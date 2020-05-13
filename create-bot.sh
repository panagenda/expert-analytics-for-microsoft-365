#!/bin/bash
# This script deploys an Azure Bot application
# Example: ./create-bot.sh "expertanalytics-rg" "westeurope" "my-oe.my-domain.com"
set -e

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo "usage: ./create-bot.sh <resource-group> <location> <hostname>"
    exit
fi

# customer specifc configuration
resourceGroup=$1
location=$2
endpoint="https://$3:4443/bot/messages"

# fixed configuration
pricingTier=S1
name="expertanalytics-bot-$RANDOM$RANDOM"
displayName="EA Bot"
iconUrl="http://help.binarytree.com/powerba-officepro/content/additional%20content/bt_powerba_bot_icons_orange%20192x192.png"

# create app
appId=$(az ad app create --display-name $name --available-to-other-tenants 2>/dev/null | python3 -c "import sys, json; print(json.load(sys.stdin)['appId'])")

# create bot
az bot create --appid "$appId" --kind registration --name "$name" --resource-group "$resourceGroup" --display-name "$displayName" --endpoint "$endpoint" --location "$location" --sku "$pricingTier"

# set icon url (can't be done with create command)
az bot update --name "$name" --resource-group "$resourceGroup" --icon-url $iconUrl

az bot msteams create --name "$name" --resource-group "$resourceGroup"
