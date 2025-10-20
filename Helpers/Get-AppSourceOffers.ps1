function Get-AppSourceOffers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]$authcontext,
        [object]$offerName
    )

    Write-Host "
   _____      _   _   _                      __  __                          
  / ____|    | | | | (_)                    / _|/ _|                         
 | |  __  ___| |_| |_ _ _ __   __ _    ___ | |_| |_ ___ _ __ ___             
 | | |_ |/ _ \ __| __| | '_ \ / _` |  / _ \|  _|  _/ _ \ '__/ __|            
 | |__| |  __/ |_| |_| | | | | (_| | | (_) | | | ||  __/ |  \__ \  _   _   _ 
  \_____|\___|\__|\__|_|_| |_|\__, |  \___/|_| |_| \___|_|  |___/ (_) (_) (_)
                               __/ |                                         
                              |___/                                          " -ForegroundColor Cyan

    # Import the BcContainerHelper module if not already imported
    if (-not (Get-Module -Name BcContainerHelper)) {
        Import-Module BcContainerHelper -Force
    }

    $AppSourceOffers = Get-AppSourceProduct -authContext $authcontext -silent | Where-Object { $_.resourceType -eq "AzureDynamics365BusinessCentral" }
    if (-not $AppSourceOffers -or $AppSourceOffers.Count -eq 0) {
        Write-Host "No AppSource offers found."
        return
    }

    if (!$offerName) {
        Write-Host "Available AppSource offers:"
        $AppSourceOffers | Sort-Object name | ForEach-Object { Write-Host "- $($_.name)" }
    }

    $selectedOffer = $null
    do {
        if (!$offerName) {
            $selectedName = Read-Host "Enter the exact name of the offer to select (or type 'Cancel' to abort)"
            if ($selectedName -eq 'Cancel') {
                throw "Selection cancelled."
            }
        }
        else {
            $selectedName = $offerName
        }
        $selectedOffer = $AppSourceOffers | Where-Object { $_.name -eq $selectedName }
        if (-not $selectedOffer) {
            Write-Host "No offer found with that exact name. Please try again."
        }
    } while (-not $selectedOffer)

    Write-Host "Working with the following offer: $($selectedOffer.name)" -ForegroundColor Green
    Write-Host
    return $selectedOffer
}