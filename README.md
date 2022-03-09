# Short terraform example of managing credentials with kvv2

This is a very short example of generating a random password, storing the password in vault, and then using that password with a service downstream.

**This code is for example purposes only and does not adhere to production ready usage**

## Goals

Our goal is to generate a password using the `random` provider that we can use with downstream modules and systems.

## Managing random passwords

```
resource "random_password" "db_password" {
  length  = 12
  special = true
}
```

Once the password is generated it is used to create a user resource (such as Redis or SQL) and then stored in Vault. Downstream terraform modules can use the outputs. Applications running in the environment can access Vault directly for the newly generated password.

Rotation of password (creating a new password) can be accomplished by leveraging the `taint` command in terraform. This tells terraform to regenerate a new resource.

Example:
```
$ terraform apply
random_password.db_password: Refreshing state... [id=none]
vault_mount.kvv2: Refreshing state... [id=secret]
vault_generic_secret.dbsecret: Refreshing state... [id=secret/dbsecret]

<cut for brevity>

Outputs:

secret_output_password = "fa&2OZ1s0Ylc"
secret_output_user = "myuser"

$ terraform taint random_password.db_password
Resource instance random_password.db_password has been marked as tainted.

$ terraform apply
random_password.db_password: Refreshing state... [id=none]
vault_mount.kvv2: Refreshing state... [id=secret]
vault_generic_secret.dbsecret: Refreshing state... [id=secret/dbsecret]

<cut for brevity>

Changes to Outputs:
  ~ secret_output_password = "fa&2OZ1s0Ylc" -> (known after apply)
  ~ secret_output_user     = "myuser" -> (known after apply)

<cut for brevity>

Apply complete! Resources: 1 added, 1 changed, 1 destroyed.

Outputs:

secret_output_password = "Lvk(z47K{s@G"
secret_output_user = "myuser"
```

