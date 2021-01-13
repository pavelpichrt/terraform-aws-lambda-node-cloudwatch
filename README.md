# terraform-aws-lambda-node-cloudwatch

A terraform module to abstract common setup for Lambda with a Node.js layer and logging to AWS Cloudwatch.

Full docs available in [terraform registry](https://registry.terraform.io/modules/pavelpichrt/lambda-node-cloudwatch/aws/latest).

## How does it work?
The module will:

### NodeJs
* run `npm install` in the layers path (`${path.root}/src/layers/nodejs` by default),
* create a zip file from the layers directory (`"path.root/var.layers_path`) in `var.build_dir_rel_path` (`dist` by default),
* create a zip file from the handler directory (`var.handler_path`) in `var.build_dir_rel_path` (`dist` by default),

### Resources
* lambda function
* IAM role with assume role and minimal CloudWatch policies.
* NodeJs layer

## Directory structure
Is configurable via input parameters, by default the following structure is assumed:

```bash
/src
  /handler
    /exports.js
  /layers
    /nodejs
      /node_modules
      /package.json
      /package-lock.json
```

## Examples

### ./src/handler/exports.js
This is default handler path and name.

```javascript
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