﻿function Get-VSAItems
{
<#
.Synopsis
   Returns VSA items using Get  REST API method
.DESCRIPTION
   Returns existing VSA objects.
   Takes either persistent or non-persistent connection information.
.PARAMETER VSAConnection
    Specifies existing non-persistent VSAConnection.
.PARAMETER URISuffix
    Specifies URI suffix if it differs from the default.
.PARAMETER Filter
    Specifies REST API Filter.
.PARAMETER Paging
    Specifies REST API Paging.
.PARAMETER Sort
    Specifies REST API Sorting.
.EXAMPLE
   Get-VSAItems
.EXAMPLE
   Get-VSAItems -VSAConnection $connection
.INPUTS
   Accepts piped non-persistent VSAConnection 
.OUTPUTS
   Array of custom objects that represent VSA objects.
#>
    [CmdletBinding()]
    param ( 
        [parameter(Mandatory = $true, 
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'NonPersistent')]
        [VSAConnection] $VSAConnection,
        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'NonPersistent')]
        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'Persistent')]
        [ValidateNotNullOrEmpty()] 
        [string] $URISuffix,
        [Parameter(ParameterSetName = 'Persistent', Mandatory = $false)]
        [Parameter(ParameterSetName = 'NonPersistent', Mandatory = $false)]
        [ValidateNotNullOrEmpty()] 
        [string] $Filter,
        [Parameter(ParameterSetName = 'Persistent', Mandatory = $false)]
        [Parameter(ParameterSetName = 'NonPersistent', Mandatory = $false)]
        [ValidateNotNullOrEmpty()] 
        [string] $Paging,
        [Parameter(ParameterSetName = 'Persistent', Mandatory = $false)]
        [Parameter(ParameterSetName = 'NonPersistent', Mandatory = $false)]
        [ValidateNotNullOrEmpty()] 
        [string] $Sort
    )

    if ([VSAConnection]::IsPersistent)
    {
        $CombinedURL = "$([VSAConnection]::GetPersistentURI())/$URISuffix"
        $UsersToken = "Bearer $( [VSAConnection]::GetPersistentToken() )"
    }
    else
    {
        $ConnectionStatus = $VSAConnection.GetStatus()

        if ( 'Open' -eq $ConnectionStatus )
        {
            $CombinedURL = "$($VSAConnection.URI)/$URISuffix"
            $UsersToken = "Bearer $($VSAConnection.GetToken())"
        }
        else
        {
            throw "Connection status: $ConnectionStatus"
        }
    }
    #region Filterin, Sorting, Paging
    [string]$JoinWith = '?'

    if ( $Filter ) {
        $CombinedURL += "`?`$filter=$Filter"
        $JoinWith = '&'
    }
    if ( $Sort ) {
        $CombinedURL += "$JoinWith`$orderby=$Sort"
        $JoinWith = '&'
    }
    if ($Paging) {
        $CombinedURL += "$JoinWith`$$Paging"
    }
    
    #endregion Filterin, Sorting, Paging

    $result = Get-RequestData -URI $CombinedURL -AuthString $UsersToken

    return $result
}
Export-ModuleMember -Function Get-VSAUsers
