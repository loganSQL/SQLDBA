#
#	Steps to create and test a IIS container image
#	https://hub.docker.com/r/microsoft/iis/
# Docker_IIS.psd1
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
#	then change to http://$ip:8000
$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" Myiis
Start-Process -FilePath http://$ip

# HOW TO TRANSFER YOUR FILE INTO YOUR DOCKER FOR YOUR WINDOWS CONTAINERS
#
# Technique 1: Edit in the Container
# connect to container view cmd
# go to the c:\Myiis folder
# create a test page
docker exec -i Myiis cmd
dir
cd Myiis
echo "Hello World From a Windows Server IIS Container" > C:\Myiis\index.html
exit

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
$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" datatest1
Start-Process -FilePath http://$ip

# IE: http://172.20.44.18:8000/
# check the page from IE

# housekeep
docker stop Myiis
docker rm Myiis