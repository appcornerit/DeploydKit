//
//  DKRequest.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKRequest.h"
#import "DKManager.h"
#import "NSError+DeploydKit.h"
#import "DKNetworkActivity.h"
#import "NSURLConnection+Timeout.h"


@interface DKRequest ()
@property (nonatomic, copy, readwrite) NSString *endpoint;

-(NSString*)httpMethod:(NSString*)op;

@end

// DEVNOTE: Allow untrusted certs in debug version.
// This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug

@interface NSURLRequest (DeploydKit)

+ (BOOL)setAllowsAnyHTTPSCertificate:(BOOL)flag forHost:(NSString *)host;

@end

#endif

@implementation DKRequest
DKSynthesize(endpoint)
DKSynthesize(cachePolicy)

+ (DKRequest *)request {
  return [[self alloc] init];
}

- (id)init {
  return [self initWithEndpoint:[DKManager APIEndpoint]];
}

- (id)initWithEndpoint:(NSString *)absoluteString {
  self = [super init];
  if (self) {
    self.endpoint = absoluteString;
    self.cachePolicy = DKCachePolicyIgnoreCache;
  }
  return self;
}

- (id)sendRequestWithMethod:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error {
  return [self sendRequestWithData:nil method:apiMethod entity:entityName error:error];
}

- (id)sendRequestWithObject:(id)JSONObject method:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error {
  // Wrap special objects before encoding JSON
  JSONObject = [isa wrapSpecialObjectsInJSON:JSONObject];
    
  // Encode JSON
  NSError *JSONError = nil;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&JSONError];
    
  if (JSONError != nil) {
    [NSError writeToError:error
                     code:DKErrorInvalidParams
              description:NSLocalizedString(@"Could not JSON encode request object", nil)
                 original:JSONError];
    return nil;
  }
    
  return [self sendRequestWithData:JSONData method:apiMethod entity:entityName error:error];
}

- (id)sendRequestWithData:(NSData *)bodyData method:(NSString *)apiMethod
                   entity:(NSString *)entityName error:(NSError **)error {
    
  //Append json to url
  if([apiMethod isEqualToString:@"query"] && bodyData && bodyData.length > 2){
        NSMutableString * queryParams = [NSMutableString stringWithString:entityName];
        NSString *jsonString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        if([entityName rangeOfString:@"?"].location == NSNotFound)
            [queryParams appendFormat:@"?"];
        else
            [queryParams appendFormat:@"&"];
        [queryParams appendString: jsonString];
        entityName = queryParams;
  }    
  NSString* urlString = [self.endpoint stringByAppendingString:entityName];
    
  // Create url request
  NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:URL];
  req.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
  
  // DEVNOTE: Timeout interval is quirky
  // https://devforums.apple.com/thread/25282
  req.timeoutInterval = 20.0;
  req.HTTPMethod = [self httpMethod:apiMethod];
  req.cachePolicy = self.cachePolicy;
    
  // Log request
  if ([DKManager requestLogEnabled]) {
      NSLog(@"[URL] %@", urlString);
  }
    
  if([req.HTTPMethod isEqualToString:@"POST"] || [req.HTTPMethod isEqualToString:@"PUT"]){
      if (bodyData.length > 0) {
          req.HTTPBody = bodyData;
      }
  
      [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
      
      // Log request
      [isa logData:bodyData isOut:YES];
  }
  else{
      // Log
      if ([DKManager requestLogEnabled]) {
          NSLog(@"[OUT EMPTY]");
      }
  }
 
  //NSString* sid = [DKManager sessionId]?[DKManager sessionId]:@"";
  //NSString* sidCookie = @"sid=";
  //sidCookie = [sidCookie stringByAppendingString:sid];
  //[req setValue:sidCookie forHTTPHeaderField:@"Cookie"];
  
  // DEVNOTE: Allow untrusted certs in debug version.
  // This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug
  [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:URL.host];
#endif
  
  [DKNetworkActivity begin];
  
  NSError *requestError = nil;
  NSHTTPURLResponse *response = nil;
  NSData *result = [NSURLConnection sendSynchronousRequest:req returningResponse:&response timeout:20.0 error:&requestError];
  
  [DKNetworkActivity end];
  
  // Check for request errors
  if (requestError != nil) {
    [NSError writeToError:error
                     code:DKErrorConnectionFailed
              description:NSLocalizedString(@"Connection failed", nil)
                 original:requestError];
    return nil;
  }
  
  return [isa parseResponse:response withData:result error:error];
}

