# Enpos Terraform Repository

**Quick start**
1. Clone the repository
```bash
git clone https://gitlab.enpos.fr/enpos/admin/terraform/proxmox terraform
cd terraform
```
If you have already cloned the repository, you can pull the latest changes
```bash
git pull origin main
```
2. Edit the following files with correct data
- `locals.tf`
- `providers.tf`
- `versions.tf`

3. Create virtual_machines.yaml
```bash
cp virtual_machines.yaml.sample virtual_machines.yaml
```
Edit the file with desired vms.

4. Apply changes
```bash
export VAULT_TOKEN=<TERRAFORM-VAULT-TOKEN> # Stored in Bitwarden
```
Get THe Gitlab Access Token stored in vault (should output something like `glpat-XX...`)
```bash
export GITLAB_ACCESS_TOKEN=$(vault kv get -field gitlab_access_token -address https://vault.network.lan kv/terraform)
echo ${GITLAB_ACCESS_TOKEN:0:8}...
```

If running for the first time...
```bash
terraform init -backend-config="password=$GITLAB_ACCESS_TOKEN"
```

Before applying the changes, check them
```bash
terraform plan
```

After verifying the changes, you can apply them
```bash
terraform apply
```

**Setting up the Terraform token on Vault/OpenBao**

```bash
export VAULT_TOKEN=s.yourtoken
export VAULT_ADDR=https://vault.network.lan
vault login s.yourtoken
vault policy write terraform terraform-policy.hcl
vault token create -policy="terraform" -ttl=8760
```