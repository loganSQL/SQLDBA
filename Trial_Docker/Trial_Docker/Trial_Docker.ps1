#
#
#	Steps to test drive the Docker Containers
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
docker images

#	Powershell on windows
docker images

#######################################################
#	Test drive Docker Linux Container from WSL
#######################################################
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


#################################################
#	Test drive Docker Windows Container
################################################
<#
#	By default, Docker for windows 'Enable Linux containers on Window"
#	To run Window container, untick this in Settings->General
#>


##################################
#	Install Base Container Images
##################################
#	Windows Containers on Windows 10
#	https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/quick-start-windows-10

docker pull microsoft/nanoserver

docker images

############################
#	First Container
############################
## 1.	start a container with interactive session from nanoserver image
##		Once the container started, a command shell is presented
docker run -it microsoft/nanoserver cmd

## 2.	create a simple'Hello World' ps script file
powershell.exe Add-Content C:\helloworld.ps1 'Write-Host "Hello World"'

## 3.	explore what is inside this container, exit the container
dir
type helloworld.ps1
exit

-- get containerid
docker ps -a

-- create the new ‘HelloWorld’ image. Replace with the id of your container
-- docker commit <containerid> helloworld
docker commit 67b216876c59 helloworld

docker images

<#
The outcome of the 'docker run' command is that a Hyper-V container was created from the 'HelloWorld' image, 
a sample 'Hello World' script was then executed (output echoed to the shell), and then the container stopped and removed. 
#>
docker run --rm helloworld powershell c:\helloworld.ps1

###################################
# https://www.maherjendoubi.io/asp-net-core-2-0-in-docker/
###########################################################
## 1.NET Core 2.0 in docker
docker pull microsoft/dotnet:2.0.0

# create a new console app. Let's see the files created and do a dotnet run to run the app.
dir
cd Windows\Temp
dir
dotnet new console
dotnet run
#
# 2. ASP.NET Core 2.0 in Docker
#
docker pull microsoft/aspnetcore:2.0.0
docker pull microsoft/aspnetcore-build:2.0.0
docker images

cd C:\Windows\Temp
dir

dotnet new web -o .\
dotnet run

<#

Hosting environment: Production
Content root path: C:\Windows\Temp
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.
#>


#########################################################################
#	Build a Sample App
#	taking a sample ASP.net app and converting it to run in a container
#########################################################################
#
#	https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/building-sample-app
#
cd C:\logan\test\SampleASPContainerApp

git clone https://github.com/cwilhit/SampleASPContainerApp.git

#	create the dockerfile for our proj
#	dockerfile : a makefile--a list of instructions that describe how a container image must be built.

mkdir proj
New-Item C:\logan\test\SampleASPContainerApp\proj\Dockerfile -type file

#	
notepad Dockerfile
# Add the following int Dockerfile
FROM microsoft/aspnetcore-build:1.1 AS build-env
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out

FROM microsoft/aspnetcore:1.1
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "MvcMovie.dll"]

##	Running the App

#	Build the app 
docker build -t myasp .
#	Run the container and give the container tag "myapp"
docker run -d -p 5000:80 --name myapp myasp