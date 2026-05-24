### Task 1: Explore the AWS Provider
1. Create a new project directory: `terraform-aws-infra`
2. Write a `providers.tf` file:
   - Define the `terraform` block with `required_providers` pinning the AWS provider to version `~> 5.0`
   - Define the `provider "aws"` block with your region
    terraform {
   required_providers {
     aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
     }
   }
}

provider "aws" {
 region = "us-east-1" 
}
3. Run `terraform init` and check the output -- what version was installed?
4. Read the provider lock file `.terraform.lock.hcl` -- what does it do?
this file will lock the exact  provider  version
it ensures that in every machine same provider version is there 
it stores the exact version 
Lock file = "same version use karo sab log" rule
**Document:** What does `~> 5.0` mean? How is it different from `>= 5.0` and `= 5.0.0`?
~5.0 means >= 5.0 and <= 6.0 any latest stable version can be download 
>= 5.0 any version that is above to 5.0 is alowed
= 5.0.0 only 5.0.0 version is allorwed





### Task 2: Build a VPC from Scratch
Create a `main.tf` and define these resources one by one:

1. `aws_vpc` -- CIDR block `10.0.0.0/16`, tag it `"TerraWeek-VPC"`
2. `aws_subnet` -- CIDR block `10.0.1.0/24`, reference the VPC ID from step 1, enable public IP on launch, tag it `"TerraWeek-Public-Subnet"`
3. `aws_internet_gateway` -- attach it to the VPC
4. `aws_route_table` -- create it in the VPC, add a route for `0.0.0.0/0` pointing to the internet gateway
5. `aws_route_table_association` -- associate the route table with the subnet

Run `terraform plan` -- you should see 5 resources to create.
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TerraWeek-VPC"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gate"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route_tablu"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}
**Verify:** Apply and check the AWS VPC console. Can you see all five resources connected?
yes

### Task 3: Understand Implicit Dependencies
Look at your `main.tf` carefully:

1. The subnet references `aws_vpc.main.id` -- this is an implicit dependency
2. The internet gateway references the VPC ID -- another implicit dependency
3. The route table association references both the route table and the subnet

Answer these questions:
- How does Terraform know to create the VPC before the subnet?
Terraform creates dependency graphes internally 
and then decides the order automatically

- What would happen if you tried to create the subnet before the VPC existed?
error will occur they said first create vpc
- Find all implicit dependencies in your config and list them
this dependency is used in the subnet vpc_id     = aws_vpc.vpc.id
this dependency is used in the internet gateway vpc_id = aws_vpc.vpc.id
this dependency is being used in the route table  vpc_id = aws_vpc.vpc.id
this dependency is used for attaching the igw with route table gateway_id = aws_internet_gateway.igw.id
below both are used in the route table association b/w subnet and route table
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id



  ### Task 4: Add a Security Group and EC2 Instance
Add to your config:

1. `aws_security_group` in the VPC:
   - Ingress rule: allow SSH (port 22) from `0.0.0.0/0`
   - Ingress rule: allow HTTP (port 80) from `0.0.0.0/0`
   - Egress rule: allow all outbound traffic
   - Tag: `"TerraWeek-SG"`

2. `aws_instance` in the subnet:
   - Use Amazon Linux 2 AMI for your region
   - Instance type: `t2.micro`
   - Associate the security group
   - Set `associate_public_ip_address = true`
   - Tag: `"TerraWeek-Server"`

Apply and verify -- your EC2 instance should have a public IP and be reachable.
yes ec2 has the public ip and it is reachable also


### Task 5: Explicit Dependencies with depends_on
Sometimes Terraform cannot detect a dependency automatically.

1. Add a second `aws_s3_bucket` resource for application logs
2. Add `depends_on = [aws_instance.main]` to the S3 bucket -- even though there is no direct reference, you want the bucket created only after the instance
3. Run `terraform plan` and observe the order

Now visualize the entire dependency tree:
```bash
terraform graph | dot -Tpng > graph.png
```
If you don't have `dot` (Graphviz) installed, use:
```bash
terraform graph
```
and paste the output into an online Graphviz viewer.

**Document:** When would you use `depends_on` in real projects? Give two examples.
ec2 + user data scripts 
igw + ec2

---

### Task 6: Lifecycle Rules and Destroy
1. Add a `lifecycle` block to your EC2 instance:
```hcl
lifecycle {
  create_before_destroy = true
}
```
2. Change the AMI ID to a different one and run `terraform plan` -- observe that Terraform plans to create the new instance before destroying the old one

3. Destroy everything:
```bash
terraform destroy
```
4. Watch the destroy order -- Terraform destroys in reverse dependency order. Verify in the AWS console that everything is cleaned up.

**Document:** What are the three lifecycle arguments (`create_before_destroy`, `prevent_destroy`, `ignore_changes`) and when would you use each?
create_before_destory - means it will first create the new resource then only adds up the new resource this ensures the zero downtime
prevent_destory --> this prevents from deletion of resources
ignore_changes this means terraform will ignore some of the changes

---