# Configure default encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Check if the operating system is Windows
function Check-OS {
    if ($env:OS -notlike "*Windows*") {
        Write-Host "This script is only compatible with Windows. Exiting..." -ForegroundColor Red
        exit 1
    }
}

# Check available GPU
function Check-GPU {
    Write-Host "Checking available GPU..."
    $gpuInfo = & wmic path win32_VideoController get name
    if ($gpuInfo -match "NVIDIA") {
        Write-Host "NVIDIA GPU detected." -ForegroundColor Green
        return "ros_nvidia_windows"
    } elseif ($gpuInfo -match "AMD") {
        Write-Host "AMD GPU detected." -ForegroundColor Green
        return "ros_amd_windows"
    } elseif ($gpuInfo -match "Intel") {
        Write-Host "Intel GPU detected." -ForegroundColor Green
        return "ros_intel_windows"
    } else {
        Write-Host "No supported GPU detected." -ForegroundColor Yellow
        exit 1
    }
}

# Check if the container is running
function Check-Container {
    param (
        [string]$ContainerName
    )

    Write-Host "Checking if the container ($ContainerName) is running..."
    $containerId = docker ps -q -f "name=$ContainerName*"
    if (-not $containerId) {
        Write-Host "The container ($ContainerName) is not running. Launch it before. Exiting..." -ForegroundColor Red
        exit 1
    }
    Write-Host "The container ($ContainerName) is running." -ForegroundColor Green
}

# Get the name of the current Git repository
function Get-GitRepoName {
    Write-Host "Detecting Git repository name..."
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        Write-Host "Error: Not inside a Git repository. Exiting..." -ForegroundColor Red
        exit 1
    }
    return (Split-Path -Path $gitRoot -Leaf)
}

# Dynamically find the workspace folder names
function Get-CatkinAndSrcNames {
    param (
        [string]$ContainerName
    )

    Write-Host "Searching for workspace folder names dynamically..."
    $currentPath = $PSScriptRoot
    while ($currentPath -ne (Get-Item $currentPath).PSDrive.Root) {
        if ($currentPath -match $ContainerName) {
            $srcPath = Split-Path -Path (Split-Path -Path (Split-Path -Path $currentPath -Parent) -Parent) -Parent
            $catkinWsPath = Split-Path -Path $srcPath -Parent

            if (-not (Test-Path $catkinWsPath) -or -not (Test-Path $srcPath)) {
                Write-Host "Error: Workspace or src folder not found. Exiting..." -ForegroundColor Red
                exit 1
            }

            $catkinWsName = Split-Path -Path $catkinWsPath -Leaf
            $srcName = Split-Path -Path $srcPath -Leaf
            Write-Host "Found workspace: $catkinWsName, src: $srcName" -ForegroundColor Green
            return @($catkinWsName, $srcName)
        }
        $currentPath = Split-Path -Path $currentPath -Parent
    }

    Write-Host "Error: Could not find workspace and src folder names dynamically. Exiting..." -ForegroundColor Red
    exit 1
}

# Main function
function Main {
    Check-OS

    # Get the Git repository name
    $repoName = Get-GitRepoName
    Write-Host "Git repository name detected: $repoName" -ForegroundColor Cyan

    # Check GPU and determine the service name
    $serviceName = Check-GPU

    # Dynamically construct the container name
    $containerName = "$repoName-$serviceName-1"

    # Check if the container is running
    Check-Container -ContainerName $containerName

    # Dynamically find catkin_ws and src folder names
    $folderNames = Get-CatkinAndSrcNames -ContainerName $repoName
    $catkinWsName = $folderNames[0]
    $srcName = $folderNames[1]

    # Open another terminal in the corresponding container and folder
    $containerPath = "/root/$catkinWsName/$srcName/$repoName"
    Write-Host "Opening terminal in the container ($containerName) at directory $containerPath..."
    docker exec -it --workdir $containerPath $containerName bash
}

# Execute the main script
Main
