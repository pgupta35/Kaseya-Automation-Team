﻿function Add-VSAOrganization {
    <#
    .Synopsis
       Creates a new organization.
    .DESCRIPTION
       Creates a new organization.
       Takes either persistent or non-persistent connection information.
    .PARAMETER VSAConnection
        Specifies existing non-persistent VSAConnection.
    .PARAMETER URISuffix
        Specifies URI suffix if it differs from the default.
    .PARAMETER OrgName
        Specifies full organization name.
    .PARAMETER OrgRef
        Specifies string to reference the organization. Must be unique. Usually shorten name or acronim.
    .PARAMETER DefaultDepartmentName
        Specifies Default Department Name. root by default.
    .PARAMETER DefaultMachineGroupName
        Specifies Default Machine Group Name. root by default.
    .PARAMETER OrgType
        Specifies Organization Type.
    .PARAMETER ParentOrgId
        Specifies Numeric Id of existing organization that is set as the parent for the new one.
    .EXAMPLE
       Add-VSAOrganization -OrgName 'My Organization' -OrgRef 'myorg'
    .INPUTS
       Accepts piped non-persistent VSAConnection 
    .OUTPUTS
       True if creation was successful
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true)]
        [VSAConnection] $VSAConnection,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $URISuffix = 'api/v1.0/system/orgs',

        [parameter(DontShow,
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            if( (-not [string]::IsNullOrEmpty($_)) -and ($_ -notmatch "^\d+$") ) {
                throw "Non-numeric value"
            }
            return $true
        })]
        [string] $OrgId,

        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage = "Specify name of the organization.")]
        [ValidateNotNullOrEmpty()]
        [string] $OrgName,

        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage = "Unique string to reference the organization. Usually shorten name or acronim.")]
        [ValidateNotNullOrEmpty()]
        [string] $OrgRef,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string] $DefaultDepartmentName = 'root',

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string] $DefaultMachineGroupName = 'root',

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $OrgType,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            if( (-not [string]::IsNullOrEmpty($_)) -and ($_ -notmatch "^\d+$") ) {
                throw "Non-numeric Id"
            }
            return $true
        })]
        [string] $ParentOrgId,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string] $Website,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            if( (-not [string]::IsNullOrEmpty($_)) -and ($_ -notmatch "^\d+$") ) {
                throw "Non-numeric value"
            }
            return $true
        })]
        [Alias('NumberOfEmployees')]
        [string] $NoOfEmployees,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({
            if( (-not [string]::IsNullOrEmpty($_)) -and ($_ -notmatch "^\d+$") ) {
                throw "Non-numeric value"
            }
            return $true
        })]
        [string] $AnnualRevenue,

        [parameter(DontShow,
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ContactInfo,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $PreferredContactMethod,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $PrimaryPhone,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $PrimaryFax,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $PrimaryEmail,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Country,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Street,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $City,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $State,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ZipCode,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $PrimaryTextMessagePhone,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()] 
        [string] $FieldName,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $FieldValue,

        [parameter(DontShow,
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [string[]] $CustomFields = @(),

        [parameter(DontShow,
            Mandatory=$false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Attributes
        )

    if ([string]::IsNullOrEmpty($OrgId))
    {
        [string]$OrgId = $((100..999) | Get-Random).ToString()
    }

    $BodyHT = [ordered]@{
            OrgName                 = $OrgName
            OrgRef                  = $OrgRef
            OrgId                   = [decimal]$OrgId
        }

    if ( -not [string]::IsNullOrEmpty($DefaultDepartmentName) )   { 
        $BodyHT.Add('DefaultDepartmentName', $DefaultDepartmentName) 
        } else {
            $BodyHT.Add('DefaultDepartmentName', 'root') 
        }
    if ( -not [string]::IsNullOrEmpty($DefaultMachineGroupName) ) {
        $BodyHT.Add('DefaultMachineGroupName', $DefaultMachineGroupName) 
        } else {
            $BodyHT.Add('DefaultMachineGroupName', 'root') 
        }
    if ( -not [string]::IsNullOrEmpty($OrgType) )                 { $BodyHT.Add('OrgType', $OrgType) }
    if ( -not [string]::IsNullOrEmpty($ParentOrgId) )             { $BodyHT.Add('ParentOrgId', [decimal]$ParentOrgId) }
    if ( -not [string]::IsNullOrEmpty($Website) )                 { $BodyHT.Add('Website', $Website) }
    if ( -not [string]::IsNullOrEmpty($NoOfEmployees) )           { $BodyHT.Add('NoOfEmployees', $NoOfEmployees) }
    if ( -not [string]::IsNullOrEmpty($AnnualRevenue) )           { $BodyHT.Add('AnnualRevenue', [decimal]$AnnualRevenue) }
    
    if ( -not [string]::IsNullOrEmpty($ContactInfo) ) {
        #convert string literal to hashtable
        $ContactInfo -match '{(.*?)\}'
        [hashtable] $ContactInfoHT = ConvertFrom-StringData -StringData $($Matches[1] -replace '= ','=' -replace '; ',';' -split ';' -join "`n")
    } else {
        [hashtable] $ContactInfoHT = @{}
    }

    if ($PreferredContactMethod)  { $ContactInfoHT.Add('PreferredContactMethod', $PreferredContactMethod)}
    if ($PrimaryPhone)            { $ContactInfoHT.Add('PrimaryPhone', $PrimaryPhone)}
    if ($PrimaryFax)              { $ContactInfoHT.Add('PrimaryFax', $PrimaryFax)}
    if ($PrimaryEmail)            { $ContactInfoHT.Add('PrimaryEmail', $PrimaryEmail)}
    if ($Country)                 { $ContactInfoHT.Add('Country', $Country)}
    if ($Street)                  { $ContactInfoHT.Add('Street', $Street)}
    if ($City)                    { $ContactInfoHT.Add('City', $City)}
    if ($State)                   { $ContactInfoHT.Add('State', $State)}
    if ($ZipCode)                 { $ContactInfoHT.Add('ZipCode', $ZipCode)}
    if ($PrimaryTextMessagePhone) { $ContactInfoHT.Add('PrimaryTextMessagePhone', $PrimaryTextMessagePhone)}
    
    if ( 0 -lt $ContactInfoHT.Count)
    {
        $BodyHT.Add('ContactInfo', $ContactInfoHT )
    }

    if ( 0 -lt $CustomFields.Count )
    {
        [array]$CustomFieldArray = @()
        Foreach ( $CustomField in $CustomFields )
        {
            $CustomField -match '{(.*?)\}'
            $CustomFieldArray += $( ConvertFrom-StringData -StringData $($Matches[1] -replace '= ','=' -replace '; ',';' -split ';' -join "`n") )
        }
        $BodyHT.Add('CustomFields', $CustomFieldArray )
    }
    if ( ( -not [string]::IsNullOrWhiteSpace($FieldName)) -and ( -not [string]::IsNullOrWhiteSpace($FieldValue)) )
    {
        $BodyHT.Add('CustomFields', @(@{ FieldName  = $FieldName; FieldValue = $FieldValue }) )
    }

    if ( -not [string]::IsNullOrEmpty($Attributes) ) {
        [hashtable] $AttributesHT = ConvertFrom-StringData -StringData $Attributes
        $BodyHT.Add('Attributes', $AttributesHT )
    }
   
    $Body = $BodyHT | ConvertTo-Json

    $Body | Out-String | Write-Debug
    $Body | Out-String | Write-Verbose

    [hashtable]$Params = @{}
    if($VSAConnection) {$Params.Add('VSAConnection', $VSAConnection)}

    $Params.Add('URISuffix', $URISuffix)
    $Params.Add('Method', 'POST')
    $Params.Add('Body', $Body)

    $Params | Out-String | Write-Debug

    return Update-VSAItems @Params
}
Export-ModuleMember -Function Add-VSAOrganization