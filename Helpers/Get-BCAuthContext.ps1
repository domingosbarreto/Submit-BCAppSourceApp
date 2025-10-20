function Get-BCAuthContext {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("S2S", "UserImpersonation")]
        [object]$authType,    
        [string]$clientId,
        [string]$clientSecret,
        [string]$tenantID
    )

    Write-Host "
                _   _                _   _           _   _                         
     /\        | | | |              | | (_)         | | (_)                        
    /  \  _   _| |_| |__   ___ _ __ | |_ _  ___ __ _| |_ _ _ __   __ _             
   / /\ \| | | | __| '_ \ / _ \ '_ \| __| |/ __/ _` | __| | '_ \ / _` |            
  / ____ \ |_| | |_| | | |  __/ | | | |_| | (_| (_| | |_| | | | | (_| |  _   _   _ 
 /_/    \_\__,_|\__|_| |_|\___|_| |_|\__|_|\___\__,_|\__|_|_| |_|\__, | (_) (_) (_)
                                                                  __/ |            
                                                                 |___/             " -ForegroundColor Cyan

    # Import the BcContainerHelper module if not already imported
    if (-not (Get-Module -Name BcContainerHelper)) {
        Import-Module BcContainerHelper -Force
    }

    if ($authType -eq "S2S") {
        # Create a new BC Auth Context with S2S authentication
        $authcontext = New-BcAuthContext `
            -clientID $clientId `
            -clientSecret $clientSecret `
            -Scopes "https://api.partner.microsoft.com/.default" `
            -tenantID $tenantID
    }
    else {
        # $authType -eq "UserImpersonation"
        # Create a new BC Auth Context with device login and specified scopes
        $authcontext = New-BcAuthContext `
            -includeDeviceLogin `
            -Scopes "https://api.partner.microsoft.com/user_impersonation offline_access" `
            -tenantID $tenantID
    }
    return $authcontext
}