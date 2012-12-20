Do you need a professional backend for your iOS apps? Add one with **DeploydKit** for [Deployd](http://www.deployd.com) in minutes!

DeploydKit is based on [DataKit project](https://github.com/eaigner/DataKit), and work with [Deployd API](https://github.com/deployd/deployd) that has great features to create a solid backend for the production environment. Integrate the SDK into your app, configure Deployd and you are ready to go!
 **DeploydKit** requires iOS 5 and ARC and has been tested with Deployd 0.6.9. DeploydKit has not been developed by Deployd team, so do not disturb them with information relating to DeploydKit, use the issues of this project.

Thanks to Erik for your great work with DataKit and thanks to Deployd team for your great work with Deployd.

**Author**: Denis Berton [@DenisBerton](https://twitter.com/DenisBerton)

### Server Configuration

Refer to [Deployd.com](http://docs.deployd.com) documentation.

### Integrate the SDK

Link to DeploydKit and import `<DeploydKit/DeploydKit.h>`. Now you only need to configure the DeploydKit manager and you are almost there (this needs to be done before any other DeploydKit objects are invoked, so the app delegate would be a good place to put it).

```objc
[DeploydKit setAPIEndpoint:@"http://localhost:2403/"];
// key difficult to guess, used in DKChannel for configure secureudid (http://secureudid.org)  
[DeploydKit setAPISecret:@"4333f0a9d92257804a8c396677f9f8e4c8313e6e1c85bd244192c743ce898285"];
```

### Start Coding

Here are some examples on how to use DeploydKit, this is in no way the complete feature set.

#### Entites
DKEntity supports all of Deployd's commands for storing and updating an object in a collection.

```objc
// Saving
DKEntity *entity = [DKEntity entityWithName:@"user"];
[entity setObject:@"Denis" forKey:@"name"];
[entity setObject:@"Berton" forKey:@"surname"];
[entity setObject:[NSNumber numberWithInteger:10] forKey:@"credits"];
[entity save];
```

#### Authenticating Users
DKEntity defines the following methods to authenticate with Deployd's User collection: 

```objc
// Log in a user with their username and password
- (BOOL)login:(NSError **)error username:(NSString*)username password:(NSString*)password;

// Logging out for the current user
- (BOOL)logout:(NSError **)error;

// Checks if the current user is logged
- (BOOL)loggedUser:(NSError **)error;
```

#### Queries
DKQuery supports all of Deployd's operators and Deployd's custom commands for querying Deployd's collections.

```objc
// Sample query for $regex command that allows you to specify a regular expression to match a string property.
DKQuery *query = [DKQuery queryWithEntityName:@"SearchableEntity"];
[query whereKey:@"text" matchesRegex:@"\\s+words"];
NSArray *results = [query findAll];
```
    
#### Files
Require a Amazon Simple Storage Service (Amazon S3) configured on s3-bucket resource for Deployd on Deployd-Modules. 

```objc
// Saving
// filename generated server side with DeploydKit s3-bucket module, or chosen by the client using with Deployd deployd/dpd-s3
DKFile *file = [DKFile fileWithName:nil data:data];
[file save];
// Loading
DKFile *loadMe = [DKFile fileWithName:@"SomeFileName"];
NSData *data =[loadMe loadData:&error];
```

#### Push notifications 
DKChannel is a representation of an installation persisted that defines methods for push notification that can be sent from a client device, require apn module on Deployd-Modules.
This [tutorial](https://parse.com/tutorials/ios-push-notifications) from parse.com provides a step-by-step guide to configuring iOS application for push notifications.
Refer to [node-apn](https://github.com/argon/node-apn) documentation to configure apn module on Deployd-Modules.



