# GitHub Secrets Configuration for CI/CD Deployment

This document outlines all GitHub secrets required for successful deployment to AWS Elastic Beanstalk.

## Required GitHub Secrets

Add these secrets to your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

### Docker Hub Credentials
- **`DOCKERHUB_TOKEN`** (Required)
  - Description: Docker Hub personal access token for pushing images
  - Get it from: https://hub.docker.com/settings/security
  - Required for: Building and pushing Docker images

### AWS Credentials
- **`AWS_ACCESS_KEY_ID`** (Required)
  - Description: AWS IAM access key ID
  - Get it from: AWS IAM Console → Users → Your user → Security credentials
  - Permissions needed: Elastic Beanstalk, EC2, IAM

- **`AWS_SECRET_ACCESS_KEY`** (Required)
  - Description: AWS IAM secret access key (pair with above)
  - Get it from: AWS IAM Console → Users → Your user → Security credentials
  - ⚠️ Save securely - only shown once

### AWS Elastic Beanstalk Configuration
- **`EB_APPLICATION_NAME`** (Required)
  - Value: `healthcare` (or your EB application name)
  - Get it from: AWS Console → Elastic Beanstalk → Applications

- **`EB_ENVIRONMENT_NAME`** (Required)
  - Value: `Healthcare-env` (or your EB environment name)
  - Get it from: AWS Console → Elastic Beanstalk → Environments

### Application Environment Variables
These variables are injected into Docker containers during deployment.

- **`GROQ_API_KEY`** (Required)
  - Description: Your Groq API key for LLM access
  - Get it from: https://console.groq.com/keys
  - Used by: Healthcare backend, RAG backend

- **`MONGODB_URL`** (Required)
  - Description: MongoDB connection string
  - Example format: `mongodb+srv://username:password@cluster.mongodb.net/?appName=Cluster0`
  - Get it from: MongoDB Atlas → Database → Connect → Driver
  - Used by: RAG backend, Healthcare backend

- **`DATABASE_NAME`** (Required)
  - Description: MongoDB database name
  - Example value: `healthcare_genai`
  - Used by: RAG backend, Healthcare backend

- **`OPENAI_API_KEY`** (Optional)
  - Description: OpenAI API key (alternative LLM provider)
  - Get it from: https://platform.openai.com/api-keys
  - Used by: RAG backend prompt engine (if GROQ not available)
  - Default: Demo mode if not set

- **`OPENAI_API_BASE`** (Optional)
  - Description: OpenAI API endpoint base URL
  - Default value: `https://api.openai.com/v1`
  - Used by: RAG backend prompt engine

- **`LLM_MODEL`** (Optional)
  - Description: LLM model to use
  - Example values: `gpt-3.5-turbo`, `gpt-4`
  - Default: `gpt-3.5-turbo`
  - Used by: RAG backend prompt engine

## Setup Checklist

- [ ] Create Docker Hub account and generate personal access token
- [ ] Create AWS IAM user with Elastic Beanstalk permissions
- [ ] Create AWS access keys for IAM user
- [ ] Create Groq account and get API key
- [ ] Create MongoDB Atlas account and get connection string
- [ ] Create GitHub secrets for all items above
- [ ] Verify all secrets are non-empty in GitHub
- [ ] Push code changes to trigger deployment
- [ ] Monitor deployment in GitHub Actions → Workflows
- [ ] Verify application works at AWS EB URL

## Verification Steps

1. **Check GitHub Secrets**
   ```
   GitHub.com → Your Repo → Settings → Secrets and variables → Actions
   Verify all required secrets are listed (values hidden)
   ```

2. **Test Deployment**
   ```
   1. Push code to main branch
   2. Go to GitHub Actions tab
   3. Watch CI/CD Pipeline workflow
   4. Verify "Build" job completes successfully
   5. Verify "Deploy" job completes successfully
   ```

3. **Test Application**
   ```
   1. Get EB environment URL from AWS Console
   2. Open in browser: http://your-eb-url
   3. Try generating a healthcare plan
   4. Try generating a disease overview document
   5. Both should work without errors
   ```

## Troubleshooting

### Build Fails: "DOCKERHUB_TOKEN secret is NOT set"
- Add `DOCKERHUB_TOKEN` to GitHub secrets
- Regenerate token if necessary

### Deploy Fails: "Failed to create deployment package"
- Verify `Dockerrun.aws.json` exists in repository root
- Check CI/CD log for envsubst errors
- Ensure all environment variable secrets are set

### Deploy Succeeds but App Fails: "Failed to generate document"
- RAG backend likely missing environment variables
- Check AWS EB environment configuration
- Verify MongoDB connection string is valid
- Verify GROQ_API_KEY is correct

### Cannot Connect to Database
- Verify MONGODB_URL is correct and includes credentials
- Check MongoDB Atlas network access (allow AWS EB IP)
- Verify DATABASE_NAME exists in MongoDB

## Notes

- Secrets are environment-specific; use different secrets for dev/prod
- Regenerate API keys periodically for security
- Never commit `.env` files to Git (already in .gitignore)
- GitHub secrets cannot be viewed after creation - update if incorrect
