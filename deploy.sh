#!/usr/bin/env bash

# Creates the resource group that will contain all of our application resources
az group create --name "${RGNAME}" --location "${RGLOCATION}"

# Creates the SQL Database Server and Database with the provided admin details
# This is not created in the ARM template below because it's assumed that the lifecycle
# of this SQL Database is longer than that of this web application
az sql server create -l "${RGLOCATION}" -g ${RGNAME} -n ${SQLSERVERNAME}  -u ${SQLADMINUSER} -p ${SQLADMINPASSWORD}
az sql db create -s ${SQLSERVERNAME} -n ${SQLSERVERDB} -g ${RGNAME}

# Set the firewall to allow ALL connections (This would actually be set to just your web app)
az sql server firewall-rule create -g $RGNAME -s $SQLSERVERNAME  -n azureservices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Populate the schema in the database (This would normally be handled via your DB Schema management solution)
connstring=`az sql db show-connection-string --server $SQLSERVERNAME --name $SQLSERVERDB --client ado.net`
connstring=$(echo ${connstring} | sed "s/<username>/${SQLADMINUSER}/g")
connstring=$(echo ${connstring} | sed "s/<password>/${SQLADMINPASSWORD}/g")
sqlcon="${connstring%\"}"
sqlcon="${sqlcon#\"}"
sqlcmd -S tcp:${SQLSERVERNAME}.database.windows.net,1433 -d ${SQLSERVERDB} -U ${SQLADMINUSER} -P ${SQLADMINPASSWORD} -N -l 30 -Q "CREATE TABLE Counts(ID INT NOT NULL IDENTITY PRIMARY KEY, Candidate VARCHAR(32) NOT NULL, Count INT)"

# Deploy those resources found in the ARM template - This deploys the bulk of the resources.
az deployment group create --resource-group ${RGNAME} --template-uri ${DEPLOYMENT}webappdeploy.json --parameters VotingWeb_name=${DNSNAME} SqlConnectionString="$sqlcon"

# Deploy those resources found in the bicep template - This deploys the bulk of the resources.
#az deployment group create --resource-group ${RGNAME} --template-uri ${DEPLOYMENT}webappdeploy.bicep --parameters VotingWeb_name=${DNSNAME} SqlConnectionString="$sqlcon"

# Create the CosmosDB Database and Container
# This could have been deployed as part of the ARM template above, but we opted to show AZ CLI usage here instead.
cosmosacc=`az cosmosdb list -g ${RGNAME} | jq -r .[0].name`
az cosmosdb sql database create -a ${cosmosacc} -g ${RGNAME} -n cacheDB
az cosmosdb sql container create -a ${cosmosacc} -g ${RGNAME} -d cacheDB -p '/MessageType' -n cacheContainer