Terraform AWS S3 Static Site
============================

This repository contains Terraform code to host a static website on AWS S3.


### Tech Stack and AWS Services
---------------------------

- **Terraform**: Infrastructure as Code (IaC) tool for provisioning and managing AWS resources.
- **AWS S3**: Simple Storage Service for storing and serving static website content.
- **CloudFront**: Content Delivery Network (CDN) for distributing static content globally and improving performance.
- **Amazon Certificate Manager**:

This is a basic example of a Terraform AWS S3 static site. Depending on your requirements, you might need to add more services or modify this architecture.


Prerequisites
-------------

- [Terraform](https://www.terraform.io/downloads.html) installed
- [AWS CLI](https://aws.amazon.com/cli/) installed
- [AWS account](https://aws.amazon.com/) with valid credentials

How to Use
----------


2. **Navigate to the repository**:

```bash
cd terraform-s3-website
```

3. **Configure AWS credentials**:

```bash
aws configure
```

4. **Create a Terraform backend**:

```bash
terraform init
```

5. **Review changes**:

```bash
terraform plan
```

6. **Create the infrastructure**:

```bash
terraform apply
```

7. **Destroy the infrastructure**:

```bash
terraform destroy
```