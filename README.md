# terraform_techapp

This is the Terraform project to interact with aws account and create EC2 instance to deploy the application.

## How to use this Project?

Install latest version of terraform before executing this project.

Pre-requisites-

1. Need to have AWS account
2. Generate access and secret key
3. install aws_vault to store secrets

Executing the project-

1. Initialize the terraform reources
   ```bash
    terraform init
    ```
2. Verify the terraform execution plan.
   ```bash
    terraform plan
    ```
3. To apply the changes to reach the desired state of the configuration. Input the personal token when it is asked.

   ```bash
    terraform apply
    ```
