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
#import "DKNetworkActivity.h"
#import "EGOCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface DKRequest ()
    @property (nonatomic, copy, readwrite) NSString *endpoint;
    @property (nonatomic, copy, readwrite) NSString* keyCache;
@end

// DEVNOTE: Allow untrusted certs in debug version.
// This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug

@interface NSURLRequest (DeploydKit)

+ (BOOL)setAllowsAnyHTTPSCertificate:(BOOL)flag forHost:(NSString *)host;

@end

#endif

@implementation DKRequest

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
    self.maxCacheAge = [EGOCache globalCache].defaultTimeoutInterval;     
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
      [isa logData:bodyData isOut:YES isCached:NO];
  }
  else{
      // Log
      if ([DKManager requestLogEnabled]) {
          NSLog(@"[OUT EMPTY]");
      }
  }
  
  // DEVNOTE: Allow untrusted certs in debug version.
  // This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug
  [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:URL.host];
#endif
  
  NSError *requestError = nil;
  NSHTTPURLResponse *response = nil;
  NSData *result = nil;
  BOOL loadFromCache = NO;
    
  switch (self.cachePolicy) {
    case DKCachePolicyIgnoreCache:
        result = [self sendSynchronousRequest:req returningResponse:&response error:&requestError];
        break;
    case DKCachePolicyUseCacheElseLoad:
        if([req.HTTPMethod isEqualToString:@"GET"]){
            result = [[EGOCache globalCache] dataForKey:self.keyCache?self.keyCache:[self md5:entityName]];
            loadFromCache = YES;
        }
        if(!result){
            result = [self sendSynchronousRequest:req returningResponse:&response error:&requestError];
            loadFromCache = NO;
        }
        break;
    case DKCachePolicyUseCacheIfOffline:
        if(![DKManager endpointReachable] && [req.HTTPMethod isEqualToString:@"GET"]){
            result = [[EGOCache globalCache] dataForKey:self.keyCache?self.keyCache:[self md5:entityName]];
            loadFromCache = YES;
        }else{
            result = [self sendSynchronousRequest:req returningResponse:&response error:&requestError];
        }
  }
  
  // Check for request errors
  if (requestError != nil) {
    [NSError writeToError:error
                     code:DKErrorConnectionFailed
              description:NSLocalizedString(@"Connection failed", nil)
                 original:requestError];
    return nil;
  }
  
  if([req.HTTPMethod isEqualToString:@"GET"] && !loadFromCache) {
     self.keyCache = [self md5:entityName];
     [[EGOCache globalCache] setData:result forKey:self.keyCache withTimeoutInterval:self.maxCacheAge];
  }
    
  return [isa parseResponse:response withData:result error:error isCached:loadFromCache];
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    // Start network activity indicator
    [DKNetworkActivity begin];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:response timeout:20.0 error:error];
    
    // End network activity
    [DKNetworkActivity end];
    return data;
}

- (BOOL)hasCachedResult{
    if(!self.keyCache) return NO;
    return [[EGOCache globalCache] hasCacheForKey:self.keyCache];
}

+ (BOOL)canParseResponse:(NSHTTPURLResponse *)response {
  NSInteger code = response.statusCode;
  return (code == 200 || code == 204 || code == 400);
}

+ (id)parseResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError **)error isCached:(BOOL)isCached {
  if (!isCached && ![self canParseResponse:response]) {
    [NSError writeToError:error
                     code:DKErrorUnknownStatus
              description:[NSString stringWithFormat:NSLocalizedString(@"Unknown response (%i)", nil), response.statusCode]
                 original:nil];
  }
  else {
    // Log response
      [self logData:data isOut:NO isCached:isCached];
    
    if (isCached || response.statusCode == DKResponseStatusSuccess) {
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
        NSNumber *status = resultObj[@"status"];
        NSString *message = resultObj[@"message"];
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

- (NSString *)md5:(NSString*) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end

@implementation DKRequest (Wrapping)

+ (id)iterateJSON:(id)JSONObject modify:(id (^)(id obj))handler {
  id converted = handler(JSONObject);
  if ([converted isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (id key in converted) {
      id obj = converted[key];
      dict[key] = [self iterateJSON:obj modify:handler];
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

+ (void)logData:(NSData *)data isOut:(BOOL)isOut isCached:(BOOL)isCached{
  if ([DKManager requestLogEnabled]) {
    if (data.length > 0) {
      NSData *logData = data;
      if (data.length > 1000) {
        logData = [data subdataWithRange:NSMakeRange(0, 1000)];
      }
      NSLog(@"[%@%@] %@",
            (isOut ? @"OUT" : @"IN"),(isCached ? @" CACHE" : @""),
            [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding]);
    }
  }
}

@end
