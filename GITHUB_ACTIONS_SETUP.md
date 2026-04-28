# GitHub Actions CI/CD Setup Guide

## ✅ Workflow Status
The CI/CD pipeline is now active at `.github/workflows/cicd.yml`

## Overview
This pipeline automatically:
1. **Builds** 3 Docker images on push to main
2. **Pushes** images to Docker Hub with `latest` and commit SHA tags
3. **Deploys** to AWS Elastic Beanstalk

## Required GitHub Secrets

Add these 5 secrets to your GitHub repository settings:

**Go to:** Repository → Settings → Secrets and variables → Actions → New repository secret

| Secret Name | Description | Source |
|------------|-------------|--------|
| `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token | Docker Hub → Settings → Personal access tokens |
| `AWS_ACCESS_KEY_ID` | AWS Access Key | AWS IAM → Users → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | AWS IAM → Users → Security credentials |
| `EB_APPLICATION_NAME` | Elastic Beanstalk app name | Should be: `healthcare` |
| `EB_ENVIRONMENT_NAME` | Elastic Beanstalk environment | Should be: `Healthcare-env` |

## Environment Variables (Already Configured)
- `AWS_REGION`: `eu-north-1`
- `DOCKERHUB_USERNAME`: `adityaraj2104`
- `REGISTRY`: `docker.io`

## Workflow Triggers

The pipeline runs automatically on:
- **Push to main branch** - Builds, pushes, and deploys
- **Manual trigger** - Go to Actions tab → "Run workflow"

## What Gets Built

### Build Job (runs first)
Creates 3 Docker images with both `latest` and `{COMMIT_SHA}` tags:

```
docker.io/adityaraj2104/healthcare-backend:latest
docker.io/adityaraj2104/healthcare-backend:{commit-sha}

docker.io/adityaraj2104/rag-backend:latest
docker.io/adityaraj2104/rag-backend:{commit-sha}

docker.io/adityaraj2104/healthcare-frontend:latest
docker.io/adityaraj2104/healthcare-frontend:{commit-sha}
```

### Deploy Job (runs after build succeeds)
1. Verifies deployment files exist
2. Creates `beanstalk-deploy.zip` with:
   - `Dockerrun.aws.json`
   - `docker-compose.yml`
3. Deploys to AWS Elastic Beanstalk
4. Version label: `{COMMIT_SHA}-{RUN_ID}`

## Monitoring Your Deployment

1. **View workflow runs:**
   - GitHub → Actions tab → CI/CD Pipeline

2. **Check Docker Hub:**
   - hub.docker.com → Your images

3. **Monitor AWS EB:**
   - AWS Console → Elastic Beanstalk → healthcare → Healthcare-env → Recent deployments

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Secrets not set | Go to Settings → Secrets and add all 5 secrets |
| Images not pushing | Verify DOCKERHUB_TOKEN is valid and has push scope |
| EB deployment fails | Check AWS credentials have Elastic Beanstalk permissions |
| Workflow not triggering | Ensure `.github/workflows/cicd.yml` is on main branch |

## Security Notes

⚠️ **Never commit secrets** - Always use GitHub Secrets
- Secrets are encrypted at rest
- Not visible in logs
- Referenced as `${{ secrets.NAME }}` in workflows

## Docker Image Versioning

Each build creates two tags for traceability:

- **latest tag** - Always latest successful build
- **sha tag** - Specific commit for rollback capability

Example usage:
```bash
# Pull latest
docker pull adityaraj2104/healthcare-backend:latest

# Pull specific version
docker pull adityaraj2104/healthcare-backend:a1b2c3d4
```

## Testing Before Production

To test the pipeline safely:

1. Create a test branch: `git checkout -b test-cicd`
2. Update workflow trigger temporarily:
   ```yaml
   on:
     push:
       branches:
         - test-cicd  # Change from main
   ```
3. Push and watch Actions tab
4. Revert changes when ready

## Workflow Structure

```
CI/CD Pipeline (main branch push)
├─ BUILD JOB
│  ├─ Checkout code
│  ├─ Setup Docker Buildx
│  ├─ Login to Docker Hub
│  ├─ Build & Push Healthcare Backend
│  ├─ Build & Push RAG Backend
│  └─ Build & Push Healthcare Frontend
│
└─ DEPLOY JOB (depends on BUILD)
   ├─ Checkout code
   ├─ Verify deployment files
   ├─ Create deployment package
   ├─ Configure AWS credentials
   └─ Deploy to Elastic Beanstalk
```

## Next Steps

1. ✅ Workflow file committed
2. ⏳ Add the 5 GitHub Secrets
3. 🚀 Push to main to trigger first build
4. 📊 Monitor in Actions tab

## Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Build Action](https://github.com/docker/build-push-action)
- [AWS Credentials Action](https://github.com/aws-actions/configure-aws-credentials)
- [Beanstalk Deploy Action](https://github.com/einaregilsson/beanstalk-deploy)
