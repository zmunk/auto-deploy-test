the dist files were generated from `nexus/react/cloudformation/react`

to build:
  - create empty react/.env file
  - create react/.env.local file and add VITE_CLERK_PUBLISHABLE_KEY variable
  - `cd react`
  - `npm install`
  - `npm run dev`

see commands in cmd.sh

generate github personal access token with the following permissions:
  - repo
  - admin:repo_hook
  - admin:org_hook

add secret keys to ssm  
Note: the name of the github branch will be used to store the keys e.g. "dev", "main"

`aws ssm put-parameter --name "/dev/app/config/VITE_CLERK_PUBLISHABLE_KEY" --value "<key>" --type SecureString --region your-region`
`aws ssm put-parameter --name "/main/app/config/VITE_CLERK_PUBLISHABLE_KEY" --value "<key>" --type SecureString --region your-region`

create cfn-params.json and add GithubOAuthToken parameter, like below

```json
[
    {
        "ParameterKey": "GitHubOAuthToken",
        "ParameterValue": "<token>"
    }
]
```

`cmd create stack`

for debugging:
- `watch ./cmd.sh stack status`
- `watch ./cmd.sh stack logs`

`cmd upload dist <s3-bucket-name>`

to get cloudfront domain: `cmd stack output CloudFrontDistributionDomain`

to get s3 bucket name: `cmd stack output S3BucketName`

# Old notes

before running
- create empty .env in react folder
- create .env.local in react folder that contains VITE_CLERK_PUBLISHABLE_KEY

to run locally
- cd react
- npm install
- npm run dev

to deploy
- cd react
- npm install
- npm run build
- npm run preview
