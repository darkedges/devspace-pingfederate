# Devspace for Ping Federate

This currently deploys

- Ping Directory
  - `instance`
  - `console`
- Ping Federate
  - `console`
  - `engine`
- Hashicorp Vault
- cert-manager
- ingress nginx

HashiCorp Vault is used to issue certificates for the web front ends as well as being deployed into a JKS for use by the directory.

All configuration is stored within the [values](values) directory

Requires

- [kubernetes](https://kubernetes.io/)
- [docker](https://www.docker.com/)
- [Helm](https://helm.sh/)
- [HashiCorp Terraform](https://www.terraform.io/)

## Passwords

| App                        | URL                                                 | Username               | Password   |
| -------------------------- | --------------------------------------------------- | ---------------------- | ---------- |
| Ping Directory -cconsole   | <https://pingdirectory.internal.darkedges.com>      |                        |            |
| Ping Directory - directory | `pingdirectory-directory-0.pingdirectory-directory` | `cn=Directory Manager` | `Passw0rd` |
| Ping Federate - console    | <https://pingfederate.internal.darkedges.com>       | `administrator`        | `Passw0rd` |
| Ping Federate - engine     | <https://pingauth.internal.darkedges.com>           |                        |            |
| HashiCorp Vault            | <https://vault.internal.darkedges.com>              |                        | `root`     |

## Build Images

```bash
docker-compose build jre
docker-compose build tomcat
docker-compose build genjks
docker-compose build pingdirectory_base
docker-compose build pingdirectoryconsole
docker-compose build pingfederate_base
docker-compose build pingdirectory
docker-compose build pingfederate
```

## Helm

```bash
cd helm/coreservices
helm dependency update
cd ../..
helm install --namespace=pingfederate --create-namespace -f coreservices.yaml coreservices helm/coreservices

cd terraform/terraform-vault-ca
terraform init
$ISSUER_CORE_SERVICE = "coreservices"
$nodeport = kubectl get svc $ISSUER_CORE_SERVICE-vault-ui -o=jsonpath='{.spec.ports[?(@.port==8200)].nodePort}'
$env:VAULT_ADDR="http://localhost:$nodeport"
$env:VAULT_TOKEN ="root"
terraform plan -var-file=values/terraform.tfvars
terraform apply -var-file=values/terraform.tfvars --auto-approve

cd ../..
$ISSUER_SECRET_REF = kubectl get serviceaccount coreservices-certmanager -o=jsonpath='{.secrets[].name}'
$ISSUER_NAMESPACE = "pingfederate"
echo @"
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: certmanager-binding
  namespace: $ISSUER_NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: coreservices-certmanager
  namespace: $ISSUER_NAMESPACE
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: $ISSUER_NAMESPACE
spec:
  vault:
    path: ${ISSUER_NAMESPACE}_idam_intermediate/sign/${ISSUER_NAMESPACE}_idam
    server: http://$ISSUER_CORE_SERVICE-vault:8200
    auth:
      kubernetes:
        role: certmanager
        mountPath: /v1/auth/kubernetes
        secretRef:
          name: $ISSUER_SECRET_REF
          key: token
"@ > $env:temp\issuer.yaml
kubectl apply -f $env:temp\issuer.yaml
rm $env:temp\issuer.yaml

helm upgrade --namespace=pingfederate --create-namespace -f values/coreservices.yaml -f values/coreservices-upgrade.yaml coreservices helm/coreservices

helm install --namespace=pingfederate --create-namespace -f values/pingdirectory.yaml pingdirectory helm/pingdirectory
helm install --namespace=pingfederate --create-namespace -f values/pingfederate.yaml pingfederate helm/pingfederate
```
