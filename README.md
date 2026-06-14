# Node AWS API

A small TypeScript Express API designed for learning how a Node service is deployed to AWS ECS Fargate.

## What You Will Learn

- How a Node API is packaged as a Docker image.
- How ECR stores the image used by ECS.
- How ALB routes public HTTP traffic to private Fargate tasks.
- How RDS PostgreSQL stays private and is only reachable from ECS.
- How Secrets Manager injects `DATABASE_URL` into the container.
- How CloudWatch Logs and ECS service events help debug deployments.

## Local Development

1. Install dependencies:

   ```sh
   npm install
   ```

2. Create local env:

   ```sh
   cp .env.example .env
   ```

3. Start PostgreSQL:

   ```sh
   docker compose up postgres
   ```

4. Generate Prisma Client and run the migration:

   ```sh
   npm run prisma:generate
   npm run prisma:migrate
   ```

5. Start the API:

   ```sh
   npm run dev
   ```

6. Test the API:

   ```sh
   curl http://localhost:3000/health
   curl http://localhost:3000/todos
   curl -X POST http://localhost:3000/todos \
     -H 'Content-Type: application/json' \
     -d '{"title":"Learn ECS Fargate"}'
   ```

## Docker Verification

Build and run the full local stack:

```sh
docker compose up --build
```

Then open:

```sh
curl http://localhost:3000/health
```

## AWS Deployment

Copy the AWS config template:

```sh
cp scripts/aws/config.example.env scripts/aws/config.env
```

Edit `scripts/aws/config.env` with your AWS region and a real database password. Do not commit that file.

Make sure these tools are installed and authenticated:

- AWS CLI v2
- Docker
- An AWS identity with permissions for ECR, CloudFormation, EC2, ECS, Elastic Load Balancing, RDS, IAM, Logs, and Secrets Manager

Deploy everything:

```sh
./scripts/aws/deploy-all.sh
```

The script performs this sequence:

1. Create or reuse an ECR repository.
2. Build the Docker image.
3. Push the image to ECR.
4. Deploy the CloudFormation stack for VPC, ALB, ECS Fargate, RDS, Secrets Manager, and CloudWatch Logs.
5. Print the ALB URL from stack outputs.

## Important AWS Resources

- Public subnets: contain the ALB and NAT Gateway.
- Private subnets: contain ECS tasks and RDS.
- ALB security group: accepts public HTTP traffic.
- ECS security group: accepts traffic only from ALB.
- RDS security group: accepts PostgreSQL only from ECS.
- NAT Gateway: lets private ECS tasks pull images and reach AWS APIs.
- Secrets Manager: stores the database connection string for ECS.
- CloudWatch Logs: stores application logs from the container.

## HTTPS and Domain

After the HTTP deployment works:

1. Request an ACM certificate in the same region as the ALB.
2. Validate the certificate with DNS.
3. Add an ALB listener on port `443`.
4. Redirect port `80` to `443`.
5. Create a Route 53 `A` alias record pointing your domain to the ALB.

The CloudFormation template intentionally starts with HTTP so the first deployment is easier to understand.

## Monitoring and Debugging

Useful AWS console places:

- ECS service events: deployment health, failed task starts, target registration.
- ECS task logs: container stdout and stderr in CloudWatch Logs.
- ALB target group health: whether `/health` returns `200`.
- RDS connectivity: security group rules, subnet group, database endpoint.

Useful commands:

```sh
aws cloudformation describe-stacks --stack-name node-aws-api-dev
aws ecs describe-services --cluster node-aws-api-dev --services node-aws-api-dev
aws logs tail /ecs/node-aws-api-dev --follow
```

## Cost Cleanup

This learning stack creates paid resources, especially NAT Gateway, ALB, RDS, and Fargate.

Delete the CloudFormation stack when finished:

```sh
./scripts/aws/destroy-stack.sh
```

Then delete the ECR repository if you no longer need the pushed images.
