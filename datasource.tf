# +--------------+
# | Data Sources |
# +--------------+
data "oci_core_services" "oci_network_services" {
    filter {
        name   = "name"
        values = ["All .* Services In Oracle Services Network"]
        regex  = true
    }
}

data "oci_identity_availability_domains" "rad" {
	compartment_id = var.compartment_ocid
}

data "oci_core_images" "shape_oracle_linux" {
	compartment_id           = var.compartment_ocid
	operating_system         = "Oracle Linux"
    shape                    = var.shape
	operating_system_version = "9"
	sort_by                  = "TIMECREATED"
	sort_order               = "DESC"
}