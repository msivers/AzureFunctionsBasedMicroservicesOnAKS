# Deploy Azure Functions (microservices) on AKS

Here you will find complete set of terraform scripts (and increasingly Azure Pipelines yaml) for deploying ACR, Key Vault, Cosmos DB (Graph), Application Gateway and an AKS Cluster utilising AGIC (Application Gateway Ingress Controller) and Container Insights.

You will also find an well written Azure Functions 3 (.NET Core 3.1) micro-service (User Service) with Helm Chart which is deployed via YAML.

![Architecture](https://github.com/msivers/AzureFunctionsBasedMicroservicesOnAKS/raw/master/resources/archdiagram1.png)
