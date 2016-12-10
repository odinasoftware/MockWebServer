# MockWebServer

[![CI Status](http://img.shields.io/travis/jaehan/MockWebServer.svg?style=flat)](https://travis-ci.org/jaehan/MockWebServer)
[![Version](https://img.shields.io/cocoapods/v/MockWebServer.svg?style=flat)](http://cocoapods.org/pods/MockWebServer)
[![License](https://img.shields.io/cocoapods/l/MockWebServer.svg?style=flat)](http://cocoapods.org/pods/MockWebServer)
[![Platform](https://img.shields.io/cocoapods/p/MockWebServer.svg?style=flat)](http://cocoapods.org/pods/MockWebServer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Objective C Example

#### Initializing MockWebServer
Initialize `MockWebServer` in `setUp` and run `startServer`.

```objective-c
- (void)setUp {
    [super setUp];
    mockWebServer = [[MockWebServer alloc] init];
    [mockWebServer startServer];
}
```

When a test case is completed, you will need to stop the server by running `stopServer`. You can run `stopServer` when a test is tearing down. 

```objective-c
- (void)tearDown {
    [super tearDown];
    [mockWebServer stopServer];
}
```

#### Creating Dispatch and DispatchMap
A dispatch will hold a request pattern to mock and response headers and response body to mock. 

```objective-c
Dispatch *dispatch = [[Dispatch alloc] init];
[dispatch requestContainString:@"test"];
[dispatch setResponseCode:200];
[dispatch responseString:@"test"];
[dispatch responseHeaders:@{@"Accept-encoding": @"*.*"}];
```

This will match any request contains "test" and will generate response code 200 and the response headers indicated. And the response body will be "test". After a dispatch is created, you will need to add the dispatch to a dispatchMap and set it to the mock server.

```objective-c
[dispatchMap addDispatch:dispatch];
[mockWebServer setDispatch:dispatchMap];
```

#### Running test with MockWebServer
You may use `NSURLSessionDataTask` to run a normal url request. 

```objective-c
NSString *dataUrl = @"http://127.0.0.1:9000/test";
NSURL *url = [NSURL URLWithString:dataUrl];
NSURLSessionDataTask *test = [[NSURLSession sharedSession]
dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
// 4: Handle response here
NSLog(@"data=%@", [NSString stringWithUTF8String:[data bytes]]);

XCTAssert([[NSString stringWithUTF8String:[data bytes]] compare:@"test"]==0, @"Body doesn't match.");

[testWait wakeup];
}];
```

Since the task is asynchronous, the test must wait until the asynchrnous taks is completed. You may want to use helper function to do that. First you will need to create `TestConditionWait` and you will need to wait after the url task is resumed.

```objective-c
TestConditionWait *testWait = [[TestConditionWait alloc] init];
...
[test resume];
[testWait wait];
```

`testWait` will wait until `[testWait wakeup]` is called. 

## Requirements

## Installation

MockWebServer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MockWebServer"
```

## Author

Jae Han, odinasoftware@gmail.com

## License

MockWebServer is available under the MIT license. See the LICENSE file for more info.
