### Backend S3 bucket and Dynamodb

### Clone the repo
- git clone git@github.com:salman-cheema/selflearning.git
- Setup backend:
    - Create an S3 bucket at aws with a name as you like and replace it in the file
        - `selflearning/terraform/applications/api/backend.tf`
- Replace your public ssh key at this file for variable `public_key`:
    - `selflearning/terraform/applications/api/ec2.tf`
- Make sure the user/server who is running the terraform has proper permissions as those permissions will be used for the resource creation.
    - Locally:
        - Create an IAM user , create secret key pair for a user, download the keys
        - Run the command: `aws configure` and provide the keys as inputs
    - From EC2 server:
        - Attach the IAM role to the server with the required permission, no need for any other step.

- Move to the directory:
    - `cd selflearning/terraform/applications/api/`

- Initialize the terrafrom to download the modules by running the command
    - `terraform init`
- Create terraform workspace
    - `terraform workspace new dev`
    - Above command automatically create and switch you to new workspace dev
- Run terraform plan command to see the expected resources to be created
    - `terraform plan  -var-file=workspaces/$(terraform workspace show).tfvar`
- Run terraform apply after you review the plan generated by the above command
    - `terraform apply  -var-file=workspaces/$(terraform workspace show).tfvar`
- After terraform apply is complete it will generate outputs:
    - Get the value ALB DNS `rates_api_alb_dns` and hit it in the browser
        - Response will be shown:  `"Hello world!"`
## Scenario 1:
- `Code updates need to be pushed out frequently. This needs to be done without the risk of stopping a data update already being processed, nor a data response being lost`
    - Change the code of the Flask application:
        - Change this message `"Hello world!"` to `"Hello world! again new deployment"` at file
        `selflearning/terraform/applications/api/rates/rates.py` and push the code (if you like!)
