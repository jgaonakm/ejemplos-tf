provider "linode" {}

# Seleccionar la imagen más reciente de Ubuntu
# Ref. https://registry.terraform.io/providers/linode/linode/latest/docs/data-sources/images#filter
data "linode_images" "ubuntu" {
  filter {
    name   = "vendor"
    values = ["Ubuntu"]
  }

  filter {
    name   = "is_public"
    values = ["true"]
  }

  latest = true
}

variable "tags" {
  type        = list(string)
  description = "Tags para la instancia"
  default     = ["web_server_tf"]
}

# Crear una variable local para almacenar el script a ejecutar con cloud-init
# Ref. https://www.linode.com/docs/products/compute/compute-instances/guides/metadata/?tabs=linode-cli%2Cmacos#add-user-data
locals {
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "<marquee><h1>Akamai Connected Cloud</h1></marquee>" > /var/www/html/index.html
              systemctl restart apache2
              EOF
}

# Crear el servidor web
resource "linode_instance" "web_server" {
  region = "us-lax"
  label  = "web_server_tf"
  tags = var.tags
  image  = data.linode_images.ubuntu.images.0.id
  type   = "g6-nanode-1"
  metadata {
    user_data = base64encode(local.user_data)
  }
}

output "ip" {
  value = "Visita http://${linode_instance.web_server.ip_address}:8080"
}
