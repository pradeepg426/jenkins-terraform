#
# Variables used to create the environment
#
# Pre-requisites
#

# Pre-existing key pair to use for ec2-user SSH.
variable "ec2_key_pair" { default = "smartofc"}

variable "bastion_ami" { default = "ami-d552xxx"}
variable "instance_type" { default = "t2.micro" }

variable "project_name" { default = "ofc" }

# The Environment name is appended to generated AWS element name to make it easily /ifiable.
variable "env_name" {}

Requires ECS service.
variable "server_ami" {} 
variable "server_instance_type" { default = "m4.large" }
variable "server_initial_heap_size" { default = "2048m" }
variable "server_max_heap_size" { default = "8192m" }
variable "server_max_perm_gen_size" { default = "512m" }
variable "server_notification_email" { default = "pradeep426@gmail.com" }
variable "server_root_volume_size" { default = "80" }
variable "server_asg_min_instances" { default = "0" }
variable "server_asg_max_instances" { default = "0" }
variable "server_asg_scale_upper_threshold" { default = "2500" }
variable "server_asg_scale_lower_threshold" { default = "1000" }
variable "server_deployment_batch_percentage" { default = "30" }
variable "server_elb_connection_draining_timeout" { default = "20" }
variable "server_elb_ssl_cert_id" { default = "arn:aws:acm:us-east-1:789985XXXX:certificate/b3e015d7-e844-4e42" }
variable "server_route_53_region_default_zone_id" { default = "Z117KPSXXXXX" }
#variable "server_route53_hosted_zone_id" {}
#variable "server_dns_name" {}
variable "server_logstash_token" { default = "INSERT-TOKEN" }

# RDS
variable "rdscount" {}
variable "mysql_version" { default = "5.7.17" }
variable "rds_backup_retention_period" { default = "7" }
variable "rds_binlog_format" { default = "ROW" }
variable "rds_interactive_timeout" { default = "120" }
variable "rds_log_bin_trust_function_creators" { default = "1" }
variable "rds_max_connections" { default = "1500" }
variable "rds_max_connect_errors" { default = "18446744073709547520" }
variable "rds_max_user_connections" { default = "1000" }
variable "rds_tx_isolation" { default = "READ-COMMITTED" }
variable "rds_wait_timeout" { default = "500" }  
variable "rds_instance_class" { default = "db.t2.small" }
variable "rds_use_multi_az" { default = true }
variable "rds_use_read_replica" { default = 1 }
variable "rds_username" { default = "fusionadmin" }
variable "rds_storage_size" { default = "10" } 
variable "rds_storage_type" { default = "standard" }


##
variable "cidr_whitelist" { default = "216.85.170.0/24" }

#
# Networking Variables
#

# Randomly chosen AZs.  If one is not available at the time of creation, then
# choose a different one. Add China region when available.
variable "azs" {
    default = {
        us-east-1 = "us-east-1a, us-east-1b, us-east-1d, us-east-1e"
        us-east-2 = "us-east-2a, us-east-2b, us-east-2c"
        us-west-2 = "us-west-2a, us-west-2b, us-west-2c"
        cn-north-1 = "cn-north-1a, cn-north-1b"
    }
}
variable "region" {}

variable "vpc_cidr" { default = "10.202.0.0/16" }
# Split IP space into 4 zones
# az1 10.200.0.0/18
# az2 10.200.64.0/18
# az3 10.200.128.0/18
# az4 10.200.192.0/18


variable "subnets_private_cidr" {
    default = {
        "0" = "10.202.32.0/24"
        "1" = "10.202.96.0/24"
        "2" = "10.202.160.0/24"
        "3" = "10.202.224.0/24"
    }
}

variable "cloudwatch_retention_days" { default = 3 }
variable "private_subnet_count" { default = 3 }
variable "health_check_url" {default = "HTTP:8080/apis/healthCheck"}
