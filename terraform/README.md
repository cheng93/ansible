Note I think we use .vault_pass as secrets

Decrypt
```
ansible-vault decrypt azure/secrets.tfvars --vault-password-file .vault_pass
```
Encrypt
```
ansible-vault encrypt azure/secrets.tfvars --vault-password-file .vault_pass
```

Navigate to azure directory

```
terraform plan -var-file="secrets.tfvars"     
```

```
terraform apply -var-file="secrets.tfvars"  
```