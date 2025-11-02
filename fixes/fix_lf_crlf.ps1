# Script to convert CRLF line endings to LF in all files within a directory
# Starting two levels above the location of the script

# Define the starting directory as two levels above the script's location
$TargetDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent

Write-Host "Starting from directory: $TargetDirectory" -ForegroundColor Cyan

# Check if the directory exists
if (-not (Test-Path $TargetDirectory)) {
    Write-Host "Error: Directory $TargetDirectory does not exist." -ForegroundColor Red
    exit 1
}

# Search for .sh and .py files in the directory and subdirectories, excluding .venv
Get-ChildItem -Path $TargetDirectory -Recurse -File | Where-Object {
    $_.FullName -notmatch "\\.venv[\\/]?" -and ($_.Extension -eq ".sh" -or $_.Extension -eq ".py" -or $_.Extension -eq ".msg" -or $_.Extension -eq ".srv" -or $_.Extension -eq ".launch" -or $_.Extension -eq ".json" -or $_.Extension -eq ".xml" -or $_.Extension -eq ".yaml")
} | ForEach-Object {
    $filePath = $_.FullName
    Write-Host "Processing file: $filePath" -ForegroundColor Yellow

    # Read the file content and replace CRLF with LF
    $content = Get-Content -Raw -Path $filePath
    if ($content -match "`r`n") {
        $content -replace "`r`n", "`n" | Set-Content -NoNewline -Path $filePath
        Write-Host "Converted: $filePath" -ForegroundColor Green
    } else {
        Write-Host "No changes needed: $filePath" -ForegroundColor Gray
    }
}

Write-Host "Conversion completed." -ForegroundColor Green
