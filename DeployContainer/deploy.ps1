az login

$dContainer = "deploy-container"
$dRegistry ="dragandanga"
# build image and push to Azure Container Registry
docker build -f DeployContainer\Dockerfile  --force-rm -t $dContainer .
docker tag $dContainer $dRegistry/$dContainer
docker push $dRegistry/$dContainer

$grp = "DeployContainer"
$loc ="westeurope"
# creating resource group
az group create --name $grp --location $loc

$environment = "deploy-container-env"
# creating environment
az containerapp env create --name $environment `
                           --resource-group $grp `
                           --internal-only false `
                           --location $loc


$contanerAppName ="deploy-container"
# creating the Container App
az containerapp create `
  --name $contanerAppName `
  --resource-group $grp `
  --environment $environment `
  --image $dRegistry/$dContainer `
  --target-port 80 `
  --ingress 'internal'

# update ingress
az containerapp ingress update --resource-group $grp --name $contanerAppName --type "external"

# let's say we change the container to new QA contianer
$dContainer ="deploy-container-qa"
# re-build image and push to Azure Container Registry
docker build -f DeployContainer\Dockerfile  --force-rm -t $dContainer .
docker tag $dContainer $dRegistry/$dContainer
docker push $dRegistry/$dContainer

# enable multiple revisions
az containerapp revision set-mode --name $contanerAppName --resource-group $grp --mode "multiple"

# update the Container App
az containerapp up `
  --name $contanerAppName `
  --resource-group $grp `
  --environment $environment `
  --image $dRegistry/$dContainer `
  --target-port 80 `
  --ingress 'external'`

# get revisions mode
az containerapp revision list --name $contanerAppName --resource-group $grp






