# OCI CLI Terraform Demo
This is an automation script to create a basic network and, within it, a virtual machine to manage the OCI CLI. Additional steps will need to be followed, which are listed below.

### Execute Script in VM
To execute the following steps you must connect to the resources created in OCI by ssh with the key that you used in their deployment.
It is important to remember that these steps must be executed one by one.
```bash
nano /home/opc/.keys/oci_cli_private_key.pem
nano /home/opc/.oci/config
chmod 600 /home/opc/.keys/oci_cli_private_key.pem
chmod 600 /home/opc/.oci/config
sh /home/opc/setup.sh
oci iam region list
OCI_COMPARTMENT=ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
OCI_NAME=DEMO
oci os bucket list -c ${OCI_COMPARTMENT}
oci os bucket create -c ${OCI_COMPARTMENT} --name OS_CLI_${OCI_NAME}
oci os bucket list -c ${OCI_COMPARTMENT}
echo "Demo File for ${OCI_NAME}" >> demo.txt
oci os object list -bn OS_CLI_${OCI_NAME}
oci os object put -bn OS_CLI_${OCI_NAME} --file demo.txt
oci os object list -bn OS_CLI_${OCI_NAME}
oci os object delete -bn OS_CLI_${OCI_NAME} --name demo.txt --force
oci os object list -bn OS_CLI_${OCI_NAME}
oci os bucket delete --name OS_CLI_${OCI_NAME} --force
oci os bucket list -c ${OCI_COMPARTMENT}
```

## Tools
[![Tools](https://skillicons.dev/icons?i=github,terraform&theme=dark)](https://registry.terraform.io/providers/oracle/oci/latest/docs)

## Execute Terraform Template
[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oci-ht/oci-cli-terraform/archive/refs/tags/1.0.zip)