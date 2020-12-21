%dw 2.0

import keySet from dw::core::Objects
import HMACBinary, hashWith from dw::Crypto
import toHex from dw::core::Binaries

var algorithm = 'AWS4-HMAC-SHA256'
var contentType = 'application/x-amz-json-1.1'

/*
 * Sign AWS API request.
 *
 * Restrictions:
 * - not using URI parameters
 * - not using query parameters
 * - request with body accepted
 */
fun generateSecureAWSHeaders(method: String, region: String, service: String, operation: String, uri: String, queryParams: String, request,  accessKey: String, secretKey: String): Object =
	do {
		var today = now() >> "GMT"
		var amz_date = today as String {format: "yyyyMMdd'T'HHmmss'Z'"}
		var date_stamp = today as String {format: "yyyyMMdd"}
		var headers = {
			'content-type': contentType,
			'host': '$(service).$(region).amazonaws.com',
			'x-amz-date': amz_date,
			'x-amz-target': operation,
		}
		---
		headers ++ {
			"Authorization": computeAuthorizationHeader(amz_date, date_stamp, region, service, method, uri , queryParams, headers, request.^raw, accessKey, secretKey)
		}
	}

/*
 * STEP 1
 * AWS documentation: https://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
 * To begin the signing process, create a string that includes information from your request in a standardized (canonical) format.
 * This ensures that when AWS receives the request, it can calculate the same signature that you calculated.
 *
 * Pseudocode describing the way to compute canonical request is as follows:
 * CanonicalRequest =
 *   HTTPRequestMethod + '\n' +
 *   CanonicalURI + '\n' +
 *   CanonicalQueryString + '\n' +
 *   CanonicalHeaders + '\n' +
 *   SignedHeaders + '\n' +
 *   HexEncode(Hash(RequestPayload))
 */
fun canoncialRequest(method: String, uri: String, querystring: String, headers: Object, request: Binary) =
	"$(method)\n$(canoncialUri(uri))\n$(canonicalQueryParameters(querystring))\n$(canoncialHeader(headers))\n\n$(headerKeys(headers))\n$(hash(request))"

/*
 * STEP 2
 * AWS documentation: https://docs.aws.amazon.com/general/latest/gr/sigv4-create-string-to-sign.html
 * Includes meta information about your request and about the canonical request that you created
 *
 * Pseudocode describing the way to compute signing string is as follows:
 * StringToSign =
 *   Algorithm + \n +
 *   RequestDateTime + \n +
 *   CredentialScope + \n +
 *   HashedCanonicalRequest
 */
fun stringToSign(date, dateStamp, region: String, service: String, canonicalRequest) =
	"$(algorithm)\n$(date)\n$(dateStamp)/$(region)/$(service)/aws4_request\n$(hash(canonicalRequest))"

/*
 * STEP 3
 * AWS documentation: https://docs.aws.amazon.com/general/latest/gr/sigv4-calculate-signature.html
 *
 * Calculate the signature. Pseudocode:
 * kSecret = your secret access key
 * kDate = HMAC("AWS4" + kSecret, Date)
 * kRegion = HMAC(kDate, Region)
 * kService = HMAC(kRegion, Service)
 * kSigning = HMAC(kService, "aws4_request")
 */
fun getSignatureKey(key, date, region, service) =
	sign(sign(sign(sign('AWS4$(key)', date),region),service),"aws4_request")


/*
 * STEP 4
 * AWS documentation: https://docs.aws.amazon.com/general/latest/gr/sigv4-add-signature-to-request.html
 *
 * Build the authorization header. Pseudocode:
 * Authorization: algorithm Credential=access key ID/credential scope, SignedHeaders=SignedHeaders, Signature=signature
 */
fun computeAuthorizationHeader(amz_date: String, date_stamp: String, region: String, service: String, method: String, uri: String, queryString: String, headers: Object, request: Binary, accessKey: String, secretKey: String) =
	do {
		var cr = canoncialRequest(method, uri, queryString, headers, request)
		var signedHeaders = headerKeys(headers)
		var stringToSignVar = stringToSign(amz_date, date_stamp, region, service, cr)
		var signingKey = getSignatureKey(secretKey, date_stamp, region, service)
		var signature = lower(toHex(HMACBinary(signingKey as Binary, stringToSignVar as Binary, "HmacSHA256")))
		---
		'AWS4-HMAC-SHA256 Credential=$(accessKey)/$(date_stamp)/$(region)/$(service)/aws4_request, SignedHeaders=$(signedHeaders), Signature=$(signature)'
	}

/***** HELPER FUNCTIONS *****/
/*
 * Add the canonical headers, followed by a newline character.
 * The canonical headers consist of a list of all the HTTP headers that you are including with the signed request.
 */
fun canoncialHeader(headers: Object) =
	keySet(headers)
		orderBy (trim(lower($)))
		map "$(trim(lower($))):$(headers[$])"
		joinBy "\n"


fun hash(body: Binary) =
	lower(toHex(hashWith(body, "SHA-256")))

fun sign(key: Binary, msg: Binary): Binary =
	HMACBinary(key, msg, "HmacSHA256")

fun headerKeys(headers: Object) =
	keySet(headers) map (trim(lower($))) orderBy $ joinBy ";"


/*
 * TODO!
 */
fun canoncialUri(uri) =
 '/'

/*
 * TODO!
 */
fun canonicalQueryParameters(queryParameters) =
 ''