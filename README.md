# OAuth-Proxy Setup
Secure any service in a Gardener cluster with an OAuth2 proxy in under two minutes, without modifying the service's code. This setup utilizes OAuth2-Proxy from oauth2-proxy/oauth2-proxy to simplify and streamline the deployment process.

## Why OAuth-Proxy?
Deploying an OAuth2 proxy can be complex and time-consuming. This suite of scripts makes it easy to deploy an OAuth2 proxy for any service in a Gardener cluster, handling the intricacies of configuration and deployment for you.


[Oauth2proxy](..) gives you that, but as much as it sound easy to configure  i got into trubles with configurations noches, so i created this script to make it easy to create an oauth2 proxy for a given service in a gardener cluster.


# Available scripts
## Main Script
*run.sh:* Automates the deployment of your application and the OAuth2 proxy. It sets up the environment, authenticates with the Kubernetes cluster, exports the kubeconfig, and executes necessary scripts.

Usage 

```bash
./run.sh <project_name> <cluster_name>
```

*Note:* This script obviates the need for manual script execution, automating your setup process.

# Script Details

## Kube Authentication
 *auth.sh:* Utilizes gardenctl for Gardener authentication and retrieves the kubeconfig. If using a non-Gardener cluster, log in with kubectl and optionally bypass this step.
``` 
./auth.sh <cluster_identity> <project_name> <cluster_name>
```
  
## Ingress Controller Deployment
*ingress.sh:* Creates an ingress resource. 

```bash
./ingress.sh <cluster_domain>
```
Can use environment variables instead of parameters

```bash
export FDQM=my.cluster.domain
````

## Test Application Deployment 
*app.sh:* Deploys an application. Supports environment variables for specifying domain, service name, and image. 
you can skip this step if you already have a service running in your cluster, but recommend to use it to deploy a test service and only then apply to your service. 
```bash
./app.sh my.cluster.domain httpbin IMAGE-kennethreitz/httpbin:latest
```

## OAuth2 Proxy Deployment
*proxy.sh:* Deploys the OAuth2 proxy. 
```bash
./proxy.sh <cluster_domain> <iss_url> <client_id> <client_secret>
```
Can use environment variables instead of parameters
``
export FDQM=my.cluster.domain
export OAUTH2_PROXY_ISS=idp.example.com
export OAUTH2_PROXY_CLIENT_ID=cid
export OAUTH2_PROXY_CLIENT_SECRET=secret
``

> You can run with default iss values and change the values later.

## Ingress Authorization
*protect.sh:* Modifies the ingress to protect your application with the OAuth2 proxy, offering both parameter and environment variable inputs.


```bash
./protect.sh my.cluster.domain httpbin

```

> The scripts are designed to be run on a system with kubectl and python3 installed, and they assume that the Kubernetes cluster is already up and running. They also assume that you have the necessary permissions to create and modify resources on the cluster.



## Utility Scripts
./chm.sh: Ensures all scripts are executable.
./browser.sh: Opens a specified URL in a browser.
./fqdn.sh: Retrieves the current FQDN.


## Prerequisites
Ensure kubectl and gardenctl are installed on your system for authentication and cluster management. The setup assumes an operational Kubernetes cluster and the necessary permissions to modify cluster resources.

You can skip gardenctl if you are using a non-Gardener cluster, but you will need to log in with kubectl.



