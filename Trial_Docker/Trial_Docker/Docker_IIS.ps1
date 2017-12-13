#
#	Steps to create and test a IIS container image and ways to transfer files into containers
#	https://hub.docker.com/r/microsoft/iis/
#	Docker_IIS.ps1
#

# 1. create a Dockerfile with following info
# -- Download and Pull docker images from Microsoft
# -- create a directory c:\Myiis
# -- start a site named Myiis 
# -- expose port
# -- if you want to put the pages
# -- COPY ./testpage.html
 /Myiis
Dockerfile

FROM microsoft/iis

RUN mkdir C:\Myiis

RUN powershell -NoProfile -Command \
    Import-module IISAdministration; \
    New-IISSite -Name "Myiis" -PhysicalPath C:\Myiis -BindingInformation "*:8000:"

EXPOSE 8000

# build and run the Docker image:

docker build -t iis-site .
docker run -d -p 8000:8000 --name Myiis iis-site

# check
docker images
docker ps
docker ps -a

# check ip of IIS website
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" Myiis


#
#	get an IIS container running, discover it’s IP address, and launch it in a browser
#	then change to http://$ip:8000 to get error because of no web page yet
#	This will start the browser with the default page on C:\inetpub\wwwroot\iisstart.htm

$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" Myiis
Start-Process -FilePath http://$ip

$ip = $ip+':8000'
Start-Process -FilePath http://$ip

# HOW TO TRANSFER YOUR FILE INTO YOUR DOCKER FOR YOUR WINDOWS CONTAINERS
#
# Technique 1: Edit in the Container
# connect to container view cmd / powershell
# go to the c:\Myiis folder
# create a test page, change http://$ip:8000
docker exec -i Myiis cmd
dir

cd Myiis
echo "Hello World From a Windows Server IIS Container" > C:\Myiis\index.html
exit
# 
docker exec -it Myiis powershell
echo "<html><body><h1>Hello World</h1></body></html>" > "C:\Myiis\index.html"
exit

# Technique 2: Copy into a Container
# use the docker cp command. 
# This allows you to copy files locally into a container. 
# But the container needs to stop
# 
docker stop Myiis
docker cp index.html Myiis:c:\Myiis
docker start Myiis

# If instead of copying a single file, we want to copy the contents of a whole local folder called 'site' into 'wwwroot', 
# then I couldn’t find the right syntax to do this directly with docker cp, 
# so I ended up changing local directory before performing the copy:
docker stop Myiis
push-location ./site
docker cp . Myiis:c:/inetpub/wwwroot
pop-location
docker start Myiis
$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" Myiis
Start-Process -FilePath http://$ip

# Technique 3: Mount a Volume
# Rather than transferring our data into the container, we can make a folder on our local machine visible inside the container by mounting a volume.
# We do this with the –v switch on the docker run command, specifying the local folder we want to mount, and the location in which it should appear on the container.
#
# First of all, the local path needs to be absolute, not relative, so I’m using Get-Location to get the current directory. 
# And secondly, you can’t mount a volume on top of an existing folder (at least in Docker for Windows). 
# So we sadly can’t overwrite wwwroot using this technique. But we could mount into a subfolder under wwwroot like this:
docker run -d -p 80 -v "$((Get-Location).Path)\site:c:\inetpub\wwwroot\site" --name Myiis iis-site

# Now the great thing is that we can simply modify our local HTML and refresh the browser and our changes are immediately visible.
$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" Myiis
Start-Process -FilePath http://$ip/site

# Technique 4: Use a Dockerfile
# All this dockerfile is saying is that our base image is the Microsoft IIS nanoserver image from DockerHub, 
# and then we want to copy the contents of our local 'site' directory into 'C:/inetpub/wwwroot'
# Dockerfile
FROM microsoft/iis:nanoserver
COPY site C:/inetpub/wwwroot

# With our dockerfile in place, we need to build an image with the docker build command
docker build -t Myiis:v1 .
docker run -d -p 80 --name Myiis Myiis:v1
$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" Myiis
Start-Process -FilePath http://$ip


# housekeep
docker stop Myiis
docker rm Myiis