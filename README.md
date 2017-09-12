# WiremockClient

[![CI Status](http://img.shields.io/travis/theodore.rothrock@gmail.com/WiremockClient.svg?style=flat)](https://travis-ci.org/theodore.rothrock@gmail.com/WiremockClient)
[![Version](https://img.shields.io/cocoapods/v/WiremockClient.svg?style=flat)](http://cocoapods.org/pods/WiremockClient)
[![License](https://img.shields.io/cocoapods/l/WiremockClient.svg?style=flat)](http://cocoapods.org/pods/WiremockClient)
[![Platform](https://img.shields.io/cocoapods/p/WiremockClient.svg?style=flat)](http://cocoapods.org/pods/WiremockClient)

WiremockClient is an HTTP client that allows users to interact with a standalone Wiremock instance from within an Xcode project.

## Installation

WiremockClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "WiremockClient"
```

## Usage

WiremockClient maps closely to the functionality available in Wiremock's native Java API as described in the [documentation](http://wiremock.org/docs/). The pod enables you to build and post JSON mappings to a standalone Wiremock instance from within an Xcode project. It is assumed that you are familiar with the basics of using Wiremock, including initializing a standalone instance and populating it with mappings.

### Getting Started

To begin using WiremockClient, start up a standalone Wiremock instance on localhost port 8080. The base URL for all requests is set to `http://localhost:8080` by default and can be modified at the top of the `WiremockClient` file. Be sure to [whitelist your base URL](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33) before using WiremockClient, or you will be unable to communicate with your standalone instance.

### Posting a Mapping

The following code will post a mapping to your Wiremock standalone instance that will match any request sent to the `http://localhost:8080/my/path` endpoint and return a status of 200:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .willReturn(
            ResponseDefinition()
                .withStatus(200)
    )
)
```

This behavior maps closely to the Java API as described in the [Stubbing](http://wiremock.org/docs/stubbing/) portion of the documentation, so a full explanation will not be reproduced here. There are three significant differences to note:
1. The `stubFor()` method used to initialize a mapping in the Java API is now a type function of the `StubMapping` class.
2. The `aResponse()` method used to initialize a response object in the Java API has been replaced with an instance of the `ResponseDefinition` class.
3. The mapping created using the `stubFor` and `aResponse` methods above must be passed to the `WiremockClient.postMapping(stubMapping: StubMapping)` function to be posted to the standalone Wiremock instance.

### Matching a Request

All of the request matching logic available in the Java API has been reproduced within WiremockClient. For a full explanation of the methods below, reference the [Request Matching](http://wiremock.org/docs/request-matching/) portion of the documentation.

A collection of `StubMapping` instance methods enable the user to build mappings step-by-step, specifying the criteria that must be met in order for an incoming network request to be considered a match:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .withHeader("Accept", matchCondition: .contains, value: "xml")
        .withCookie("session", matchCondition: .matches, value: ".*12345.*")
        .withQueryParam("search_term", matchCondition: .equalTo, value: "WireMock")
        .withBasicAuth(username: "myUsername", password: "myPassword")
        .withRequestBody(.equalTo, value: "Some request body string")
        .willReturn(
	    ResponseDefinition()
    )
)
```

An additional `withRequestBodyEqualToJson` method has been added to allow users to set the `ignoreArrayOrder` and `ignoreExtraElements` flags described in the ‘JSON equality’ section of the [Request Matching](http://wiremock.org/docs/request-matching/) documentation:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .withRequestBodyEqualToJson(jsonString: "{ \"total_results\": 4 }", ignoreArrayOrder: true, ignoreExtraElements: true)
        .willReturn(ResponseDefinition())
)
```

Mappings can also be prioritized as described in the ‘Stub priority’ section of the [Stubbing](http://wiremock.org/docs/stubbing/) documentation:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .withPriority(1)
        .willReturn(ResponseDefinition())
)
```

### Defining a Response

All of the response definition logic available in the Java API has been reproduced in WiremockClient. For a full explanation of the methods below, reference the [Stubbing](http://wiremock.org/docs/stubbing/) portion of the documentation.

A collection of `ResponseDefinition` instance methods enable the user to specify elements to include in the response that is returned when a mapping is matched:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .willReturn(
            ResponseDefinition()
                .withStatus(200)
                .withStatusMessage("Great jorb!")
                .withHeader(key: "Content-Type", value: "text/plain")
                .withBody("Just a plain old text body")
    )
)
```

WiremockClient also includes a convenience method for returning JSON that is stored in a local file:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .willReturn(
            ResponseDefinition()
                .withLocalJsonBodyFile(fileName: "myFile", fileBundleId: "com.WiremockClient", fileSubdirectory: nil)
    )
)
```

A public `json` variable is also included as part of the ResponseDefinition object to allow for easy access to locally stored JSON, e.g. for injecting in unit tests.

### Proxying

As in the Java API, requests can be proxied through to other hosts. A full explanation of this method can be found in the [Proxying](http://wiremock.org/docs/proxying/) portion of the documentation:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .ANY, urlMatchCondition: .urlEqualTo, url: "http://localhost:8080/my/path")
        .willReturn(
            ResponseDefinition()
                .proxiedFrom("http://myproxyhost.gov")
    )
)
```

### Stateful Behavior

WiremockClient also supports scenarios as described in the [Stateful Behavior](http://wiremock.org/docs/stateful-behaviour/) portion of the documentation:

```swift
WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/my/path")
        .inScenario("Scenario Title")
        .whenScenarioStateIs("Required Scenario State")
        .willSetStateTo("New Scenario State")
        .willReturn(
            ResponseDefinition()
            .withStatus(200)
    )
)
```

The following method resets all scenarios to their default state (“Started”):

```swift
WiremockClient.resetAllScenarios()
```

### Updating a Mapping

Updating a mapping requires a reference to it’s UUID. When a mapping is created, a UUID is automatically assigned to it. However, it is also possible to assign a UUID manually and cache it in a variable for future reference. In the example below, a mapping is posted that returns a status code of 200 when matched. The mapping is then updated to return a status code of 404:

```swift
let myMappingID = UUID()

WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/my/path")
        .withUUID(myMappingID)
        .willReturn(
            ResponseDefinition()
            .withStatus(200)
    )
)

WiremockClient.updateMapping(uuid: myMappingID, stubMapping:
    StubMapping.stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/my/path")
        .willReturn(
            ResponseDefinition()
            .withStatus(404)
    )
)
```

### Deleting Mappings

Similar to updating a mapping, deleting a mapping requires a reference to it’s UUID:

```swift
let myMappingID = UUID()

WiremockClient.postMapping(stubMapping:
    StubMapping.stubFor(requestMethod: .GET, urlMatchCondition: .urlEqualTo, url: "/my/path")
        .withUUID(myMappingID)
        .willReturn(
            ResponseDefinition()
            .withStatus(200)
    )
)

WiremockClient.deleteMapping(uuid: myMappingID)
```

It is also possible to reset your Wiremock instance by deleting all mappings simultaneously:

```swift
WiremockClient.reset()
```

### Saving Mappings

Mappings can be persisted to the `mappings` directory of your Wiremock instance via the following method:

```swift
WiremockClient.saveAllMappings()
```

### Using WiremockClient in an XCTestCase

A typical use case of WiremockClient looks like this:
1. Call `WiremockClient.postMapping()` in the test suite’s `setup()` method to post the required mappings before the app launches.
2. If necessary, call `WiremockClient.updateMapping()` within the test script to alter mappings on the fly.
3. Call `WiremockClient.reset()` in the test suite’s `tearDown()` method to remove all mappings after the test has finished.

## Author

Ted Rothrock, ted.rothrock@mobileforming.com

## License

WiremockClient is available under the MIT license. See the LICENSE file for more info.
