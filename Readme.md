# Submit-BCAppSourceApp

PowerShell helper to prepare and submit a Business Central extension package (app) for AppSource/validation workflows.

## Installation
Place the script file `Submit-BCAppSourceApp.ps1` into your project folder or a centralized scripts folder.

## Usage
Basic pattern:
```powershell
$authcontext = Get-BCAuthContext -tenantID $TenantId -authType 'S2S' -clientId $clientId -clientSecret $clientSecret
$selectedOffer = Get-AppSourceOffers -authcontext $authcontext -offerName $offerName

$AppSourceArchives = Initialize-AppSourceArchives -ArtifactsPath $zipFilePath -OfferName $selectedOffer.name -mainApp $appFile -libraryApps 'all'

New-AppSourceSubmission -authContext $authContext -productId $selectedOffer.id -appFile $AppSourceArchives.mainAppFile -libraryAppFiles $AppSourceArchives.libraryAppFiles -autoPromote -Force
```
## Notes
- Review and test the script in a safe environment before using in production.
- Keep credentials secure.
- Adjust validation steps to match your organization's AppSource/marketplace rules.

## Contributing
Create issues or pull requests with improvements or bug fixes. Keep changes minimal and documented.