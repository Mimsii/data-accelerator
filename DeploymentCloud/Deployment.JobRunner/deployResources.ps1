#
#  DeployResources Deploy Script
#
#  This script deploys all the resources to an azure subscription and resource group that are required for the scenario tester job runner.
#  This asumes that the target subscription contains a data-accelerator environment already deployed and a keyvault already initialized.
#  This script takes the values from the data-accelerator environment keyvault to initialize the new resources used by scenario tester.
#  This script also requires that an application id and secret are already created from a registered app, and that registered app is already onboarded
#  to the Gateway Service. Finally, you can skip certificate validation in case it is required for your test client run cases.
#
#  Output: Scenario tester is deployed into an existing data-accelerator environment
#
param(
    # Tenant id where data-accelerator environment is deployed
    [string]
    $tenantId,
    # Subscription id where data-accelerator environment is deployed
    [string]
    $subscriptionId,
    # Resource Group name where data-accelerator environment is deployed
    [string]
    $resourceGroupName,
    # Application id that job runner is going to run in behalf of
    [string]
    $applicationId,
    # Application secret for the target application id
    [string]
    $appSecretKey,
    # Prefix chosen for deployed secrets of data-accelerator main keyvault
    [string]
    $kvBaseNamePrefix='configgen',
    # Name for scenario test flow
    [string]
    $flowName='scenariotest',
    # Skip server certificate validation (TLS check from client side)
    [string]
    $skipServerCertificateValidation='false'
)
Import-Module ./utilities.psm1

$ErrorActionPreference = "stop"

Push-Location $PSScriptRoot

$scenarioTestKVBaseName = $flowName

$jobRunnerBasePath = $PSScriptRoot
$resourcesPath = $jobRunnerBasePath + "\Resources"
$templatesPath = $resourcesPath + "\Templates"
$parametersPath = $resourcesPath + "\Parameters"
$jobRunnerTemplateFile = $templatesPath + "\jobRunner-Template.json"
$jobRunnerParameterFile = $parametersPath + "\JobRunner-Parameter.json"

Write-Host "Template json path: $jobRunnerTemplateFile"

Write-Host -ForegroundColor Green "Total estimated time to complete: 10 minutes"

$login = Login -subscriptionId $subscriptionId -tenantId $tenantId
$tenantName = $login.tenantName

$appAccInfo = Get-AppInfo -applicationId $applicationId -tenantName $tenantName

$stInfo = Get-ScenarioTesterInfo `
    -subscriptionId $subscriptionId `
    -resourceGroupName $resourceGroupName `
    -flowName $flowName `
    -scenarioTestKVBaseName $scenarioTestKVBaseName

$kvInfo = Get-KVKeyInfo -baseNamePrefix $kvBaseNamePrefix

$params = @{
    tenantId = $tenantId
    productName = $stInfo.productName
    applicationObjectId = $appAccInfo.objectId
    applicationId = $appAccInfo.applicationId
    applicationIdentifierUri = $appAccInfo.identifierUri
    authorityUri = $appAccInfo.authorityUri
    serviceUrl = $stInfo.serviceUrl
    secretKey = $appSecretKey
    kvServicesName = $stInfo.kvServicesName
    kvSparkName = $stInfo.kvSparkName
    blobUri = $stInfo.blobUri
    sparkStorageAccountName = $stInfo.sparkStorageAccountName
    eventHubName = $stInfo.eventHubName 
    eventHubConnectionString = $stInfo.eventHubConnectionString
    isIotHub = $stInfo.isIotHub
    jobRunnerName = $stInfo.jobRunnerName
    databricksToken = $stInfo.databricksToken
    referenceDataUri = $stInfo.referenceDataUri
    udfSampleUri = $stInfo.udfSampleUri
    skipServerCertificateValidation = $skipServerCertificateValidation
    eventHubConnectionStringKVName = $stInfo.eventHubConnectionStringKVName
    referenceDataKVName = $stInfo.referenceDataKVName
    udfSampleKVName = $stInfo.udfSampleKVName
    databricksTokenKVName = $stInfo.databricksTokenKVName
    secretKeyKVName = $kvInfo.secretKeyKVName
    clientIdKVName = $kvInfo.clientIdKVName
    testClientId = $kvInfo.testClientId
}

$templateName = $flowName

New-AzureRmResourceGroupDeployment `
-Name "deployment-$templateName-$(get-date -f MM-dd-yyyy_HH_mm_ss)" `
-ResourceGroupName $resourceGroupName `
-TemplateFile $jobRunnerTemplateFile `
-TemplateParameterObject $params `
-Verbose `
-ErrorAction stop