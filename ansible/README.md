# Ansible

Provision Web
```
ansible-playbook -i stack/hosts stack/web.yml
```

Provision db
```
ansible-playbook -i stack/hosts stack/db.yml
```

## Vault

Encrypt
```
ansible-vault encrypt stack/group_vars/all/vault.yml
```

Decrypt
```
ansible-vault decrypt stack/group_vars/all/vault.yml
```