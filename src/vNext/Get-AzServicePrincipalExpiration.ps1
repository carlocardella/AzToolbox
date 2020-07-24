function Get-AzServicePrincipalExpiration {
    <#
    .SYNOPSIS
        Lists all certificates in the Azure Subscriptions passed as $SubscriptionName

    .DESCRIPTION
        Lists all certificates in the Azure Subscriptions passed as $SubscriptionName.
        Optionally it can show the expiring certificates and send an email notification.

    .EXAMPLE
        Get-AzureServicePrincipalExpiration | Format-Table

        ServicePrincipalName                                                    ApplicationId                        StartDate             EndDate               KeyId                                Type
        --------------------                                                    -------------                        ---------             -------               -----                                ----
        CD Application                                                      ca703a6a-5fef-4c1a-886a-2d584d18c3d7 8/6/2015 6:20:58 PM   8/6/2016 6:20:58 PM   a87a11e3-506b-4fff-951f-bc0f564e30fa Password
        CD WATM App                                                         5ca930cd-b869-48f6-9677-6df9b36b3b98 8/11/2015 10:47:32 PM 8/11/2016 10:47:32 PM f7e6d8a5-d4d5-4919-a006-211d827413cf Password
        ArmManagementApplicationWithCertificate                             26744a50-e616-4fb7-9056-05aeed8ebe65 2/9/2016 12:05:57 AM  8/27/2016 1:22:29 AM  859dad20-e2e6-4a74-88fb-59331ed088c7 AsymmetricX509Cert
        DSC-TestAccount                                                     49868791-4d81-4b96-87fa-a487399c9a94 10/23/2015 7:05:19 PM 10/23/2016 7:05:19 PM 356337d3-396b-4745-8be4-47d89032e01d Password
         ARM Management Application                                         59bf539a-a27c-4545-8fd6-7c21ef966c2f 12/2/2015 7:11:32 PM  12/2/2016 7:11:32 PM  e2b9b096-1c1a-4cc4-a00d-b3cdb39d31f0 Password
        ProdMgmt Application 1                                              6fd5d418-44df-4540-93e9-956f2a1b2aab 2/3/2016 4:51:12 PM   2/3/2017 4:51:12 PM   9c54ec3b-7825-4a25-9d68-ed76cc4fc7f3 Password
        cleanupapp                                                          a8078866-c9b9-430d-9cd2-96f335fe91a8 2/19/2016 3:56:25 PM  2/19/2017 3:56:25 PM  7bc79aa1-4708-4aec-8961-ae49bd98ffe1 AsymmetricX509Cert
        cleanupapp                                                          a8078866-c9b9-430d-9cd2-96f335fe91a8 2/19/2016 4:24:54 PM  2/19/2017 4:24:54 PM  c5f35b7c-57c2-41fc-9e6a-63131145fedd Password
        admin                                                               66cafc28-6490-4c61-8950-34339cd86be0 3/26/2015 5:53:47 PM  3/26/2017 5:53:47 PM  38c5a766-010c-4e4d-bbbd-56bfb9761369 Password
        -infra_6/ZDHOtz6h4w2uyC4w92dn6uH3iscJPL3bnNDV71w4g=                 e13669ff-444a-403c-8d65-a8c6efdc8838 5/8/2016 12:00:00 AM  5/9/2017 12:00:00 AM  f94d6775-ccee-458e-be0f-03068eb90cc1 AsymmetricX509Cert
        infra-scus_nz+Nkl6fkVa+R3uiSVY2p7SSB8ShWyFhxfgS6bZapBg=             048ec8b9-75c8-4b1e-991e-fc3eedbe13af 5/8/2016 12:00:00 AM  5/9/2017 12:00:00 AM  208de273-8c28-4aea-a230-3fc899a78c11 AsymmetricX509Cert
        FunctionalTestVault                                                 0f40d5b1-3f95-485e-9337-49861c5bae70 7/1/2016 10:56:42 PM  7/1/2017 10:56:42 PM  2118c439-bae0-46ea-a416-d38259a1b361 Password
        FunctionalTestVault                                                 0f40d5b1-3f95-485e-9337-49861c5bae70 7/2/2016 12:29:25 AM  7/2/2017 12:29:25 AM  54808bc7-ccbb-4a65-a60e-9a77f61702bf AsymmetricX509Cert
        RunnersProdServicePrincipal                                         af7c2ca1-46ef-48dc-94a3-19a8b8eb2c4f 7/13/2016 11:41:42 PM 7/13/2017 11:41:42 PM 5f2328f8-da89-4bc7-87ce-f59daa200443 AsymmetricX509Cert
        SolutionRP-DoNotDelete_+c18iPHCiuASazpD6+TiCqQXR0jjmCSkgqa+YF42n0c= 81c3887d-87ff-4bcd-a5b7-675577fbe87c 8/14/2016 12:00:00 AM 8/15/2017 12:00:00 AM 56253803-4968-4fbd-b0cf-e9610632effd AsymmetricX509Cert
        ArmManagementApplicationWithCertificate                             26744a50-e616-4fb7-9056-05aeed8ebe65 9/2/2016 10:28:52 PM  9/2/2017 10:28:52 PM  3ac7b9ab-d7a4-47b2-910f-82533b58f2bf AsymmetricX509Cert
        CD Application                                                      ca703a6a-5fef-4c1a-886a-2d584d18c3d7 8/8/2016 9:45:16 PM   8/8/2018 9:45:16 PM   287696d0-fb3d-4a32-a199-91e9e0af9291 Password
        CD WATM App                                                         5ca930cd-b869-48f6-9677-6df9b36b3b98 8/12/2016 12:28:43 AM 8/12/2018 12:28:43 AM 31467a81-a444-47a2-a20f-e3491d7bddb5 Password
         ARM Management Application                                         59bf539a-a27c-4545-8fd6-7c21ef966c2f 10/6/2016 10:23:36 PM 10/6/2018 10:23:36 PM 88f470ef-3b8c-48f7-a4c6-afec766eaa8f Password
        RunnersProdServicePrincipal                                         af7c2ca1-46ef-48dc-94a3-19a8b8eb2c4f 10/6/2016 10:26:09 PM 10/6/2018 10:26:09 PM 63d17c91-7eab-4b27-b204-b3bfd016cdad Password
        ProdMgmt Application 1                                              6fd5d418-44df-4540-93e9-956f2a1b2aab 10/6/2016 10:28:15 PM 10/6/2018 10:28:15 PM fd0e44f2-1f2a-4cdd-a881-59d31ee9e92b Password

    .EXAMPLE
        Get-AzureServicePrincipalExpiration -InNumberOfDays 120
    #>

    [CmdletBinding()]
    [OutputType('AzServicePrincipalExpiration')]
    param (
        [parameter(Mandatory, Position = 0)]
        [string[]]$SearchString,

        [Parameter()]
        ## set the number of days to alert before a key expires
        [int]$InNumberOfDays = 60
    )

    # $keys = @()
    foreach ($item in $SearchString) {
        Write-Verbose -Message "Searching for Service Principals matching $item"

        $keys = $null
        $keys = Get-AzADServicePrincipal -SearchString $item -PipelineVariable sp | Get-AzADAppCredential |
            Select-Object -Property @{l = 'ServicePrincipalName'; e = { $sp.DisplayName } }, `
            @{l = 'ApplicationId'; e = { $sp.ApplicationId } }, `
                StartDate, `
            @{l = 'EndDate'; e = { [datetime]($_.EndDate) } }, `
                KeyId, `
                Type
        $keys.PSObject.TypeNames.Insert(0, 'Microsoft.Azure.AzureServicePrincipalExpiration')
        Write-Output $keys

        $keys = $null
        $keys = Get-AzADServicePrincipal -SearchString $item | ForEach-Object {
            $sp = $_
            Get-AzADSpCredential -ServicePrincipalName $sp.ApplicationId |
                Select-Object -Property @{l = 'ApplicationId'; e = { $sp.ApplicationId } }, `
                @{l = 'ServicePrincipalName'; e = { $sp.DisplayName } }, `
                    StartDate, `
                @{l = 'EndDate'; e = { [datetime]($_.EndDate) } }, `
                    KeyId, `
                    Type
                $keys.PSObject.TypeNames.Insert(0, 'AzServicePrincipalExpiration')
                Write-Output $keys
            }
        }
    }
