### Task 1: Inspect Your Current State
Use your Day 63 config (or create a small config with a VPC and EC2 instance). Apply it and then explore the state:

```bash
terraform show                                    # Full state in human-readable format
terraform state list                              # All resources tracked by Terraform
terraform state show aws_instance.<name>          # Every attribute of the instance
terraform state show aws_vpc.<name>               # Every attribute of the VPC
```

Answer:
1. How many resources does Terraform track?
aws_instance.terraweek-server
aws_internet_gateway.igw
aws_route_table.route_table
aws_route_table_association.route_table_association
aws_s3_bucket.example34
aws_security_group.security_group
aws_subnet.subnet
aws_vpc.vpc
aws_vpc_security_group_egress_rule.allow_all_traffic
aws_vpc_security_group_ingress_rule.allow_http
aws_vpc_security_group_ingress_rule.allow_ssh
2. What attributes does the state store for an EC2 instance?
way more than what you defined
3. Open `terraform.tfstate` in an editor -- find the `serial` number. What does it represent?
66
State version counter
---


### Task 4: Import an Existing Resource
Not everything starts with Terraform. Sometimes resources already exist in AWS and you need to bring them under Terraform management.

1. Manually create an S3 bucket in the AWS console -- name it `terraweek-import-test-<yourname>`
2. Write a `resource "aws_s3_bucket"` block in your config for this bucket (just the bucket name, nothing else)
3. Import it:
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-<yourname>
```
4. Run `terraform plan`:
   - If you see "No changes" -- the import was perfect
   - If you see changes -- your config does not match reality. Update your config to match, then plan again until you get "No changes"

5. Run `terraform state list` -- the imported bucket should now appear alongside your other resources

**Document:** What is the difference between `terraform import` and creating a resource from scratch?
