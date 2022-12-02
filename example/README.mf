
# 初始化基本步骤
- terraform 腾讯云配置
- terraform init
- 网络初始化
- 中控机
- k8s or TKE

# 配置腾讯云provider配置
follow https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs

# 初始化
```cmd
cp example.tfvars.example example.tfvars
terraform init
```

# 初始化公共网段及VPC
```hcl
terraform plan -var-file poc.tfvars -out=action.tfplan -target 'module.vpc'

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.tencentcloud_eip.this[0] will be created
  + resource "tencentcloud_eip" "this" {
      + id                   = (known after apply)
      + internet_charge_type = (known after apply)
      + name                 = "zxz-poc-nat-eip-0"
      + public_ip            = (known after apply)
      + status               = (known after apply)
      + type                 = "EIP"
    }

  # module.vpc.tencentcloud_nat_gateway.this[0] will be created
  + resource "tencentcloud_nat_gateway" "this" {
      + assigned_eip_set = (known after apply)
      + bandwidth        = 100
      + created_time     = (known after apply)
      + id               = (known after apply)
      + max_concurrent   = 1000000
      + name             = "zxz-poc-ngw-public-a"
      + tags             = {
          + "Name" = "zxz-poc-ngw-public-a"
          + "test" = "poc"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.tencentcloud_route_table.this[0] will be created
  + resource "tencentcloud_route_table" "this" {
      + create_time     = (known after apply)
      + id              = (known after apply)
      + is_default      = (known after apply)
      + name            = "zxz-poc-internet-route-table-public-a"
      + route_entry_ids = (known after apply)
      + subnet_ids      = (known after apply)
      + tags            = {
          + "Name" = "zxz-poc-internet-route-table-public-a"
          + "test" = "poc"
        }
      + vpc_id          = (known after apply)
    }

  # module.vpc.tencentcloud_route_table_entry.this[0] will be created
  + resource "tencentcloud_route_table_entry" "this" {
      + description            = "zxz-poc-route-nat-public-a"
      + destination_cidr_block = "0.0.0.0/0"
      + id                     = (known after apply)
      + next_hub               = (known after apply)
      + next_type              = "NAT"
      + route_table_id         = (known after apply)
    }

  # module.vpc.tencentcloud_subnet.public[0] will be created
  + resource "tencentcloud_subnet" "public" {
      + availability_zone  = "ap-guangzhou-3"
      + available_ip_count = (known after apply)
      + cidr_block         = "172.16.0.0/24"
      + create_time        = (known after apply)
      + id                 = (known after apply)
      + is_default         = (known after apply)
      + is_multicast       = true
      + name               = "zxz-poc-subnet-public-a"
      + route_table_id     = (known after apply)
      + tags               = {
          + "Name" = "zxz-poc.vpc"
          + "test" = "poc"
        }
      + vpc_id             = (known after apply)
    }

  # module.vpc.tencentcloud_vpc.this will be created
  + resource "tencentcloud_vpc" "this" {
      + assistant_cidrs        = (known after apply)
      + cidr_block             = "172.16.0.0/20"
      + create_time            = (known after apply)
      + default_route_table_id = (known after apply)
      + dns_servers            = (known after apply)
      + docker_assistant_cidrs = (known after apply)
      + id                     = (known after apply)
      + is_default             = (known after apply)
      + is_multicast           = true
      + name                   = "zxz-poc.vpc"
      + tags                   = {
          + "Name" = "zxz-poc.vpc"
          + "test" = "poc"
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan may
│ not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such
│ as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part
│ of an error message.
╵

──────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: action.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "action.tfplan"


terraform apply "action.tfplan"
```
```cmd
terraform apply "action.tfplan"
module.vpc.tencentcloud_eip.this[0]: Creating...
module.vpc.tencentcloud_vpc.this: Creating...
module.vpc.tencentcloud_eip.this[0]: Creation complete after 5s [id=eip-g3i3npba]
module.vpc.tencentcloud_vpc.this: Creation complete after 6s [id=vpc-3tlkcnxh]
module.vpc.tencentcloud_route_table.this[0]: Creating...
module.vpc.tencentcloud_nat_gateway.this[0]: Creating...
module.vpc.tencentcloud_route_table.this[0]: Creation complete after 1s [id=rtb-qwd0avwg]
module.vpc.tencentcloud_subnet.public[0]: Creating...
module.vpc.tencentcloud_subnet.public[0]: Creation complete after 3s [id=subnet-9ier0hx8]
module.vpc.tencentcloud_nat_gateway.this[0]: Still creating... [10s elapsed]
module.vpc.tencentcloud_nat_gateway.this[0]: Creation complete after 16s [id=nat-auol3t9s]
module.vpc.tencentcloud_route_table_entry.this[0]: Creating...
module.vpc.tencentcloud_route_table_entry.this[0]: Creation complete after 1s [id=1756786.rtb-qwd0avwg]
╷
│ Warning: Applied changes may be incomplete
│
│ The plan was created with the -target option in effect, so some changes requested in the
│ configuration may have been ignored and the output values may not be fully updated. Run the
│ following command to verify that no other changes are pending:
│     terraform plan
│
│ Note that the -target option is not suitable for routine use, and is provided only for
│ exceptional situations such as recovering from errors or mistakes, or when Terraform
│ specifically suggests to use it as part of an error message.
╵

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
···

# 初始化私有网络
```
terraform plan -var-file poc.tfvars -out=action.tfplan -target 'module.private'
module.vpc.tencentcloud_eip.this[0]: Refreshing state... [id=eip-g3i3npba]
module.vpc.tencentcloud_vpc.this: Refreshing state... [id=vpc-3tlkcnxh]
module.vpc.tencentcloud_nat_gateway.this[0]: Refreshing state... [id=nat-auol3t9s]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform
apply" which may have affected this plan:

  # module.vpc.tencentcloud_eip.this[0] has changed
  ~ resource "tencentcloud_eip" "this" {
        id                   = "eip-g3i3npba"
        name                 = "zxz-poc-nat-eip-0"
      ~ status               = "UNBIND" -> "BIND"
      + tags                 = {}
        # (3 unchanged attributes hidden)
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes
using ignore_changes, the following plan may include actions to undo or respond to these changes.

──────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.private.tencentcloud_route_table.this[0] will be created
  + resource "tencentcloud_route_table" "this" {
      + create_time     = (known after apply)
      + id              = (known after apply)
      + is_default      = (known after apply)
      + name            = "zxz-poc-private-internet-route-table-private-a"
      + route_entry_ids = (known after apply)
      + subnet_ids      = (known after apply)
      + tags            = {
          + "Name" = "zxz-poc-private-internet-route-table-private-a"
          + "test" = "poc"
        }
      + vpc_id          = "vpc-3tlkcnxh"
    }

  # module.private.tencentcloud_route_table.this[1] will be created
  + resource "tencentcloud_route_table" "this" {
      + create_time     = (known after apply)
      + id              = (known after apply)
      + is_default      = (known after apply)
      + name            = "zxz-poc-private-internet-route-table-private-v"
      + route_entry_ids = (known after apply)
      + subnet_ids      = (known after apply)
      + tags            = {
          + "Name" = "zxz-poc-private-internet-route-table-private-v"
          + "test" = "poc"
        }
      + vpc_id          = "vpc-3tlkcnxh"
    }

  # module.private.tencentcloud_route_table_entry.this[0] will be created
  + resource "tencentcloud_route_table_entry" "this" {
      + description            = "zxz-poc-private-route-nat-private-a"
      + destination_cidr_block = "0.0.0.0/0"
      + id                     = (known after apply)
      + next_hub               = "nat-auol3t9s"
      + next_type              = "NAT"
      + route_table_id         = (known after apply)
    }

  # module.private.tencentcloud_route_table_entry.this[1] will be created
  + resource "tencentcloud_route_table_entry" "this" {
      + description            = "zxz-poc-private-route-nat-private-v"
      + destination_cidr_block = "0.0.0.0/0"
      + id                     = (known after apply)
      + next_hub               = "nat-auol3t9s"
      + next_type              = "NAT"
      + route_table_id         = (known after apply)
    }

  # module.private.tencentcloud_subnet.this[0] will be created
  + resource "tencentcloud_subnet" "this" {
      + availability_zone  = "ap-guangzhou-3"
      + available_ip_count = (known after apply)
      + cidr_block         = "172.16.1.0/24"
      + create_time        = (known after apply)
      + id                 = (known after apply)
      + is_default         = (known after apply)
      + is_multicast       = true
      + name               = "zxz-poc-private-subnet-private-a"
      + route_table_id     = (known after apply)
      + tags               = {
          + "Name" = "zxz-poc-private-subnet-private-a"
          + "test" = "poc"
        }
      + vpc_id             = "vpc-3tlkcnxh"
    }

  # module.private.tencentcloud_subnet.this[1] will be created
  + resource "tencentcloud_subnet" "this" {
      + availability_zone  = "ap-guangzhou-4"
      + available_ip_count = (known after apply)
      + cidr_block         = "172.16.2.0/24"
      + create_time        = (known after apply)
      + id                 = (known after apply)
      + is_default         = (known after apply)
      + is_multicast       = true
      + name               = "zxz-poc-private-subnet-private-v"
      + route_table_id     = (known after apply)
      + tags               = {
          + "Name" = "zxz-poc-private-subnet-private-v"
          + "test" = "poc"
        }
      + vpc_id             = "vpc-3tlkcnxh"
    }

Plan: 6 to add, 0 to change, 0 to destroy.
╷
│ Warning: Resource targeting is in effect
│
│ You are creating a plan with the -target option, which means that the result of this plan may
│ not represent all of the changes requested by the current configuration.
│
│ The -target option is not for routine use, and is provided only for exceptional situations such
│ as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part
│ of an error message.
╵

──────────────────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: action.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "action.tfplan"
```