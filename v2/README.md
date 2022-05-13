### Configure Vault
```sh
ssh -i ssh-key.pem ubuntu@$(terraform output vault_ip)
./install_vault.sh
export VAULT_ADDR=http://127.0.0.1:8200
vault operator init -key-threshold=1 -key-shares=1 > init.txt
vault operator unseal Y5DFoXb4NTROWucXrlmcfmP9vPe+ut1sLMV0XizGmeg=
exit
```

### Install Vault on workstation
```sh
wget https://releases.hashicorp.com/vault/1.10.3/vault_1.10.3_linux_amd64.zip
unzip -j vault_*_linux_amd64.zip -d /usr/local/bin
export VAULT_TOKEN=hvs.pybA8A1zp5kMgDhud0wPR8jX
export VAULT_ADDR=http://54.203.106.170:8200
```

### Define AWS region
```sh
export AWS_DEFAULT_REGION=us-west-2
```

### Install awscli
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Install kubectl
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Install Helm
```sh
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

### Remove files
```sh
rm awscliv2.zip get_helm.sh vault_*_linux_amd64.zip
```

### Configure kubectl
```sh
export EKS_CLUSTER=k8squickstart-cluster
aws eks --region ${AWS_DEFAULT_REGION} update-kubeconfig --name ${EKS_CLUSTER}
```

### Test K8s cluster
```sh
kubectl get po -A
```

### Install Vault Agent on EKS
```sh
helm repo add hashicorp https://helm.releases.hashicorp.com && helm repo update
cat > values.yaml << EOF
injector:
   enabled: true
   externalVaultAddr: "${VAULT_ADDR}"
EOF
more values.yaml
helm install vault -f values.yaml hashicorp/vault --version "0.19.0"
```

### Check `vault-agent-injector-*` pod for `RUNNING` status
```sh
kubectl get po
```

### Configure Kubernetes Auth Method on Vault
```sh
vault auth enable kubernetes
export TOKEN_REVIEW_JWT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.token }' | base64 --decode)
export KUBE_CA_CERT=$(kubectl get secret \
   $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
   -o jsonpath='{ .data.ca\.crt }' | base64 --decode)
export KUBE_HOST=$(kubectl config view --raw --minify --flatten \
   -o jsonpath='{.clusters[].cluster.server}')
vault write auth/kubernetes/config \
   token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
   kubernetes_host="$KUBE_HOST" \
   kubernetes_ca_cert="$KUBE_CA_CERT"
```

### Deploy example workload with Postgres database
```sh
git clone https://github.com/hashicorp/vault-guides.git
cd vault-guides/cloud/eks-hcp-vault/
```

### Deploy Postgres database and check for `RUNNING` status
```sh
kubectl apply -f postgres.yaml
kubectl get po
```

### Add database role to Vault
```sh
vault secrets enable database
export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' \
   postgres)
vault write database/config/products \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@${POSTGRES_IP}:5432/products?sslmode=disable" \
    username="postgres" \
    password="password"
vault write database/roles/product \
    db_name=products \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;"\
    default_ttl="10s" \
    max_ttl="30s"
```
If this fails with an error that looks like `* error creating database object: error verifying connection: dial tcp: lookup a986ca57f20914c29b53f61ff0b7d960-2128898780.us-west-2.elb.amazonaws.com on 127.0.0.53:53: no such host`, check the EKS security group and open all inbound traffic from anywhere.

### Test generating dynamic credentials
```sh
vault read database/creds/product
```

### Edit `product.yaml`
```sh
vim product.yaml
# remove line 39 or the annotation that mentions the namespace `vault.hashicorp.com/namespace: "admin"`
```

### Deploy `product` pod and check for `RUNNING` status
```sh
kubectl apply -f product.yaml
kubectl get po
```