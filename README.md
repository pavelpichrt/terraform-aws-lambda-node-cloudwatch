# terraform-aws-lambda-node-cloudwatch

A terraform module to abstract common setup for Lambda with a Node.js layer and logging to AWS Cloudwatch.

Full docs available in [terraform registry](https://registry.terraform.io/modules/pavelpichrt/lambda-node-cloudwatch/aws/latest).

## What does it do?
### NodeJS
* runs `npm install` in the layers path (`${path.root}/src/layers/nodejs` by default),
* creates a zip file from the layers directory (`"path.root/var.layers_path`) in `var.build_dir_rel_path` (`dist` by default),
* creates a zip file from the handler directory (`var.handler_path`) in `var.build_dir_rel_path` (`dist` by default),

### Resources
* Lambda function
* IAM role with AssumeRole and minimal CloudWatch policies.
* NodeJS layer
* CloudWatch log group `/aws/lambda/"${var.function_name}-${var.env}"`

## Directory structure
Is configurable via input parameters, by default the following structure is assumed:

```bash
main.tf
variables.tf
/src
  /handler
    /exports.js
  /layers
    /nodejs
      /node_modules
      /package.json
```

## Examples

### ./src/handler/exports.js
This is the default handler path and name.

```javascript
// Make sure shortid is available in src/layers/nodejs/package.json (by default)
const shortid = require('shortid');

exports.handler = async (event, context) => {
  const myDummyId = shortid.generate();

  // Sleep for 2 seconds
  await new Promise(r => setTimeout(r, 2000));

  return myDummyId;
};
```

### Basic usage
```terraform
module "lambda-node-cloudwatch" {
  source  = "pavelpichrt/lambda-node-cloudwatch/aws"
  version = "0.0.6" # change this to latest

  function_name = "my_function"
}
```

### All inputs
```terraform
module "lambda-node-cloudwatch" {
  source  = "pavelpichrt/lambda-node-cloudwatch/aws"
  version = "0.0.6" # change this to latest

  function_name      = "my_function"
  build_dir_rel_path = "dist"
  env                = "stg" # Only used for naming and tagging
  handler            = "exports.handler"
  handler_path       = "src/handler"
  layers_path        = "src/layers"
  runtime            = "nodejs12.x"
}
```