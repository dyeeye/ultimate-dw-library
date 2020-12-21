Author: Patryk Bandurski
WWW: https://ambassadorpatryk.com

Description:
DataWeave utilities. It is dedicated to DataWeave 2.x

## Usage
### Maven Dependency
First import maven dependency to UDWL
```xml
<dependency>
	<groupId>com.ambassadorpatryk</groupId>
	<artifactId>ultimate-dw-library</artifactId>
	<version>1.0.0</version>
</dependency>
```
### Usage
Below you can see simple transformation using one of the functions from UDWL.
```
%dw 2.0
output application/json skipNullOn="everywhere"
import generateSecureAWSHeaders from dw::com::ambassadorpatryk::aws::Auth
---
generateSecureAWSHeaders(
	'POST', 
	'us-east-1', 
	'ssm',
	'AmazonSSM.GetParameter', 
	'/', 
	'', 
	payload, 
	Mule::p('secure::aws.accessKey'), 
	Mule::p('secure::aws.secretKey'))

```
At second line we import **Filter.dwl** from **dw/com/ambassadorpatryk/utils** folder. Instead of slash character you need to use two colons.  In order to use function from emptiness_filter you need to refer to specific function/variable like in the fifth line.
## New Features!
  - sign AWS API Request
  - filter empty objects from json
 
## Functions

### Package dw.com.ambassadorpatryk.com.aws
  - generateSecureAWSHeaders
  Method used to create Authorization header for AWS API Request. It is based on AWS documentation https://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html 

### Package dw.com.ambassadorpatryk.com.aws
  - filterEmptyObjects
  Usage described at https://ambassadorpatryk.com/2018/08/dataweave-tip-6-empty-json-object/
 
## Contribute
If you come across any issues, please create a new issue at GitHub, propose new feature, or feel free to contribute a pull request to enhance.
## License
MIT