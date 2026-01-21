#
# Battlestar Ventana Network Blueprint - Firewall Automation
#
# This Terraform configuration automates firewall rule generation from
# the firewall matrix documentation using the services_to_ufw.py script.
#
# Usage:
#   terraform init
#   terraform plan
#   terraform apply
#

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Local variables for VLAN configuration
locals {
  # VLAN definitions matching the documentation
  vlans = {
    ventana = {
      id          = 10
      name        = "Ventana"
      network     = "10.76.10.0/24"
      description = "Trusted LAN"
    }
    iot = {
      id          = 20
      name        = "IoT"
      network     = "10.76.20.0/24"
      description = "IoT Devices"
    }
    guest = {
      id          = 30
      name        = "Guest"
      network     = "10.76.30.0/24"
      description = "Guest Internet"
    }
    guest_elevated = {
      id          = 31
      name        = "GuestElevated"
      network     = "10.76.31.0/24"
      description = "Elevated Guest"
    }
    infra_core = {
      id          = 40
      name        = "InfraCore"
      network     = "10.76.40.0/24"
      description = "Infrastructure"
    }
    server_vault = {
      id          = 50
      name        = "ServerVault"
      network     = "10.76.50.0/24"
      description = "Services"
    }
    printers = {
      id          = 60
      name        = "Printers"
      network     = "10.76.60.0/24"
      description = "Printers"
    }
    media = {
      id          = 70
      name        = "Media"
      network     = "10.76.70.0/24"
      description = "Media/Casting"
    }
    cameras_local = {
      id          = 81
      name        = "CamerasLocal"
      network     = "10.76.81.0/24"
      description = "Cameras Local"
    }
    cameras_cloud = {
      id          = 82
      name        = "CamerasCloud"
      network     = "10.76.82.0/24"
      description = "Cameras Cloud"
    }
    work = {
      id          = 90
      name        = "Work"
      network     = "10.76.90.0/24"
      description = "Work VLAN"
    }
  }

  # Path to the conversion script
  script_path = "${path.module}/../../scripts/services_to_ufw.py"
  docs_path   = "${path.module}/../../docs"
  
  # Output paths for generated rules
  ufw_output_path  = "${path.module}/generated/firewall-rules.sh"
  json_output_path = "${path.module}/generated/firewall-rules.json"
}

# Create output directory for generated rules
resource "null_resource" "create_output_dir" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "mkdir -p ${dirname(local.ufw_output_path)}"
  }
}

# Generate UFW firewall rules script
resource "null_resource" "generate_ufw_rules" {
  depends_on = [null_resource.create_output_dir]

  triggers = {
    # Regenerate when script or docs change
    script_hash = filemd5(local.script_path)
    services_hash = filemd5("${local.docs_path}/services.md")
    matrix_hash = filemd5("${local.docs_path}/firewall-matrix.md")
  }

  provisioner "local-exec" {
    command = "python3 ${local.script_path} --format ufw --output ${local.ufw_output_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'UFW rules generation resource destroyed'"
  }
}

# Generate JSON firewall rules for validation
resource "null_resource" "generate_json_rules" {
  depends_on = [null_resource.create_output_dir]

  triggers = {
    # Regenerate when script or docs change
    script_hash = filemd5(local.script_path)
    services_hash = filemd5("${local.docs_path}/services.md")
    matrix_hash = filemd5("${local.docs_path}/firewall-matrix.md")
  }

  provisioner "local-exec" {
    command = "python3 ${local.script_path} --format json --output ${local.json_output_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'JSON rules generation resource destroyed'"
  }
}

# Read generated JSON rules for validation
data "local_file" "generated_rules" {
  depends_on = [null_resource.generate_json_rules]
  filename   = local.json_output_path
}

# Output the VLAN configuration
output "vlan_configuration" {
  description = "VLAN configuration for the Battlestar Ventana network"
  value       = local.vlans
}

# Output the generated UFW script path
output "ufw_script_path" {
  description = "Path to the generated UFW firewall rules script"
  value       = local.ufw_output_path
}

# Output the generated JSON rules path
output "json_rules_path" {
  description = "Path to the generated JSON firewall rules"
  value       = local.json_output_path
}

# Output rule count for validation
output "rule_count" {
  description = "Number of firewall rules generated"
  value       = length(jsondecode(data.local_file.generated_rules.content).rules)
}

# Output rules summary
output "rules_summary" {
  description = "Summary of generated firewall rules"
  value = {
    ufw_script_path  = local.ufw_output_path
    json_rules_path  = local.json_output_path
    total_vlans      = length(local.vlans)
    total_rules      = length(jsondecode(data.local_file.generated_rules.content).rules)
    generation_time  = timestamp()
  }
}
