# --------------------------------
# ****** SSL CERT RESOURCES ******
# --------------------------------

resource "null_resource" "sslcert-issue-save" {
  # Changes to any key vault id requires re-provisioning
  triggers = {
    timestamp = var.timestamp
  }

  provisioner "local-exec" {
    command = "./sslcerts-issue-save.sh '${var.subscription_id}' '${var.client_id}' '${var.client_secret}' '${var.tenant_id}' '${azurerm_key_vault.core.name}' '${var.hostname}'"
  }

  depends_on = [azurerm_key_vault_access_policy.core]
}