+ (BOOL)canParseResponse:(NSHTTPURLResponse *)response {
  NSInteger code = response.statusCode;
  return (code == 200 || code == 400);
}

+ (id)parseResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError **)error {
  if (![self canParseResponse:response]) {
    [NSError writeToError:error
                     code:DKErrorUnknownStatus
              description:[NSString stringWithFormat:NSLocalizedString(@"Unknown response (%i)", nil), response.statusCode]
                 original:nil];
  }
  else {
    // Log response
    [self logData:data isOut:NO];
    
    if (response.statusCode == DKResponseStatusSuccess) {
      id resultObj = nil;
      NSError *JSONError = nil;
      
      // A successful operation must not always return a JSON body
      if (data.length > 0) {      
        resultObj = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:&JSONError];
      }
      if (JSONError != nil) {
        [NSError writeToError:error
                         code:DKErrorInvalidResponse
                  description:NSLocalizedString(@"Could not deserialize JSON response", nil)
                     original:JSONError];
      }
      else {
        return [self unwrapSpecialObjectsInJSON:resultObj];
      }
    }
    else if (response.statusCode == DKResponseStatusError) {
      NSError *JSONError = nil;
      id resultObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
      if (JSONError != nil) {
        [NSError writeToError:error
                         code:DKErrorInvalidResponse
                  description:NSLocalizedString(@"Could not deserialize JSON error response", nil)
                     original:JSONError];
      }
      else if (error != nil && [resultObj isKindOfClass:[NSDictionary class]]) {
        NSNumber *status = [resultObj objectForKey:@"status"];
        NSString *message = [resultObj objectForKey:@"message"];
        [NSError writeToError:error
                         code:status.integerValue
                  description:message
                     original:nil];
      }
    }
  }
  return nil;
}

-(NSString*)httpMethod:(NSString*)op{
    if([op isEqualToString:@"save"] || [op isEqualToString:@"login"] ||
       [op isEqualToString:@"logout"] || [op isEqualToString:@"apn"]) return @"POST";
    if([op isEqualToString:@"update"]) return @"PUT";
    if([op isEqualToString:@"delete"]) return @"DELETE";
    return @"GET"; //refresh/query/me
}

@end

@implementation DKRequest (Wrapping)

+ (id)iterateJSON:(id)JSONObject modify:(id (^)(id obj))handler {
  id converted = handler(JSONObject);
  if ([converted isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (id key in converted) {
      id obj = [converted objectForKey:key];
      [dict setObject:[self iterateJSON:obj modify:handler]
               forKey:key];
    }
    converted = [NSDictionary dictionaryWithDictionary:dict];
  }
  else if ([converted isKindOfClass:[NSArray class]]) {
    NSMutableArray *ary = [NSMutableArray new];
    for (id obj in converted) {
      [ary addObject:[self iterateJSON:obj modify:handler]];
    }
    converted = [NSArray arrayWithArray:ary];
  }
  return converted;
}

+ (id)wrapSpecialObjectsInJSON:(id)obj {
  return [self iterateJSON:obj modify:^id(id objectToModify) {
    return objectToModify;
  }];
}

+ (id)unwrapSpecialObjectsInJSON:(id)obj {
  return [self iterateJSON:obj modify:^id(id objectToModify) {
    return objectToModify;
  }];
}

@end

@implementation DKRequest (Logging)

+ (void)logData:(NSData *)data isOut:(BOOL)isOut {
  if ([DKManager requestLogEnabled]) {
    if (data.length > 0) {
      NSData *logData = data;
      if (data.length > 1000) {
        logData = [data subdataWithRange:NSMakeRange(0, 1000)];
      }
      NSLog(@"[%@] %@",
            (isOut ? @"OUT" : @"IN"),
            [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding]);
    }
  }
}

@end
