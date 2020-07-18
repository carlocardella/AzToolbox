function Save-AzCliReleaseAsset {
    <#
    .SYNOPSIS
    Downloads the Az CLI installer package
    
    .PARAMETER Package
    Package type to download
    
    .PARAMETER OutputFolder
    Target folder to download the package into
    
    .EXAMPLE
    
    #>
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateSet('MSI', 'HomebrewFormula', 'UbuntuXenialDeb', 'UbuntuBionicDeb', 'RPM')]
        [string]$Package,

        [parameter()]
        [ValidateScript( { Test-Path -Path $_ -PathType 'Container' })]
        [string]$OutputFolder
    )

    $asset = Get-AzCliReleaseAsset

    switch ($Package) {
        MSI {
            $uri = 'https://aka.ms/InstallAzureCliWindowsEdge'
            Write-Verbose $uri
            # $destination = Join-Path -Path $OutputFolder -ChildPath 'Microsoft Azure CLI.msi'
            $destination = Join-Path -Path $OutputFolder -ChildPath ("{0}{1}" -f $asset.Tag, '.msi')
        }
        
        HomebrewFormula {
            $uri = 'https://aka.ms/InstallAzureCliHomebrewEdge' 
            Write-Verbose $uri
            # $destination = Join-Path -Path $OutputFolder -ChildPath 'azure-cli.rb'
            $destination = Join-Path -Path $OutputFolder -ChildPath ("{0}{1}" -f $asset.Tag, '.rb')
        }
        
        UbuntuXenialDeb {
            $uri = 'https://aka.ms/InstallAzureCliXenialEdge' 
            Write-Verbose $uri
            # $destination = Join-Path -Path $OutputFolder -ChildPath 'azure-cli_xenial_all.deb'
            $destination = Join-Path -Path $OutputFolder -ChildPath ("{0}{1}" -f $asset.Tag, '.deb')
        }
        
        UbuntuBionicDeb {
            $uri = 'https://aka.ms/InstallAzureCliBionicEdge' 
            Write-Verbose $uri
            # $destination = Join-Path -Path $OutputFolder -ChildPath 'azure-cli_bionic_all.deb'
            $destination = Join-Path -Path $OutputFolder -ChildPath ("{0}{1}" -f $asset.Tag, '.deb')
        }
        
        RPM {
            $uri = 'https://aka.ms/InstallAzureCliRpmEdge' 
            Write-Verbose $uri
            # $destination = Join-Path -Path $OutputFolder -ChildPath 'azure-cli.rpm'
            $destination = Join-Path -Path $OutputFolder -ChildPath ("{0}{1}" -f $asset.Tag, '.rpm')
        }
        
        Default {
            Write-Error "Invalid Package type: $Package"
        }
    }

    Invoke-Webrequest -Uri $uri -UseBasicParsing -DisableKeepAlive -OutFile $destination
    if ($?) {
        Write-Verbose "Package downloaded: $destination"
    }
}