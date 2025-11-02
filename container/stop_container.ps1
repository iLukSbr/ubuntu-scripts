# Set default encoding to UTF-8
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
        return "ros_default"
    }
}

# Stop the ROS container
function Stop-ROS-Container {
    param (
        [string]$ServiceName
    )

    Write-Host "Checking if the container ($ServiceName) is running..."
    $containerId = docker ps -q -f "name=$ServiceName*"
    if ($containerId) {
        Write-Host "Stopping the container ($ServiceName)..."
        docker stop $containerId
#        docker rm $containerId
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Container ($ServiceName) stopped." -ForegroundColor Green
        } else {
            Write-Host "Error stopping/removing the container ($ServiceName)." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "No running container ($ServiceName) found." -ForegroundColor Yellow
    }
}

# Main function
function Main {
    Check-OS

    # Check GPU and select the appropriate service
    $serviceName = Check-GPU

    # Stop the corresponding container
    Stop-ROS-Container -ServiceName $serviceName
}

# Execute the main script
Main
