## Cloudformation - AWS Elastic Beanstalk - Infrastructure as Code

This package provides an IAC component for an **Elastic Beanstalk** application in AWS.

See [main.yaml](main.yaml) for CloudFormation template file.

## Inputs

See [parameters.json](parameters.json) for starting parameter file.

| Var                                  | Description
| ------------------------------------ | -----------
| ApplicationName                      | What is the name of this application?
| EnvironmentName                      | Environments to create (Default: `Dev`)
| ---                                  | ---
| BeanstalkPlatform                    | Beanstalk platform (Default: `php7`)
| BeanstalkTier                        | Web app or worker instance? (Default: `web`)
| InstanceSize                         | Instance size (Default: `t2.micro`)
| SSHKeypair                           | **Optional** Allow SSH access using this EC2 keypair
| ---                                  | ---
| HealthCheckPath                      | Health check URL of app (Default: `/`)
| SSLCertificateArn                    | **Optional** ARN of ACM Certificate (To enable HTTPS)
| ---                                  | ---
| DeploymentPolicy                     | Deploy or update configuration all at once or rolling? (Default: `AllAtOnce`)
| RollingUpdateMaxBatchSize            | Max instances to update config simultaneously (Default: `1`)
| ---                                  | ---
| AutoScaleGroupMinSize                | Min instances (Default: `1`)
| AutoScaleGroupMaxSize                | Max instances (Default: `3`)
| AutoScaleTriggerLowerThreshold       | Scaling threshold - remove instances (Default: `20`)
| AutoScaleTriggerUpperThreshold       | Scaling threshold - add instances (Default: `80`)
| ---                                  | ---
| VPCID                                | `vpc-123456`
| PrivateInstanceSubnets               | Any 2 private subnets (`sg-1234,sg-5678`)
| LoadBalancerSubnets                  | Any 2 private or private subnets (`sg-abcd,sg-efgh`)
| LoadBalancerScheme                   | Is public-facing app? (`internal` or `external`)
| LoadBalancerAdditionalSecurityGroups | **Optional** Additional ALB SGs

## Outputs

| Var                                | Description
| ---------------------------------- | -----------
| InstanceRole                       | ARN of Instance Role
| InstanceSecurityGroup              | Security Group ID of Instances
| LoadBalancerSecurityGroup          | Security Group ID of ALB
| ElasticBeanstalkApplication        | Beanstalk application
| ElasticBeanstalkEnvironment        | Beanstalk environment
| ElasticBeanstalkURL                | Beanstalk URL (cname)
| ElasticBeanstalkELBEndpoint        | Load Balancer Endpoint
