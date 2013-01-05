//
//  DKRequest.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKConstants.h"

enum {
  DKResponseStatusSuccess = 200,
  DKResponseStatusError = 400
};
typedef NSInteger DKResponseStatus;

@interface DKRequest : NSObject
@property (nonatomic, copy, readonly) NSString *endpoint;
@property (nonatomic, assign) DKCachePolicy cachePolicy;
@property (readwrite, assign) NSTimeInterval maxCacheAge;

+ (DKRequest *)request;

+ (BOOL)canParseResponse:(NSHTTPURLResponse *)response;
+ (id)parseResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError **)error isCached:(BOOL)isCached;

- (id)initWithEndpoint:(NSString *)absoluteString;

- (id)sendRequestWithMethod:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error;
- (id)sendRequestWithObject:(id)JSONObject method:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error;
- (id)sendRequestWithData:(NSData *)data method:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error;

- (BOOL)hasCachedResult;
@end

@interface DKRequest (Wrapping)

+ (id)iterateJSON:(id)JSONObject modify:(id (^)(id obj))handler;
+ (id)wrapSpecialObjectsInJSON:(id)obj;
+ (id)unwrapSpecialObjectsInJSON:(id)obj;

@end

@interface DKRequest (Logging)

+ (void)logData:(NSData *)data isOut:(BOOL)isOut isCached:(BOOL)isCached;

@end


