# PowerShell script
$randomIdentifier = (New-Guid).ToString().Substring(0, 8)
$servicePrincipalName = "imagePacker-sp"
$roleName = "Contributor"
$subscriptionID = $(az account show --query id --output tsv)
$resourceGroup = "packer-vm-rg"
echo "Creating SP for RBAC with name $servicePrincipalName, with role $roleName and in scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup"

az ad sp create-for-rbac --name $servicePrincipalName --role $roleName --scopes /subscriptions/$subscriptionID/resourceGroups/$resourceGroup