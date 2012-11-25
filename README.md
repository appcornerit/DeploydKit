Do you need a professional backend for your iOS apps? Add one with **DeploydKit** for [Deployd](http://www.deployd.com) in minutes!

DeploydKit is based on [DataKit project](https://github.com/eaigner/DataKit), and work with [Deployd API](https://github.com/deployd/deployd) that has great features to create a solid backend for the production environment. Integrate the SDK into your app, configure Deployd and you are ready to go!
 **DeploydKit** requires iOS 5 and ARC and has been tested with Deployd 0.6.9. DeploydKit has not been developed by Deployd team, so do not disturb them with information relating to DeploydKit, used the issue of this project.

Thanks to Erik for your great work with DataKit and thanks to Deployd team for your great work with Deployd.

**Author**: Denis Berton [@DenisBerton](https://twitter.com/DenisBerton)

### Server Configuration

Refer to the great documentation on [Deployd.com](http://docs.deployd.com)

### Integrate the SDK

Link to DeploydKit and import `<DeploydKit/DeploydKit.h>`. Now you only need to configure the DeploydKit manager and you are almost there (this needs to be done before any other DeploydKit objects are invoked, so the app delegate would be a good place to put it).

```objc
[DeploydKit setAPIEndpoint:@"http://localhost:2403/"];
```

### Start Coding

Here are some examples on how to use DeploydKit, this is in no way the complete feature set.

#### Entites

```objc
// Saving
DKEntity *entity = [DKEntity entityWithName:@"user"];
[entity setObject:@"Denis" forKey:@"name"];
[entity setObject:@"Berton" forKey:@"surname"];
[entity setObject:[NSNumber numberWithInteger:10] forKey:@"credits"];
[entity save];
```
    
#### Queries

```objc
DKQuery *query = [DKQuery queryWithEntityName:@"SearchableEntity"];
[query whereKey:@"text" matchesRegex:@"\\s+words"];
NSArray *results = [query findAll];
```
    
#### Files
Require a Amazon Simple Storage Service (Amazon S3) configured on s3-bucket resource for Deployd on DeploydKitTests_Deployd 

```objc
// Saving
//filename generated server side with DeploydKit s3-bucket resource, or chosen by the client using with Deployd deployd/dpd-s3
DKFile *file = [DKFile fileWithName:nil data:data];
[file save];
// Loading
DKFile *loadMe = [DKFile fileWithName:@"SomeFileName"];
NSData *data =[loadMe loadData:&error];
```

### TODO
- Add `DKChannel` class for push notifications and async messaging

