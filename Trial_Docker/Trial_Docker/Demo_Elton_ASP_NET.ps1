# Demo from Elton’s NDC talk
# Demo_Elton_ASP_NET.ps1
#
# http://markheath.net/post/get-up-and-running-with-docker-for-windows
#

# 
C:\logan\test\ndc
git clone https://github.com/sixeyed/ndc-london-2017
cd  src\docker
notepad docker-compose.yml
# change verson to 2.1
<#
version: '2.1'

services:
  
  product-launch-db:
    image: microsoft/mssql-server-windows-express
    ports:
      - "1433:1433"
    environment: 
      - ACCEPT_EULA=Y
      - sa_password=NDC_l0nd0n
    networks:
      - app-net

  message-queue:
    image: sixeyed/nats:windowsservercore
    ports:
      - "4222:4222"
    networks:
      - app-net

  elasticsearch:
    image: sixeyed/elasticsearch:windowsservercore
    ports:
      - "9200:9200"
    networks:
      - app-net

  kibana:
    image: sixeyed/kibana:windowsservercore
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    networks:
      - app-net

  homepage:
    image: sixeyed/product-launch-homepage:v5
    ports:
      - "81:80"
    networks:
      - app-net

  product-launch-web:
    image: sixeyed/product-launch-web:v5
    ports:
      - "80:80"
    environment:
      - DB_CONNECTION_STRING=Server=product-launch-db;Database=ProductLaunch;User Id=sa;Password=NDC_l0nd0n;
      - HOMEPAGE_URL=http://homepage
    depends_on:
      - homepage
      - product-launch-db
      - message-queue
    networks:
      - app-net

  save-prospect-handler:
    image: sixeyed/product-launch-save-handler:v5
    environment:
      - DB_CONNECTION_STRING=Server=product-launch-db;Database=ProductLaunch;User Id=sa;Password=NDC_l0nd0n;
    depends_on:
      - product-launch-db
      - message-queue
    networks:
      - app-net

  index-prospect-handler:
    image: sixeyed/product-launch-index-handler:v5
    depends_on:
      - elasticsearch
      - message-queue
    networks:
      - app-net

networks:
  app-net:
    external:
      name: nat
#>
docker-compose up -d
# it will pull all the necessary Docker images to run this app
# starts all eight Docker containers required for this application (they’re all Windows containers), 
# and connects them together in a network so they can communicate with each other.
docker ps

# Test
$ip = docker inspect -f "{{.NetworkSettings.Networks.nat.IPAddress}}" docker_product-launch-web_1
Start-Process -FilePath http://$ip

# the launch page is pulled from a second container running a webserver on another port. 
#If we can manage to click on the “Register here for updates” link while it’s visible, 
#we get to enter our details into a form, which posts a message onto a queue

# There are two listeners on the NATS queue (or “subject”), 
# one which writes a row into a table in our SQL Server Express container, 
# and one which writes a document to elasticsearch.

# check sql
docker exec -it docker_product-launch-db_1 sqlcmd -U sa -P NDC_l0nd0n -Q "USE ProductLaunch; SELECT * FROM Prospects"

# check elasticsearch at Port 5601
$ip = docker inspect -f '{{.NetworkSettings.Networks.nat.IPAddress}}' docker_kibana_1
$ip=$ip+':5601'
Start-Process -FilePath http://$ip

# To stop all containers
docker stop $(docker ps -aq)