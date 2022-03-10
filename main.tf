variable "vault_token" {}
variable "vault_addr" {}

variable "db_username" {
  default = "myuser"
}

provider "random" {}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

# Initializing kvv2 mount
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv-v2"
  description = "This is an example engine."
}

# Initializing random password
resource "random_password" "db_password" {
  # The length here is set to 16 for AWS ElastiCache requirement
  # adjust appropriately for target system
  length  = 16
  special = true
}

# Creating secret
resource "vault_generic_secret" "dbsecret" {
  path = "${vault_mount.kvv2.path}/dbsecret"

  data_json = jsonencode({
    "user"     = var.db_username,
    "password" = random_password.db_password.result
  })
}

# Fetching generated data (to be used downstream)
data "vault_generic_secret" "dbsecret" {
  path = vault_generic_secret.dbsecret.path
}

# Possible example for elasticache user
# resource "aws_elasticache_user" "myuser" {
#   user_id       = var.db_username
#   user_name     = var.db_username
#   access_string = "on ~mydb::* -@all +@read"
#   engine        = "REDIS"
#   passwords = [
#     random_password.db_password.result
#   ]
# }

########################################################
### WARNING WARNING WARNING WARNING WARNING WARNING  ###
### DO NOT DO THIS. This is for an example only      ###
### In actual production code the outputs would be   ###
### marked sensitive (sensitive = true) to be passed ###
### to downstream consumers.                         ###
########################################################
output "secret_output_user" {
  value = nonsensitive(data.vault_generic_secret.dbsecret.data["user"])
}

output "secret_output_password" {
  value = nonsensitive(data.vault_generic_secret.dbsecret.data["password"])
}
########################################################
### WARNING WARNING WARNING WARNING WARNING WARNING  ###
### DO NOT DO THIS. This is for an example only      ###
### In actual production code the outputs would be   ###
### marked sensitive (sensitive = true) to be passed ###
### to downstream consumers.                         ###
########################################################
