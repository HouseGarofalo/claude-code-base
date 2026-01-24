---
name: azure-devops-pipelines
description: Build Azure DevOps YAML pipelines for CI/CD, manage releases, artifacts, and deployment environments. Create build and release pipelines, configure triggers, templates, and integrate with Azure services. Use when automating builds, tests, and deployments in Azure DevOps.
---

# Azure DevOps Pipelines Skill

Build CI/CD pipelines with Azure DevOps YAML pipelines for automated builds, tests, and deployments.

## Triggers

Use this skill when you see:
- azure devops, ado, azure pipelines
- yaml pipeline, ci/cd, build pipeline
- release pipeline, deployment, artifacts
- pipeline template, variable group

## Instructions

### Basic Pipeline Structure

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - release/*
  paths:
    exclude:
      - docs/*
      - README.md

pr:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  - name: buildConfiguration
    value: 'Release'
  - group: my-variable-group

stages:
  - stage: Build
    displayName: 'Build Stage'
    jobs:
      - job: BuildJob
        displayName: 'Build'
        steps:
          - task: UseDotNet@2
            inputs:
              version: '8.x'

          - script: dotnet build --configuration $(buildConfiguration)
            displayName: 'Build'

          - script: dotnet test --configuration $(buildConfiguration)
            displayName: 'Test'

          - task: PublishBuildArtifacts@1
            inputs:
              pathtoPublish: '$(Build.ArtifactStagingDirectory)'
              artifactName: 'drop'
```

### Multi-Stage Pipeline

```yaml
trigger:
  - main

stages:
  - stage: Build
    jobs:
      - job: Build
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: npm ci
          - script: npm run build
          - script: npm test
          - publish: $(System.DefaultWorkingDirectory)/dist
            artifact: webapp

  - stage: DeployDev
    displayName: 'Deploy to Development'
    dependsOn: Build
    condition: succeeded()
    jobs:
      - deployment: DeployDev
        environment: development
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: webapp
                - task: AzureWebApp@1
                  inputs:
                    azureSubscription: 'my-subscription'
                    appName: 'myapp-dev'
                    package: '$(Pipeline.Workspace)/webapp'

  - stage: DeployProd
    displayName: 'Deploy to Production'
    dependsOn: DeployDev
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProd
        environment: production
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: webapp
                - task: AzureWebApp@1
                  inputs:
                    azureSubscription: 'my-subscription'
                    appName: 'myapp-prod'
                    package: '$(Pipeline.Workspace)/webapp'
```

### Templates

#### Job Template

```yaml
# templates/build-job.yml
parameters:
  - name: buildConfiguration
    type: string
    default: 'Release'
  - name: dotnetVersion
    type: string
    default: '8.x'

jobs:
  - job: Build
    pool:
      vmImage: 'ubuntu-latest'
    steps:
      - task: UseDotNet@2
        inputs:
          version: ${{ parameters.dotnetVersion }}

      - script: dotnet restore
        displayName: 'Restore'

      - script: dotnet build --configuration ${{ parameters.buildConfiguration }}
        displayName: 'Build'

      - script: dotnet test --configuration ${{ parameters.buildConfiguration }}
        displayName: 'Test'
```

```yaml
# Main pipeline using template
stages:
  - stage: Build
    jobs:
      - template: templates/build-job.yml
        parameters:
          buildConfiguration: 'Release'
          dotnetVersion: '8.x'
```

#### Stage Template

```yaml
# templates/deploy-stage.yml
parameters:
  - name: environment
    type: string
  - name: azureSubscription
    type: string
  - name: appName
    type: string

stages:
  - stage: Deploy_${{ parameters.environment }}
    displayName: 'Deploy to ${{ parameters.environment }}'
    jobs:
      - deployment: Deploy
        environment: ${{ parameters.environment }}
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: webapp
                - task: AzureWebApp@1
                  inputs:
                    azureSubscription: ${{ parameters.azureSubscription }}
                    appName: ${{ parameters.appName }}
                    package: '$(Pipeline.Workspace)/webapp'
```

### Variables and Variable Groups

```yaml
variables:
  # Inline variables
  - name: solution
    value: '**/*.sln'
  - name: buildPlatform
    value: 'Any CPU'

  # Variable group from library
  - group: my-secrets

  # Template expression
  - name: environment
    ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
      value: 'production'
    ${{ else }}:
      value: 'development'

  # Conditional variable
  - ${{ if eq(variables['Build.Reason'], 'PullRequest') }}:
    - name: isPR
      value: true
