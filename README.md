# MockWebServer

[![CI Status](http://img.shields.io/travis/jaehan/MockWebServer.svg?style=flat)](https://travis-ci.org/jaehan/MockWebServer)
[![Version](https://img.shields.io/cocoapods/v/MockWebServer.svg?style=flat)](http://cocoapods.org/pods/MockWebServer)
[![License](https://img.shields.io/cocoapods/l/MockWebServer.svg?style=flat)](http://cocoapods.org/pods/MockWebServer)
[![Platform](https://img.shields.io/cocoapods/p/MockWebServer.svg?style=flat)](http://cocoapods.org/pods/MockWebServer)
 
MockWebServer is a very simple web server that is solely designed to work with XCTest framework. 
MockWebServer mocks a web server's behavior. User can specify server's response headers and body by matching request pattern. 
The idea is that it can work simiarly with MockWebServer by Square for Android so that a unit test or UI test can perform test case based on 
server's response. Since user can specify the server's response in a test case, user can determine how a test case should behave.  

## Compatibility

MockWebServer is compatible with objective-c and swift, and also it can work with Cocoapods or Carthage. To use MockWebServer in Carthage, you can simple add this line to `Carfile`.

```shell
github "odinasoftware/MockWebServer"
```
MockWebServer is impemented by objective-c only so that it can work with objective-c or any version of swift. 

## Test Requirements
MockWebServer requires local connection to the server. Therefore user will need to connect to `localhost` and the port number MockWebServer is listening. 
For instance, if the server start with `mockWebServer.start(9000)`, user may connect to MockWebServer as shown below: 

```swift
let url = NSURL(string: "http://127.0.0.1:9000/test")
...
let task = URLSession.shared.dataTask(with: url! as URL) {
    (data, response, error) in
    ...
}
```
If user wants to run app transparently in a unit test, user will need to confiure app's environment to change to connect to `localhost` when it is running from a test case. For instance, in `setUp` user may set up environment like this:
```swift
let app = XCUIApplication()
app.launchEnvironment["LOCAL_SERVER"] = "YES"
app.launch()
```

Now in you application is launched, you can check to see if it is launced from UI test case like this:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    if ([[NSProcessInfo processInfo].environment objectForKey:@"LOCAL_SERVER"] != nil) {
        // Your environment detects UI test, use local server instead.
    }
    return YES;
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Objective C Example

#### Initializing MockWebServer
Initialize `MockWebServer` in `setUp` and run `start` with port number for the server.

```objective-c
- (void)setUp {
    [super setUp];
    mockWebServer = [[MockWebServer alloc] init];
    [mockWebServer start:9000];
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
TestConditionWait *testWait = [TestConditionWait instance];
...
[test resume];
[testWait waitFor:1];
```

`testWait` will wait until `[testWait wakeup]` is called. User can also specifiy how many thread it has to wait. 

### Swift Example

User will need to start MockWebServer in `setup()` with the port number for the server. 

```swift
override func setUp() {
    super.setUp()
    ...
    mockWebServer.start(9000)

}
```

User will need to stop the server when a unit test is completed.

```swift
override func tearDown() {
    super.tearDown()
    ...
    mockWebServer.stop()
}
```

As it's done in objective-c example, user will need to specify a dispatch for a response.

```swift
let dispatch: Dispatch = Dispatch()

dispatch.requestContain("test1")
    .setResponseCode(200)
    .responseString("test")
    .responseHeaders(["Accept-encoding": "*.*"])

dispatchMap.add(dispatch)
```
User can also have multiple dispatch to simulate mubliptle response in a test case.

```swift
let dispatch1: Dispatch = Dispatch()

dispatch1.requestContain("test2")
    .setResponseCode(200)
    .responseBody(for: Bundle(for: object_getClass(self)), fromFile: "response.json")
    .responseHeaders(["Accept-encoding": "*.*"])
dispatchMap.add(dispatch1)
```
Not user created two dispates, which correspnd to two responses. User will need to add those dispatches to the dispatch map.

```swift
mockWebServer.setDispatch(dispatchMap)
```

```swift
let task = URLSession.shared.dataTask(with: url! as URL) {
    (data, response, error) in
    debugPrint("response data=", data ?? "response null")
    debugPrint("response headers=", response ?? "no response header")
    testCondition.wakeup()
}

task.resume()

let task2 = URLSession.shared.dataTask(with: url2! as URL) {
    (data, response, error) in
    debugPrint("response data=", data ?? "response null", "\n")
    debugPrint("response headers=", response ?? "no response header", "\n")
    testCondition.wakeup()
}
task2.resume()

testCondition.wait(for: 2)
```

As shown in objective-c example, user can use `TestConditionWait` to wait until data thread to finish. In this case, we have two data tasks to wait. 

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
