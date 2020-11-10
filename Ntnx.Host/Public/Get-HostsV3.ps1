function Get-HostsV3 {   
<#
.SYNOPSIS
Dynamically Generated API Function
.NOTES
NOT FOR PRODUCTION USE - FOR DEMONSTRATION/EDUCATION PURPOSES ONLY

The code samples provided here are intended as standalone examples.  They can be downloaded, copied and/or modified in any way you see fit.

Please be aware that all code samples provided here are unofficial in nature, are provided as examples only, are unsupported and will need to be heavily modified before they can be used in a production environment.
#>

    [CmdletBinding()]
    [OutputType()]

    param(
        # VIP or FQDN of target AOS cluster
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        <# Number of Hosts to return
        [Parameter()]
        [Parameter(ParameterSetName="Count")]
        [AllowNull()]
        [int]
        $Count,

        [Parameter()]
        [Parameter(ParameterSetName="Count")]
        [AllowNull()]
        [int]
        $Offset,

        # All Records
        [Parameter(Mandatory=$false)]
        [Parameter(ParameterSetName="All")]
        [switch]
        $All,
#>
        # Prism UI Credential to invoke call
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,

        # Prism UI Credential to invoke call
        [Parameter(Mandatory=$false)]
        [switch]
        $SkipCertificateCheck = $true,

        # Port (Default is 9440)
        [Parameter(Mandatory=$false)]
        [int16]
        $Port = 9440
    )

    begin {
        Set-StrictMode -Version Latest
    }

    process {

        $body = @{
            kind = "host"
        } 

        $Count = 1
        $Offset = 0

        <#
        if($All){
            $Count = 500
            $Offset = 0
        }

        if($null -ne $Count){
            $body.add("length",$Count)
        }
        if($null -ne $Offset){
            $body.add("offset",$Offset)
        }
        #>

        $body.add("length",$Count)
        $body.add("offset",$Offset)

        $iwrArgs = @{
            Uri = "https://$($ComputerName):$($Port)/api/nutanix/v3/hosts/list"
            ContentType = "application/json"
            Method = "POST"
            Body = $body | ConvertTo-Json -Depth 99
        }

        if($PSVersionTable.PSVersion.Major -lt 6){
            $basicAuth = Initialize-BasicAuthHeader -credential $Credential
            $iwrArgs.Add("headers",$basicAuth)
        }
        else{
            $iwrArgs.add("Authentication","Basic")
            $iwrArgs.add("Credential",$Credential)
            $iwrArgs.add("SslProtocol","Tls12")

            if($SkipCertificateCheck){
                $iwrArgs.add("SkipCertificateCheck",$true)
            }
        }
        
        try {
            $response = Invoke-WebRequest @iwrArgs
            if($response.StatusCode -eq 200){
                $totalMatches = ($response.content | ConvertFrom-Json -Depth 99).metadata.total_matches
                Write-Verbose -Message "Total records: $totalMatches"
                if($Count -lt $totalMatches){
                    ($response.content | ConvertFrom-Json -Depth 99).entities
                }
                #elseif($totalMatches -gt $Count){
                else{
                    do { 
                        $response = Invoke-WebRequest @iwrArgs
                        if($response.StatusCode -eq 200){
                            ($response.content | ConvertFrom-Json -Depth 99).entities
                        }
                        $iwrArgs.body.offset += $Count
                        Write-Verbose -Message "$Count"
                    }
                    Until (
                        $iwrArgs.body.offset -ge $totalMatches
                    )
                }
            }
        }
        catch {
            Write-Error -Message "ERROR $($response.StatusCode)"
        }
               
    }
                
}
