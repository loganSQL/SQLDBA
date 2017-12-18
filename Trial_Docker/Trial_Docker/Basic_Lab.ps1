#
#	Steps to administer Docker Service locally
# Basic_Lab.ps1
#

# Open Windows PowerShell as Administrator

# 1. Prerequisit
# Display the Containers feature
Get-WindowsOptionalFeature -Online -FeatureName containers

# Display Hyper-V features
Get-WindowsOptionalFeature -Online -FeatureName *hyper*

# Examine the image file  (open C:\ContainerSource in File Explorer)
# 
start c:\ContainerSource


# 2. Install Docker
# Create a folder for Docker executables
New-Item -Type Directory -Path $env:ProgramFiles\docker\

# Copy the docker daemon and client
Copy-Item C:\ContainerSource\d*.exe $env:ProgramFiles\docker -Recurse

# Add the Docker directory to the system path
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:ProgramFiles\docker", [EnvironmentVariableTarget]::Machine)

# View the network configuration
ipconfig

# Install Docker as a Windows service
dockerd --register-service

# Start the Docker service
Start-Service Docker

# View the default Docker network
docker network ls

# View detailed network information
docker network inspect nat

# 3 : Install the base container image
# Install the Nano Server image
docker load -i C:\ContainerSource\nanoserver.tar.gz

# List the Docker images
docker images

# Tag the Nano Server image
docker tag microsoft/nanoserver:10.0.14393 nanoserver:latest

# List the Docker images
docker images


