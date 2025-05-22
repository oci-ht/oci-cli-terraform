# +-----------------+
# | Local Variables |
# +-----------------+
locals {
	all_images = data.oci_core_images.shape_oracle_linux.images
	compartment_images = [for image in local.all_images : image.id if length(regexall("Oracle-Linux-[0-9].[0-9]-20[0-9]*",image.display_name)) > 0 ]
}
# +-----------+
# | Instances |
# +-----------+
resource "oci_core_instance" "cli_vm" {
    availability_domain = data.oci_identity_availability_domains.rad.availability_domains.0.name
    compartment_id      = var.compartment_ocid
    display_name        = "VM_CLI_${var.solution_name}"
    fault_domain        = "FAULT-DOMAIN-1"

	shape               = var.shape
	shape_config {
		memory_in_gbs = var.shape_memory
		ocpus         = var.shape_cpu
	}

    metadata = {
        ssh_authorized_keys = var.ssh_key_public 
    }

    create_vnic_details {
        subnet_id                 = oci_core_subnet.public_subnet.id
        display_name              = "primaryvnic"
        assign_public_ip          = true
        assign_private_dns_record = true
        hostname_label            = "cli"
    }

    source_details {
        source_type             = "image"
        source_id               = local.all_images.0.id
        boot_volume_size_in_gbs = var.shape_disk
    }
}
# +------------------+
# | Remote Execution |
# +------------------+
resource "null_resource" "remote_exec_cli_vm" {
    depends_on = [oci_core_instance.cli_vm]

    provisioner "remote-exec" {
        connection {
            agent       = false
            timeout     = "10m"
            host        = oci_core_instance.cli_vm.public_ip
            user        = "opc"
            private_key = base64decode(var.ssh_key_private)
        }

        inline = [
            "mkdir /home/opc/.keys",
            "mkdir /home/opc/.oci",
            "touch /home/opc/.keys/oci_cli_private_key.pem",
            "touch /home/opc/.oci/config",
            "echo \"[DEFAULT]\" >> /home/opc/.oci/config",
            "echo \"key_file=/home/opc/.keys/oci_cli_private_key.pem\" >> /home/opc/.oci/config",
            "touch /home/opc/setup.sh",
            "echo \"sudo dnf -y update\" >> /home/opc/setup.sh",
            "echo \"sudo dnf -y install oraclelinux-developer-release-el9\" >> /home/opc/setup.sh",
            "echo \"sudo dnf -y install python39-oci-cli\" >> /home/opc/setup.sh",
            "chmod +x /home/opc/setup.sh"
        ]
    }
}
# +-------------------+
# | Outputs Variables |
# +-------------------+
output "cli_vm_public_ip" {
    value = oci_core_instance.cli_vm.public_ip
}