Author: Patryk Bandurski
WWW: https://profit-online.pl

Description:
SOAP Router designed to work with Community Edition. In order to use this utility your WSDL file and XSD schemas needs to be seperate.

## Usage
### Maven Dependency
First import maven dependency to UDWL
```xml
<dependency>
	<groupId>pl.profit-online</groupId>
	<artifactId>ultimate-dw-library</artifactId>
	<version>1.0.0</version>
</dependency>
```
### Usage
#### DataWeave 1.0
Below you can see simple transformation using one of the functions from UDWL.

```
%dw 1.0
%output application/json skipNullOn="everywhere"
%var filterLib = readUrl("classpath://dw1/json/utils/emptiness_filter.dwl")

---
filterLib.filterEmptyObjects({"test": "content", "emptyObj": { }})
```
To load library I used **readUrl** function. You need to provide a **classpath://** as this is the protocol, used to retrieve the content. Then, you provide path to the file having dwl extension. To use such library you refer to it and on it you call expected function.

#### DataWeave 2.0
Below you can see simple transformation using one of the functions from UDWL.
```
%dw 2.0
import dw2::json::utils::emptiness_filter
output application/json skipNullOn="everywhere"
---
emptiness_filter::filterEmptyObjects({test: "a", obj: { }})
```
At second line we import **emptiness_filter.dwl** from **dw2/json/utils** folder. Instead of slash character you need to use two colons.  In order to use function from emptiness_filter you need to refer to specific function/variable like in the fifth line.
## New Features!
  - filter empty objects from json
 
## Functions

### Package json.utils
  - filterEmptyObjects
  Usage described at http://profit-online.pl/2018/08/dataweave-tip-6-empty-json-object/

 
## Contribute
If you come across any issues, please create a new issue at GitHub, propose new feature, or feel free to contribute a pull request to enhance.
## License
MIT