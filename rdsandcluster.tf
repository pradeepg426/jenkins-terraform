resource "aws_db_instance" "mysql" {
    identifier = "mysql-${lower(var.env_name)}-${aws_vpc.main.id}"
    allocated_storage = "${var.rds_storage_size}"
    count = "${var.rdscount}"
    storage_type = "${var.rds_storage_type}"
    engine = "mysql"
    engine_version = "${var.mysql_version}"
    instance_class = "${var.rds_instance_class}"
    username = "${var.rds_username}"
    password = "Terra-${var.env_name}"
    multi_az = "${var.rds_use_multi_az}"
    db_subnet_group_name = "${aws_db_subnet_group.mysql.id}"
    parameter_group_name  = "${aws_db_parameter_group.db_param_group.id}"
    vpc_security_group_ids = ["${aws_security_group.mysql.id}"]
    backup_retention_period = "${var.rds_backup_retention_period}"
    skip_final_snapshot = "true" 

    allow_major_version_upgrade = true
    apply_immediately = true
    
    tags {
        Name = "mysql.${var.env_name}"
	project_name = "${var.project_name}"
    }
}
/********************************************************************************
resource "aws_db_instance" "mysql_read_replica" {
    count = "${signum(var.rds_use_read_replica)}"
    identifier = "mysql-${lower(var.env_name)}-${aws_vpc.main.id}-ro"
    allocated_storage = "${var.rds_storage_size}"
    engine = "mysql"
    engine_version = "5.7.16"
    instance_class = "${var.rds_instance_class}"
    parameter_group_name  = "${aws_db_parameter_group.db_param_group.id}"
    vpc_security_group_ids = ["${aws_security_group.mysql.id}"]
    replicate_source_db = "${aws_db_instance.mysql.id}"
    allow_major_version_upgrade = true
	apply_immediately = true
}
********************************************************************************/

resource "aws_db_subnet_group" "mysql" {
    name = "mysql-${lower(var.env_name)}-${aws_vpc.main.id}"
    description = "mysql-${var.env_name} Multi-AZ Subnets"
    subnet_ids = ["${aws_subnet.private.*.id}"]
}

# Create RDS Security Groups
resource "aws_security_group" "mysql" {
    vpc_id = "${aws_vpc.main.id}"
    name = "mysql.${var.env_name}"
    description = "Allow MySQL access"
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${aws_security_group.bastion.id}", "${aws_security_group.openvpn.id}", "${aws_security_group.server.id}"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "mysql.${var.env_name}"
    }
}


## Create DB parameter group
resource "aws_db_parameter_group" "db_param_group" {
  name        = "mysql-${lower(var.env_name)}-${aws_vpc.main.id}-param-gp"
  family      = "mysql5.7"
  description = "${lower(var.env_name)} parameter group"

  parameter {
    name  = "binlog_format"
    value = "${var.rds_binlog_format}"
  }

  parameter {
    name  = "interactive_timeout"
    value = "${var.rds_interactive_timeout}"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "${var.rds_log_bin_trust_function_creators}"
  }

  parameter {
    name  = "max_connections"
    value = "${var.rds_max_connections}"
  }

  parameter {
    name  = "max_connect_errors"
    value = "${var.rds_max_connect_errors}"
  }

  parameter {
    name  = "max_user_connections"
    value = "${var.rds_max_user_connections}"
  }

  parameter {
    name  = "tx_isolation"
    value = "${var.rds_tx_isolation}"
  }

  parameter {
    name  = "wait_timeout"
    value = "${var.rds_wait_timeout}"
  }
}
