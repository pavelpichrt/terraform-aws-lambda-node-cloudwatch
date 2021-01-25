# terraform-aws-lambda-node-cloudwatch

A terraform module to abstract common setup for Lambda with a Node.js layer and logging to AWS Cloudwatch.

Full docs available in [terraform registry](https://registry.terraform.io/modules/pavelpichrt/lambda-node-cloudwatch/aws/latest).

## What does it do?

### NodeJS

- runs `npm ci`,
- creates a zip file from the handler directory (`var.handler_path`) and a NodeJS layer.

### Resources

- aws_cloudwatch_log_group.lambda_log_group (`/aws/lambda/"${var.function_name}-${var.env}"`)
- aws_iam_role.lambda_role
- aws_iam_role_policy.cloudwatch_policy
- aws_lambda_function.lambda
- aws_lambda_layer_version.nodejs_layer
- null_resource.nodejs_layer

## Directory structure

Is configurable via input parameters, by default the following structure is assumed:

```bash
infra/
  /main.tf
  /variables.tf
package.json
/src
  /handler
    /index.js
```

## Examples

### ./src/handler/index.js

This is the default handler path and name.

```javascript
// Make sure shortid is available in ./package.json
const shortid = require("shortid");

exports.handler = async (event, context) => {
  const myDummyId = shortid.generate();

  // Sleep for 2 seconds
  await new Promise((r) => setTimeout(r, 2000));

  return myDummyId;
};
```

### Basic usage

```terraform
module "lambda-node-cloudwatch" {
  source  = "pavelpichrt/lambda-node-cloudwatch/aws"
  version = "0.2.10" # change this to latest

  function_name = "my_function"
}
```
