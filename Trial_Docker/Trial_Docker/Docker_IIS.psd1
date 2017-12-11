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

# connect to container view cmd
# go to the c:\Myiis folder
# create a test page
docker exec -i Myiis cmd
dir
cd Myiis
echo "Hello World From a Windows Server Container" > C:\Myiis\index.html


# IE: http://172.20.44.18:8000/
# check the page from IE


