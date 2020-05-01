# --------------------------------
# ****** SSL CERT RESOURCES ******
# --------------------------------

# TODO: Refactor to use state files for KV references...  

resource "null_resource" "sslcert-issue" {
  provisioner "local-exec" {
    command = "./sslcerts-issue.sh '${var.subscription_id}' '${var.client_id}' '${var.client_secret}' '${var.tenant_id}'"
  }
}

# Save cert to dev, test and prod KVs
# TODO: Currently have on_failure="continue" set as we don't want terraform to fail if only production active for example.

resource "null_resource" "sslcert-save-dev" {
  # Save cert to Key Vault
  # Save cert to Key Vault
  provisioner "local-exec" {
    command    = "./sslcerts-save.sh '${var.subscription_id}' '${var.client_id}' '${var.client_secret}' '${var.tenant_id}' '${var.kv_name_dev}'"
    on_failure = continue
  }

  depends_on = [null_resource.sslcert-issue]
}

resource "null_resource" "sslcert-save-test" {
  # Save cert to Key Vault
  # Save cert to Key Vault
  provisioner "local-exec" {
    command    = "./sslcerts-save.sh '${var.subscription_id}' '${var.client_id}' '${var.client_secret}' '${var.tenant_id}' '${var.kv_name_test}'"
    on_failure = continue
  }

  depends_on = [null_resource.sslcert-issue]
}

resource "null_resource" "sslcert-save-prod" {
  # Save cert to Key Vault
  # Save cert to Key Vault
  provisioner "local-exec" {
    command    = "./sslcerts-save.sh '${var.subscription_id}' '${var.client_id}' '${var.client_secret}' '${var.tenant_id}' '${var.kv_name_prod}'"
    on_failure = continue
  }

  depends_on = [null_resource.sslcert-issue]
}

