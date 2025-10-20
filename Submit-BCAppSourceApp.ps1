Import-Module BcContainerHelper -Force

. "$PSScriptRoot\Helpers\Get-BCAuthContext.ps1"
. "$PSScriptRoot\Helpers\Get-AppSourceOffers.ps1"
. "$PSScriptRoot\Helpers\Initialize-AppSourceArchives.ps1"

$zipFilePath = "<artifacts-zip-filepath>"
$TenantId = '<your-tenant-id>'
$clientId = '<your-client-id>'
$clientSecret = '<your-client-secret>'

$authcontext = Get-BCAuthContext -tenantID $TenantId -authType 'S2S' -clientId $clientId -clientSecret $clientSecret
$selectedOffer = Get-AppSourceOffers -authcontext $authcontext 