#
#	Steps to administer Docker Service locally, and manipulate the container images
#
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


# 2. Install Docker Locally
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

# 3 : Install the base container image locally
# Install the Nano Server image
docker load -i C:\ContainerSource\nanoserver.tar.gz

# List the Docker images
docker images

# Tag the Nano Server image
docker tag microsoft/nanoserver:10.0.14393 nanoserver:latest

# List the Docker images
docker images


# 4 : Run and manage containers
# Create a container and run a program
docker run -it --isolation=hyperv --name dockerdemo nanoserver cmd

# Examine files in a container
dir

# View the networking configuration
ipconfig

# Ping the external host
ping svrname.yourdomain.com

# List the containers
docker ps

# Exit the container
exit

# List the containers
docker ps

# List the containers
docker ps -a

# Start the container
docker start dockerdemo

# Attach to the container
docker attach dockerdemo

# View the networking configuration
ipconfig

# Create a file on the container
ipconfig > c:\ipconfig.txt

# Display the contents of the text file
type c:\ipconfig.txt

# Exit the console session
exit

# Create a new container image
docker commit dockerdemo newcontainerimage

# Display the container images
docker images

# Create a new container from a new image
docker run -it --name newcontainer newcontainerimage cmd

# Verify the presence of the ipconfig.txt file
type c:\ipconfig.txt

# View the network configuration
ipconfig

# Exit the console session
exit

# Remove newcontainer
docker rm newcontainer

# Remove dockerdemo
docker rm dockerdemo

# Remove the newcontainer image
docker rmi newcontainerimage

# Verify the image deletion
docker images
Close all open windows

# 5 : Manage images and containers
# Change the directory to C:\Build\IIS
cd \build\iis

# List the dockerfile contents
type dockerfile

# Create the server container image
docker build –t nanoserver_iis1 c:\build\iis

# Verify the container image creation
docker images

# Run the container
docker run -it --name iis1 nanoserver_iis1 cmd

#If, after a few minutes, the console session does not appear, press ENTER.
docker run -it --name iis1 nanoserver_iis1 cmd

#Change to the packages directory
cd packages

#Install the IIS role
dism /online /apply-unattend:.\unattend.xml

# Start the web service
net start w3svc

# Exit the console session
exit

# Create a new container image
docker commit iis1 nanoserver_iis2

# Configure a firewall rule to allow HTTP traffic
if (!(Get-NetFirewallRule | where {$_.Name –eq “TCP80”})) { New-NetFirewallRule –Name “TCP80” –DisplayName “HTTP on TCP/80” –Protocol tcp –LocalPort 80 –Action Allow -Enabled True}

# Deploy the Nano Server with the IIS role container
docker run –it --name iiscontainer –p 80:80 nanoserver_iis2 cmd

# Please wait for the console session to appear before proceeding to the next step. This will take 30–60 seconds.
docker run –it --name iiscontainer –p 80:80 nanoserver_iis2 cmd

# Sign in to another host
Open Internet Explorer
Browse to the website running on the container
In Internet Explorer, browse to http://10.10.10.41. 
http://10.10.10.41