- Run terraform apply command again:
    - `terraform apply  -var-file=workspaces/$(terraform workspace show).tfvar`
    - What will it do:
        - Create a new revision of the task definition
        - Create a new image of the code and push it to ECR
        - Update the ECS service to use the new code:
            - What about our previous code? Will the user see a delay during deployment? What if a new code fails due to a bug?
            - During the update of the ECS service, first of all, ECS launches a new task for the new revision, if it starts properly and the health check passes then it will start degrading the old revision, otherwise, deployment fails and our old revision keeps on serving traffic, so no delay for users in any case.
            - If the new deployment is successful, then ECS will start degrading the old revision, so for a short period we will have 2 revisions of code being served, so when you push the code after updating message keep on refreshing your browser it will show you 2 messages randomly (old and new) for while during which the deployment is under progress and after a while you must see only new message.
            - For automation testing, you can set up a script that hit your application when the deployment is under process. It must now show errors ( no need of refreshing the browser use the below command)
                - `for i in {1..100}; do curl "http://<replace-alb-dns-got-from-terrfaorm-ouput>" ; done`
        - ### NOTE:: In short I have handled CI/CD with terraform, you can keep on changing the code and Terraform will roll it out for you!
        
    - What happens if we get heavy traffic from users?
        - I have enabled autoscaling for the application if we get more traffic the ECS service will spin up more tasks for us and they automatically get registered to our target groups, once the traffic is low it automatically decreases the tasks.
        - I have set a very low limit for the CPU utilization just for testing:
            - Run the command:
                `for i in {1..100}; do curl "http://<replace-alb-dns-got-from-terrfaorm-ouput>/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"" ; done`
            - You cna use [apache bench](https://diamantidis.github.io/2020/07/15/load-testing-with-apache-bench) for the testing as well which is pretty good.
            - Verify the cloudwatch alarm is in alarm state after that you will see a new task getting registered to handle the load.

## Scenario 2:
- `For development and staging purposes, you need to start up a number of scaled-down versions of the system.`
    - The terraform application is designed in such a way that you can create as much environment as you want, here we have used terraform workspace approach, just pass the variables and the same code will work for the dev and prod as well.
    - we can parameterize everything like different VPC for the dev and prod, RDS types and count as per the environment, ECS tasks memory and CPU, Autoscaling as per the env anything... just pass them as parameters.
    - To create a new environment like prod:
        - Run the command `terraform workspace new prod`
        - Other commands are the same as we have described above.
        - Only check is the workspace file_name preset at `selflearning/terraform/applications/api/workspaces/` should match wit the workspace you have created above.
        - If they don't match you will have to run this command"
            - `Terraform workspace select prod`
            - `terraform apply  -var-file=workspaces/file_name.tfvar`
    ### Note: By using the workspaces approach we can create different environments and developers can use it for development.

# DATA Ingestion Pipeline
- Move to the directory:
    - `cd selflearning/terraform/applications/batch_jobs/`

- Initialize the terraform to download the modules by running the command
    - `terraform init`
- Create terraform workspace
    - `terraform workspace new dev`
    - Above command automatically create and switch you to new workspace dev
- Run terraform plan command to see the expected resources to be created
    - `terraform plan  -var-file=workspaces/$(terraform workspace show).tfvar`
- Run terraform apply after you review the plan generated by the above command
    - `terraform apply  -var-file=workspaces/$(terraform workspace show).tfvar`
- After terraform apply is complete

## Test your Data ingestion pipeline:
### Scenario 1:
- `Diagram and description of one concrete solution?`
    - Go to the S3 service, it must have created a bucket with the suffix `-rates`
    - Upload multiple files into it, like 5 at a time or more.
    - When a file will be uploaded to the bucket, automatically it will create an event (PUT) that triggers private lambda.
    - Now it's lambda's responsibility to run the ECS task for the event that occurs in S3.
    - The number of Tasks at ECS Fargate and the number of files will be the same, each task will pick up its file, and download it, and every task show the port of the table from Postgresql which we had configured. during API setup.
        - I have not added complex logic for the script present inside the batch_jobs container, it shows it can access DB and download file from S3, the rest logic is dependent on use cases.
        - I  real-world example ( you can upload different JSON files to S3, ECS task must have download permission, then the script parses it and upload it to DB)
        - Both the S3 download and DB connections are handled!

### Scenario 2:
- `Please elaborate on the advantages and limitations of your chosen solution
    - Advantages:
        - It is highly scalable and available as we can run multiple ECS tasks as per our files.
        - We pay only for the time for which the task runs.
        - It generated logs and writes them directly to the cloudwatch logs group based on which we can create custom filters and notify our slack channels about every file which is processed or failed.
        - Cloudwatch event rule can be created easily to check if the task failed.
    - Limitations:
        - 1. If you see the lambda code, I have set the limit of ECS tasks that can run concurrently, AWS provides a large number of ECS tasks that can run in parallel and if it is not sufficient we can request through [Service Quota]9https://aws.amazon.com/about-aws/whats-new/2020/09/aws-fargate-increases-default-resource-count-service-quotas/#:~:text=You%20can%20now%20launch%20up,from%20100%20and%20250%20respectively.) to increase it.
        - 2. What about the CPU and RAM of the task required by the tasks?
            - No doubt not every task required the same CPU and RAM, it must be dependent on the size of the file and the logic of the code present inside the ECS task.
        
### Scenario 3:
`How would you set up monitoring to identify bottlenecks as the load grows?`
`How can those bottlenecks be addressed in the future?`
-  Create a logic that set the RAM and CPU of the ECS task as per the file size being uploaded to S3.
- Setup a Cloud watch alarm that monitors the CPU of the task and if exceeds the limit it means our CPU and memory allocated to the task were not sufficient ( like this we can do benchmarking at the start) in future, if we see the CPU again, then we must see our logic of our transforming data inside the containers might need more CPU.
### Scenario 4
- What if our task got failed in between and could not process a file?
    - Push your ECS task cloudWatch logs to S3.
    - Create a notification event in S3 on the 'ObjectCreated' event and use that to trigger a Lambda function.
    - lambda filters the logs like ( failed: for task "rates" for S3 Bukcet: "ABC" Object_key "ABC" )  and pass the message to SQS form where we can give it a retry, it will keep on happening until our file is processed.

## Note:
- To create a new image for the task of batch jobs terraform will be used the same way as we have done for API, just change the code logic present in the folder terraform/application/batch_jobs/rates/rates_insertion.py and run terraform it will create a new image upload it to s3 and when a new task will be run it will have new code.
- We can create multiple environments for the batch jobs as we have done for the API using terraform workspace and developers can use it for testing, same code will be used for all env, just need to change parameters.
- To make the process more smooth for the developers we can set up GitHub actions that do this work which we are doing manually, like terraform plan and terraform apply, sample of pseudocode is attached.