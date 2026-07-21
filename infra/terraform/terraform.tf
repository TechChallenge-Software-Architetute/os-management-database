resource "null_resource" "teste" {
  provisioner "local-exec" {
    command = "echo Terraform está funcionando!"
  }
}
