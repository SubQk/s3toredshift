###s3 begin
resource "aws_s3_bucket" "spacelift-test1-s3" {
   bucket = "loooo"
   acl = "private"  
}

# Upload an object
resource "aws_s3_bucket_object" "object" {

  bucket = aws_s3_bucket.spacelift-test1-s3.id

  key    = "geodata.py"

  source = "/Users/kateliu/Documents/pushdir/terraorm_code_1_0/geodata.py"

  etag = filemd5("/Users/kateliu/Documents/pushdir/terraorm_code_1_0/geodata.py")
}
###s3 end 

###VPC BEGIN
resource "aws_vpc" "main" {
  cidr_block           = "172.32.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

output "vpc_id" {
  value       = "aws_vpc.main.id"
  description = "VPC id."
  sensitive   = false
}
###vpc end

###IAM
resource "aws_iam_role" "redshift_role" {
  name = "redshift_role"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

tags = {
    tag-key = "redshift-role"
  }
}

resource "aws_iam_role" "glue_role" {
  name = "glue_role"
assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

tags = {
    tag-key = "glue-role"
  }
}

resource "aws_iam_role_policy_attachment" "s3_full_access_policy" {
  role       = "${aws_iam_role.redshift_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueConsoleFullAccess" {
  role       = "${aws_iam_role.redshift_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSRedshiftFullAccess" {
  role       = "${aws_iam_role.redshift_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
resource "aws_iam_role_policy_attachment" "s3_full_access_policy1" {
  role       = "${aws_iam_role.glue_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSRedshiftFullAccess1" {
  role       = "${aws_iam_role.glue_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueConsoleFullAccess1" {
  role       = "${aws_iam_role.glue_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role       = "${aws_iam_role.glue_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
###IAM

###subnet begin
resource "aws_subnet" "public_1" {
  # The VPC ID
  vpc_id             =       aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block         =      "172.32.0.0/20"
  
  # The AZ for the subnet.
  availability_zone  =      "ap-northeast-1a"

  tags = {
    Name = "dev_subnet1"
  }
}

resource "aws_subnet" "public_2" {
  # The VPC ID
  vpc_id             =       aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block         =      "172.32.16.0/20"
  
  # The AZ for the subnet.
  availability_zone  =      "ap-northeast-1c"

  tags = {
    Name = "dev_subnet2"
  }
}

resource "aws_subnet" "public_3" {
  # The VPC ID
  vpc_id             =       aws_vpc.main.id

  # The CIDR block for the subnet.
  cidr_block         =      "172.32.32.0/20"
  
  # The AZ for the subnet.
  availability_zone  =      "ap-northeast-1d"

  tags = {
    Name = "dev_subnet3"
  }
}
### subnet end

###vpc route table begin
resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.main.id

  route = []

  tags = {
    Name = "route1"
  }
}
###vpc route table end

### route_table_association begin
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.route1.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.route1.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.route1.id
}
### route_table_association end

###internet gateways begin
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "abc"
  }
}
###internet gateways end

### vpc_endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.route1.id]
  tags = {
    Name = "dev"
  }
}
### vpc_endpoint

### security groups begin
resource "aws_security_group" "allow_tls1" {
  name        = "allow_tls1"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" // equivalent to all
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls1"
  }
}
### security groups end

###redshift begin
## subnet group
resource "aws_redshift_subnet_group" "birdsgp" {
  name       = "birdsgp"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]

  tags = {
    environment = "Production"
  }
}

#redshift cluster
resource "aws_redshift_cluster" "geodata1" {
  cluster_identifier        = "tf-redshift-cluster12"
  database_name             = "sub123"
  master_username           = "root"
  master_password           = "Mm02"
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  iam_roles                 = ["${aws_iam_role.redshift_role.arn}"]
  /* cluster_security_groups   = ["${aws_vpc.main.id}"] */#abc
  cluster_subnet_group_name = "birdsgp"
  vpc_security_group_ids  = ["${aws_security_group.allow_tls1.id}"]
  skip_final_snapshot       = true
} 
###redshift end

###glue connection begin
resource "aws_glue_connection" "gluetoredshift2" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.geodata1.endpoint}/sub123"
    PASSWORD            = "Mm0212930581"
    USERNAME            = "root"
    JDBC_ENFORCE_SSL    = "false"
  }

  name = "gluetoredshift2"

  physical_connection_requirements {
    availability_zone      = aws_subnet.public_1.availability_zone
    security_group_id_list = [aws_security_group.allow_tls1.id]
    subnet_id              = aws_subnet.public_1.id
  }
}
###glue connection end

###glue_crawler begin
resource "aws_glue_crawler" "toredshift" {
  database_name = "geo123"
  name          = "geo123"
  role          = "${aws_iam_role.glue_role.name}"

  jdbc_target {
    connection_name = "gluetoredshift2"
    path            = "sub123/public/geo_dis"
  }
}
###glue_crawler end

###glue_job begin
resource "aws_glue_job" "froms3toredshift123" {
  name     = "froms3toredshift123"
  role_arn = aws_iam_role.glue_role.arn
  connections            = [aws_glue_connection.gluetoredshift2.name]
  default_arguments      = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--TempDir"             = "s3://--"
  }
  glue_version           = "2.0"
  worker_type            = "G.1X"
  number_of_workers      = "2"

  command {
    script_location = "s3://loooo/geodata.py"
    python_version  = 3
  }  
}
###glue_job end

###glue_trigger
resource "aws_glue_trigger" "run_hourly" {
  name     = "run_hourly"
  schedule = "cron(0/60 * * * ? *)"
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.froms3toredshift123.name
    timeout = 2880
  }
}
###glue_trigger end
