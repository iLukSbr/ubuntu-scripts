# ROS Noetic for Windows

# Configure default encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$env:HOSTNAME = $env:COMPUTERNAME

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

# Check if the operating system is Windows
function Check-OS {
    if ($env:OS -notlike "*Windows*") {
        Write-Host "This script is only compatible with Windows. Exiting..." -ForegroundColor Red
        exit 1
    }
}

# Check if Docker Desktop is running
function Check-Docker {
    if (-not (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)) {
        Write-Host "Docker Desktop is not running. Please open Docker Desktop." -ForegroundColor Red
        exit 1
    }
}

# Ensure WSL 2 is installed and accessible
function Check-WSL2 {
    Write-Host "Checking if WSL 2 is installed and accessible..."

    # Test if the WSL command runs without error
    try {
        wsl --list --verbose >$null 2>&1
        Write-Host "WSL 2 is installed and accessible." -ForegroundColor Green
        wsl --set-default-version 2
        wsl --update

        # Set WSL to use Ubuntu 20.04
        Write-Host "Setting WSL to use Ubuntu 20.04 as the default distribution..."
        wsl --set-default Ubuntu-20.04
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Ubuntu 20.04 notf found. Install from Microsoft Store and Open it before. Exiting..." -ForegroundColor Red
            exit 1
        }

        # Execute the install_cuda.sh script
        Write-Host "Executing install_cuda.sh script..."
        wsl bash -c "cd ../dependencies && ./install_cuda.sh"
    } catch {
        Write-Host "Error: WSL is not installed or not accessible. Please install and configure WSL 2." -ForegroundColor Red
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
        Write-Host "No supported GPU detected. Exiting..." -ForegroundColor Yellow
        exit 1
    }
}

# Check if the container is already running
function Check-Container {
    param (
        [string]$ServiceName
    )

    Write-Host "Checking if the container ($ServiceName) is already running..."
    $containerId = docker ps -q -f name=$ServiceName
    if ($containerId) {
        Write-Host "The container ($ServiceName) is already running. Stopping it to rebuild..." -ForegroundColor Yellow
        & "$PSScriptRoot/stop_container.ps1" -ServiceName $ServiceName
    }
}

# Configure Xming for graphical support
function Configure-Xming {
    Write-Host "Configuring Xming for graphical support..."
    $env:DISPLAY = "host.docker.internal:0.0"

    # Ensure X11_SOCKET and XAUTHORITY_FILE are set
    if (-not $env:X11_SOCKET) {
        $env:X11_SOCKET = "/tmp/.X11-unix"
    }
    if (-not $env:XAUTHORITY_FILE) {
        $env:XAUTHORITY_FILE = "$HOME/.Xauthority"
    }

    # Check if Xming is running
    $xmingProcess = Get-Process -Name "Xming" -ErrorAction SilentlyContinue
    if (-not $xmingProcess) {
        Write-Host "Xming is not running. Please open Xming." -ForegroundColor Red
        exit 1
    }

    Write-Host "Xming configured." -ForegroundColor Green
}

# Run the ROS container
function Run-ROS-Container {
    param (
        [string]$ServiceName = "ros_default"
    )

    $repoName = Get-GitRepoName
    Write-Host "Git repository name detected: $repoName" -ForegroundColor Cyan

    # Dynamically find catkin_ws and src folder names
    $folderNames = Get-CatkinAndSrcNames -ContainerName $repoName
    $catkinWsName = $folderNames[0]
    $srcName = $folderNames[1]
    Write-Host "Workspace folder names detected: $catkinWsName, src: $srcName" -ForegroundColor Cyan

    # Get the container name
    $containerName = "$repoName-$ServiceName"

    Write-Host "Starting the ROS container ($ServiceName) with GPU and webcam support..."
    $logFile = "build_logs_$ServiceName.log"

    $composeFilePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $composeFilePath = Join-Path -Path $composeFilePath -ChildPath ".devcontainer/docker-compose.yaml"
    if (-not (Test-Path $composeFilePath)) {
        Write-Host "Error: Arquivo docker-compose.yml não encontrado em $composeFilePath. Exiting..." -ForegroundColor Red
        exit 1
    }

    # Start the container with GPU and webcam support
    $env:COMPOSE_BAKE = "false"
    docker compose -f $composeFilePath build $ServiceName | Tee-Object -FilePath $logFile
    docker compose -f $composeFilePath up -d $ServiceName | Tee-Object -FilePath $logFile
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error starting the container. Check the Docker Compose configuration. Logs saved to $logFile" -ForegroundColor Red
        exit 1
    }
    Write-Host "ROS container ($ServiceName) started with GPU and webcam support. Logs saved to $logFile."

    # Access the container in the workspace directory
    $containerPath = "/root/$catkinWsName/$srcName/$repoName"
    $containerId = docker ps -q -f "name=$containerName*"
    if (-not $containerId) {
        Write-Host "Falha ao encontrar o contêiner ($containerName). Certifique-se de que ele está em execução." -ForegroundColor Red
        exit 1
    }
    Write-Host "Accessing the ROS container ($ServiceName) in directory $containerPath..."
    docker exec -it --workdir $containerPath $containerId bash --login
}

# Main function
function Main {
    Check-OS
    Check-Docker
    Check-WSL2

    # Check GPU and select the appropriate service
    $serviceName = Check-GPU
    if ($serviceName -eq "ros_default") {
        Write-Host "Exiting the script due to the absence of a supported GPU." -ForegroundColor Red
        exit 1
    }

    # Check if the container is already running
    Check-Container -ServiceName $serviceName

    Configure-Xming
    Run-ROS-Container -ServiceName $serviceName
}

# Execute the main script
Main
