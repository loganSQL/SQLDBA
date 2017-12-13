#
# Trial_ASP_NET.ps1
# https://docs.microsoft.com/en-us/aspnet/mvc/overview/deployment/docker-aspnetmvc
# https://hub.docker.com/r/microsoft/aspnet/
# https://github.com/Microsoft/aspnet-docker

<#
ASP.NET is a high productivity framework for building Web Applications using Web Forms, MVC, Web API and SignalR.

This repository contains Dockerfile definitions for ASP.NET Docker images. These images use the IIS image as their base.

This image contains:

Windows Server Core as the base OS
	IIS 10 as Web Server
	.NET Framework (multiple versions available)
	.NET Extensibility for IIS
#>

cd C:\logan\test\aspnet-docker

notepad Dockerfile

<#################################################

FROM microsoft/dotnet-framework:4.7.1-windowsservercore-1709

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Add-WindowsFeature Web-Server; \
    Add-WindowsFeature NET-Framework-45-ASPNET; \
    Add-WindowsFeature Web-Asp-Net45; \
    Remove-Item -Recurse C:\inetpub\wwwroot\*

ADD ServiceMonitor.exe /

#download Roslyn nupkg and ngen the compiler binaries
RUN Invoke-WebRequest https://api.nuget.org/packages/microsoft.net.compilers.2.3.1.nupkg -OutFile c:\microsoft.net.compilers.2.3.1.zip ; \	
    Expand-Archive -Path c:\microsoft.net.compilers.2.3.1.zip -DestinationPath c:\RoslynCompilers ; \
    Remove-Item c:\microsoft.net.compilers.2.3.1.zip -Force ; \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe  | \
    &C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe | \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\csc.exe /ExeConfig:c:\RoslynCompilers\tools\csc.exe | \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\vbc.exe /ExeConfig:c:\RoslynCompilers\tools\vbc.exe | \
    &C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe install c:\RoslynCompilers\tools\VBCSCompiler.exe  /ExeConfig:c:\RoslynCompilers\tools\VBCSCompiler.exe ;

ENV ROSLYN_COMPILER_LOCATION c:\\RoslynCompilers\\tools

EXPOSE 80

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]

#################################################>

docker build -t aspnet-site --build-arg site_root=/ .
docker run -d -p 8000:80 --name my-running-site aspnet-site

#There is no need to specify an ENTRYPOINT in your Dockerfile since the microsoft/aspnet base image already 
#includes an entrypoint application that monitors the status of the IIS World Wide Web Publishing Service (W3SVC).