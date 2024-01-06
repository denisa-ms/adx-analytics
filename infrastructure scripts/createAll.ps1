# Connect-AzAccount
$SubscriptionId = 'ec967cb5-f2b0-43c2-9ba2-4a2eb94bbacc'
$resourceGroupName = "adxanalytics-rg"
$location = "westeurope"


# Set subscription 
Set-AzContext -SubscriptionId $subscriptionId 
# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile deployAll.bicep -WarningAction:SilentlyContinue
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\ADF_pipeline2.json -WarningAction:SilentlyContinue
