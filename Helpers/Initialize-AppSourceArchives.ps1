function Initialize-AppSourceArchives {
    param (
        [Parameter(Mandatory = $true)]
        [string]$OfferName,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactsPath
    )

    Write-Host "
  _____                           _                __ _ _                       
 |  __ \                         (_)              / _(_) |                      
 | |__) | __ ___ _ __   __ _ _ __ _ _ __   __ _  | |_ _| | ___  ___             
 |  ___/ '__/ _ \ '_ \ / _` | '__| | '_ \ / _` | |  _| | |/ _ \/ __|            
 | |   | | |  __/ |_) | (_| | |  | | | | | (_| | | | | | |  __/\__ \  _   _   _ 
 |_|   |_|  \___| .__/ \__,_|_|  |_|_| |_|\__, | |_| |_|_|\___||___/ (_) (_) (_)
                | |                        __/ |                                
                |_|                       |___/                                 " -ForegroundColor Cyan

    $TmpPath = Join-Path -Path $env:TEMP -ChildPath ("AppExtract_{0}" -f [guid]::NewGuid().ToString())

    # Extract zip to a temp folder
    New-Item -Path $TmpPath -ItemType Directory -Force | Out-Null
    Expand-Archive -LiteralPath $ArtifactsPath -DestinationPath $TmpPath -Force

    $files = Get-ChildItem -Path $TmpPath -File -Filter '*.app' -Recurse
    if (-not $files) {
        throw "No files found in archive."
    }

    $files | Sort-Object Name | ForEach-Object { Write-Host "- $($_.Name)" }

    # Select the main file for the offer
    while ($true) {
        $mainInput = Read-Host "Select main app file by typing its exact file name (or type 'cancel' to abort)"
        if ($mainInput -eq 'cancel') {
            throw "Aborted by user."
        }
        $matchesSelectedApps = $files | Where-Object { $_.Name -eq $mainInput }
        if ($matchesSelectedApps.Count -gt 1) {
            throw "Multiple files share that name."
        }
        if ($matchesSelectedApps.Count -eq 1) {
            $mainFile = $matchesSelectedApps[0]
            break
        }
        else {
            Write-Host "No file found with that exact name. Try again."
            continue
        }

    }
    
    $mainAppFile = $mainFile.FullName

    Write-Host "Using $mainAppFile as main app file." -ForegroundColor Green
    Write-Host

    # Select library apps (exclude the main file); allow selecting one exact file name at a time, or 'none' or 'cancel'
    $libraryCandidates = $files | Where-Object { $_.FullName -ne $mainFile.FullName }
    if ($libraryCandidates) {
        $selectedLibraryFiles = @()
        while ($true) {
            if (-not $libraryCandidates) {
                Write-Host "No more library candidates available."
                break
            }

            Write-Host "Available library candidates (type one exact file name at a time, or 'all' to select all remaining):"
            $libraryCandidates | Sort-Object Name | ForEach-Object { Write-Host "- $($_.Name)" }

            $libInput = Read-Host "Select a single library app file by typing its exact file name, or type 'all' to include all remaining, 'none' to finish, or 'cancel' to abort"
            if ($null -eq $libInput) {
                Write-Host "No input provided. Try again."
                continue
            }

            $inputTrimmed = $libInput.Trim()
            $inputLower = $inputTrimmed.ToLowerInvariant()

            if ($inputLower -eq 'cancel') {
                Write-Host "Aborted by user."
                Remove-Item -LiteralPath $TmpPath -Recurse -Force -ErrorAction SilentlyContinue
                return
            }
            if ($inputLower -eq 'none') {
                break
            }
            if ($inputLower -eq 'all') {
                # Add all remaining candidates
                $selectedLibraryFiles += $libraryCandidates
                Write-Host ("Selected all remaining library files (" + ($libraryCandidates.Count) + ").")
                # clear candidates to indicate nothing left
                $libraryCandidates = @()
                break
            }

            if ([string]::IsNullOrWhiteSpace($inputTrimmed)) {
                Write-Host "No input provided. Try again."
                continue
            }

            $name = $inputTrimmed
            $matchesSelectedApps = $libraryCandidates | Where-Object { $_.Name -eq $name }
            if ($matchesSelectedApps.Count -gt 1) {
                throw "Multiple files share that name."
            }
            if ($matchesSelectedApps.Count -eq 0) {
                Write-Host "No file found with that exact name among remaining candidates. Try again."
                continue
            }
            else {
                $selected = $matchesSelectedApps[0]
                $selectedLibraryFiles += $selected
                # remove selected from candidates to avoid duplicate selection
                $libraryCandidates = $libraryCandidates | Where-Object { $_.FullName -ne $selected.FullName }
                Write-Host ("Selected: " + $selected.Name)
                Write-Host "You may select another file, or type 'none' to finish."
                continue
            }
        }
        
        if ($selectedLibraryFiles.Count -gt 0) {
            $libraryAppsPath = Join-Path -Path $TmpPath -ChildPath ("{0}.libraries.zip" -f $OfferName)
            Compress-Archive -LiteralPath ($selectedLibraryFiles | ForEach-Object { $_.FullName }) -DestinationPath $libraryAppsPath -Force

            Write-Host "Using $libraryAppsPath for library apps." -ForegroundColor Green
            Write-Host
        }
    }

    return @{
        mainAppFile     = $mainAppFile
        libraryAppFiles = $libraryAppsPath
    }
}