# s3toredshift
Programmly deploy aws Instructions by terraform 
# README #
1. get the IAM access from aws
2. run the code
This project is for aws s3 bucket, glue crawler, redshift deployments.
### What is this repository for? ###
* Establish s3 and glue and redshift
* Version 1.0.0
### How do I get set up? ###
#### Procress in AWS console ####
##### 1. IAM #####
*	1.1 Access manager
* 	1.1.1 in Users security credentials create acess key
* 	1.1.2 in Roles create role with a) s3 read and write permission b) glue full permission c) redshift full permission
#### Procress in terraform ####
##### 0. IAM #####
* 0.0 create IAM role
* 0.1 create iam role policy attachment
##### 1. S3 #####
* 1.1 create s3 bucket
* 1.2 upload python script
##### 2. VPC #####
* 1.1 create VPC
* 1.2 create Subnets
* 1.3 create Route tables
* 1.4 create Internate gateways 
* 1.5 create Endpoints
* 1.6. Security
* 1.7 create security groups
##### 3. Glue #####
* 2.1 create Crawlers
* 2.2 create Connection
* 2.2 create Jobs
* 2.3 create Triggers
##### 4. Redshift #####
* 3.1 create Cluster
* 3.2 create Subnet groups
### Contribution guidelines ###
* Writing tests
* Code review
* Other guidelines
### Who do I talk to? ###
* Repo owner or admin
* Other community or team contact
