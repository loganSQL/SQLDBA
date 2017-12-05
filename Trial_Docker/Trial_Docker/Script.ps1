#
#
#	Steps to test drive the Docker Windows Container
#
#
#	Steps to setup dockers
#
#
#	1. Install Docker on Windows
#	Get Docker CE for windows (Edge)
#	make sure hardware virtualization is enabled and Hyper-V is installed, lest the engine won’t start
#	on windows cmd
docker version
docker image

#	Powershell on windows
docker image

#	on WSL
#	add these two lines to your .bashrc 
PATH="$HOME/bin:$HOME/.local/bin:$PATH"
PATH="$PATH:/mnt/c/Program\ Files/Docker/Docker/resources/bin"

# Expose TCP endpoint
#
#	right-click the Docker icon in your taskbar and choose Settings, 
#	and tick the box next to “Expose daemon on tcp://localhost:2375 without TLS” (make sure you understand the risks).
# 

#	on BASH
docker -H tcp://0.0.0.0:2375 images

#
#	make the change permanent
#
echo "export DOCKER_HOST='tcp://0.0.0.0:2375'" >> ~/.bashrc
source ~/.bashrc

#	on BASH
docker images

<#
You can log into any public or private repository for which you have credentials. 
When you log in, the command stores encoded credentials in $HOME/.docker/config.json on Linux or%USERPROFILE%/.docker/config.json on Windows.
#>
docker login
logansql
100U???

<#
#	By default, Docker for windows 'Enable Linux containers on Window"
#	To run Window container, untick this in Settings->General
#>

#	Windows Containers on Windows 10
#	https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/quick-start-windows-10

docker pull microsoft/nanoserver

docker images

############################
#	First Container
############################
docker run -it microsoft/nanoserver cmd

powershell.exe Add-Content C:\helloworld.ps1 'Write-Host "Hello World"'

exit

-- get containerid
docker ps -a

-- create the new ‘HelloWorld’ image. Replace with the id of your container
-- docker commit <containerid> helloworld
docker commit 67b216876c59 hellowworld

docker images

<#
The outcome of the 'docker run' command is that a Hyper-V container was created from the 'HelloWorld' image, 
a sample 'Hello World' script was then executed (output echoed to the shell), and then the container stopped and removed. 
#>
docker run --rm helloworld powershell c:\helloworld.ps1

#########################################################################
#	Build a Sample App
#	taking a sample ASP.net app and converting it to run in a container
#########################################################################