```

### Conditions and Dependencies

```yaml
stages:
  - stage: Build
    jobs:
      - job: BuildJob
        steps:
          - script: echo "Building"

  - stage: Test
    dependsOn: Build
    condition: succeeded()
    jobs:
      - job: UnitTests
        steps:
          - script: echo "Unit Tests"

      - job: IntegrationTests
        dependsOn: UnitTests
        condition: succeeded()
        steps:
          - script: echo "Integration Tests"

  - stage: Deploy
    dependsOn: Test
    condition: |
      and(
        succeeded(),
        eq(variables['Build.SourceBranch'], 'refs/heads/main')
      )
```

### Container Jobs

```yaml
jobs:
  - job: BuildInContainer
    pool:
      vmImage: 'ubuntu-latest'
    container:
      image: node:20
      options: --user 0:0
    steps:
      - script: npm ci
      - script: npm run build
      - script: npm test

  # Multiple containers (services)
  - job: IntegrationTests
    pool:
      vmImage: 'ubuntu-latest'
    container: node:20
    services:
      postgres:
        image: postgres:15
        ports:
          - 5432:5432
        env:
          POSTGRES_PASSWORD: password
      redis:
        image: redis:alpine
        ports:
          - 6379:6379
    steps:
      - script: npm run test:integration
        env:
          DATABASE_URL: postgres://postgres:password@postgres:5432/test
          REDIS_URL: redis://redis:6379
```

### Matrix Strategy

```yaml
jobs:
  - job: Build
    strategy:
      matrix:
        linux:
          vmImage: 'ubuntu-latest'
          platform: 'linux'
        windows:
          vmImage: 'windows-latest'
          platform: 'windows'
        mac:
          vmImage: 'macos-latest'
          platform: 'mac'
      maxParallel: 3
    pool:
      vmImage: $(vmImage)
    steps:
      - script: echo "Building on $(platform)"
```

### Deployment Strategies

```yaml
jobs:
  # Rolling deployment
  - deployment: RollingDeploy
    environment: production
    strategy:
      rolling:
        maxParallel: 2
        preDeploy:
          steps:
            - script: echo "Pre-deploy"
        deploy:
          steps:
            - script: echo "Deploy"
        routeTraffic:
          steps:
            - script: echo "Route traffic"
        postRouteTraffic:
          steps:
            - script: echo "Health check"
        on:
          failure:
            steps:
              - script: echo "Rollback"
          success:
            steps:
              - script: echo "Cleanup"

  # Canary deployment
  - deployment: CanaryDeploy
    environment: production
    strategy:
      canary:
        increments: [10, 20, 50]
        preDeploy:
          steps:
            - script: echo "Pre-deploy"
        deploy:
          steps:
            - script: echo "Deploy"
        routeTraffic:
          steps:
            - script: echo "Route $(strategy.increment)% traffic"
        postRouteTraffic:
          steps:
            - script: echo "Monitor"
```

### Approvals and Checks

```yaml
# Configure in Azure DevOps UI:
# Project Settings > Environments > [environment] > Approvals and checks

stages:
  - stage: DeployProd
    jobs:
      - deployment: DeployProd
        environment: production  # Has approval configured
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo "Deploying to production"
```

### Common Tasks

```yaml
# Azure CLI
- task: AzureCLI@2
  inputs:
    azureSubscription: 'my-subscription'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az webapp list --output table

# Docker
- task: Docker@2
  inputs:
    containerRegistry: 'my-acr'
    repository: 'myapp'
    command: 'buildAndPush'
    Dockerfile: '**/Dockerfile'
    tags: |
      $(Build.BuildId)
      latest

# Kubernetes
- task: KubernetesManifest@0
  inputs:
    action: 'deploy'
    kubernetesServiceConnection: 'my-aks'
    namespace: 'production'
    manifests: |
      $(Pipeline.Workspace)/manifests/*.yml
```

## Best Practices

1. **Templates**: Use templates for reusable pipeline components
2. **Variable Groups**: Store secrets in variable groups linked to Key Vault
3. **Environments**: Use environments with approvals for production
4. **Caching**: Cache dependencies to speed up builds
5. **Artifacts**: Publish and reuse artifacts between stages

## Common Workflows

### CI/CD Pipeline
1. Define trigger branches and paths
2. Create build stage with tests
3. Publish artifacts
4. Create deployment stages per environment
5. Configure approvals for production

### Multi-Environment Deployment
1. Create environments in Azure DevOps
2. Configure approval gates
3. Use stage templates for consistency
4. Deploy with appropriate strategies
5. Monitor deployment health
