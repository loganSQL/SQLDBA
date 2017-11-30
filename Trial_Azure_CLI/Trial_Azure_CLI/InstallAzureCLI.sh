#!/bin/bash

<# 
Install Azure CLI 2.0
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
#>

# Install WSL first (bash)
# on Bash shell
# Modify sources list

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
     sudo tee /etc/apt/sources.list.d/azure-cli.list


# Run the following sudo
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

# Run the CLI from the command prompt with the az command.

