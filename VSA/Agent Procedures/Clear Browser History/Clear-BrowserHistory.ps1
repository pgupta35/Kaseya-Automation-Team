﻿<#
.SYNOPSIS
    Removes history entries for the most popular browsers.
.DESCRIPTION
    Removes history entrie for Google Chrome, Mozilla Firefox & IE.
.PARAMETER DaysToKeep
    Specifies the number of days to keep browser data. Everything older that
    the given number of days will be removed.
    Defaults to 7.
.PARAMETER All
    This is a shorthand switch. When set, Cookies, Temporary files and History items will be cleared.
.PARAMETER Cookies
    When set, Cookies will be removed.
.PARAMETER TemporaryFiles
    When set, the Temporary files will be removed.
.PARAMETER History
    When set, History and History-journal and Visited Links will be removed.
.EXAMPLE
    .\Clear-BrowserHistory.ps1 -All -DaysToKeep 14
    Will remove Cookies, Temporary files and History older than 14 days.
.EXAMPLE
    .\Clear-BrowserHistory.ps1 -Cookies -DaysToKeep 0
    Will remove all cookies.
.NOTES
    Version 0.1
    Author: Proserv Team - VS
#>
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [int] $DaysToKeep = 7,

    [Parameter(ParameterSetName='ByAll')]
    [switch] $All,

    [Parameter(ParameterSetName='ByItem')]
    [switch] $Cookies,          # file: Cookies and Cookies-journal
    [Parameter(ParameterSetName='ByItem')]
    [switch] $TemporaryFiles,   # folder: Cache
    [Parameter(ParameterSetName='ByItem')]
    [switch] $History  # Archived History 
)

function Clear-Folder {
[CmdletBinding()]
param (
    [parameter(Mandatory = $true, 
        Position = 0,
        ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $TheFolder,
    [Parameter(Mandatory = $true,
    Position = 1)]
    [int] $DaysToKeep
)
    $OlderThan = (Get-Date).AddDays(-([Math]::Abs($DaysToKeep)))
    if(Test-Path -Path $TheFolder)
    {
        Get-ChildItem -Path $TheFolder -Recurse -Force | Where-Object { $_.CreationTime -lt $OlderThan } | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    }
}

#Clear the system temp folder
Get-ItemProperty -Path Registry::'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name "TEMP" | Select-Object -ExpandProperty "TEMP" | Clear-Folder

#Clear users' cookies
[string] $SIDPattern = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
Get-WmiObject Win32_UserProfile | Where-Object {$_.SID -match $SIDPattern} | Select-Object LocalPath, SID | `
    ForEach-Object {
        
        [array] $ItemsToClear = @()
        $UserProfilePath = $_.LocalPath

        reg load "HKU\$($_.SID)" "$UserProfilePath\ntuser.dat"

        [string] $AppDataPath = Get-ItemProperty -Path Registry::$(Join-Path -Path "HKEY_USERS\$($_.SID)" -ChildPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders") -Name "Local AppData" | Select-Object -ExpandProperty "Local AppData"
        <#
        Typically, the path to the user's TEMP folder in the registry contains a relative path that refers to the USERPROFILE system variable.
        When the registry value is read, the runtime automatically places the running process owner's profile path in the USERPROFILE variable.
        Therefore, to get the correct path to the user's TEMP folder, the registry value referencing USERPROFILE must be corrected by replacing the process owner's profile path with the user's profile path.
        #>
        $RunningProcessProfilePath = $env:USERPROFILE
        
        $AppDataPath.Replace($RunningProcessProfilePath, $UserProfilePath)

        #region Cleanup
        if ($Cookies -or $All)
        {
            #Mozilla
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Mozilla\Firefox\Profiles\*.default\cookies.sqlite"
            #Chrome
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Google\Chrome\User Data\Default\Cookies*"
            #Microsoft browsers
            $ItemsToClear += ( Get-ItemProperty -Path Registry::$(Join-Path -Path "HKEY_USERS\$($_.SID)" -ChildPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders") -Name "Cookies" `
                | Select-Object -ExpandProperty "Cookies" ).Replace($RunningProcessProfilePath, $UserProfilePath)
        }
        if ($TemporaryFiles -or $All)
        {
            #Mozilla
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Mozilla\Firefox\Profiles\*.default\cache*"
            #Chrome
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Google\Chrome\User Data\Default\cache*"
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Google\Chrome\User Data\Default\Media Cache*"
            #Microsoft browsers
            $ItemsToClear += ( Get-ItemProperty -Path Registry::$(Join-Path -Path "HKEY_USERS\$($_.SID)" -ChildPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders") -Name "Cache" `
                | Select-Object -ExpandProperty "Cache" ).Replace($RunningProcessProfilePath, $UserProfilePath)
        }
        if ($History -or $All)
        {
            #Mozilla
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Mozilla\Firefox\Profiles\*.default\places.sqlite"
            #Chrome
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Google\Chrome\User Data\Default\History*"
            $ItemsToClear += Join-Path -Path $AppDataPath -ChildPath "Google\Chrome\User Data\Default\Visited Links*"
            #Microsoft browsers
            $ItemsToClear += ( Get-ItemProperty -Path Registry::$(Join-Path -Path "HKEY_USERS\$($_.SID)" -ChildPath "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders") -Name "History" `
                | Select-Object -ExpandProperty "Cache" ).Replace($RunningProcessProfilePath, $UserProfilePath)
        }

        $ItemsToClear | Clear-Folder -DaysToKeep $DaysToKeep
        #endregion Cleanup

        [gc]::Collect()
        reg unload "HKU\$($_.SID)"
    }