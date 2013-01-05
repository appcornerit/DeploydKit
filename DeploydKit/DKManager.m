//
//  DKManager.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKManager.h"
#import "DKRequest.h"
#import "DKReachability.h"
#import "EGOCache.h"

@implementation DKManager

static NSString *kDKManagerAPIEndpoint;
static BOOL kDKManagerRequestLogEnabled;
static NSString *kDKManagerAPISecret;
static NSString *kDKManagerSessionId;
static BOOL kDKManagerReachable;
static NSTimeInterval kDKManagerMaxCacheAge;

+ (void)setAPIEndpoint:(NSString *)absoluteString {
  NSURL *ep = [NSURL URLWithString:absoluteString];
  if (![ep.scheme isEqualToString:@"https"]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSLog(@"\n\nWARNING: DeploydKit API endpoint not secured! "
            "It's highly recommended to use SSL (current scheme is '%@')\n\n",
            ep.scheme);
    });
    
  }
  kDKManagerAPIEndpoint = [absoluteString copy];
    
  // allocate a reachability object
  DKReachability* reach = [DKReachability reachabilityWithHostname:ep.host];
  DKNetworkStatus internetStatus = [reach currentReachabilityStatus];
  if(internetStatus == DKNotReachable)
    kDKManagerReachable = NO;
  else
    kDKManagerReachable = YES;

  // here we set up a NSNotification observer. The Reachability that caused the notification
  // is passed in the object parameter
  [[NSNotificationCenter defaultCenter] addObserver:[self class]
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
  [reach startNotifier];
}

+ (void)setAPISecret:(NSString *)secret {
    kDKManagerAPISecret = [secret copy];
}

+ (void)setSessionId:(NSString *)sid {
  kDKManagerSessionId = [sid copy];
}

+ (NSString *)APIEndpoint {
  if (kDKManagerAPIEndpoint.length == 0) {
    [NSException raise:NSInternalInconsistencyException format:@"No API endpoint specified"];
    return nil;
  }
  return kDKManagerAPIEndpoint;
}

+ (NSURL *)endpointForMethod:(NSString *)method {
  NSString *ep = [[self APIEndpoint] stringByAppendingPathComponent:method];
  return [NSURL URLWithString:ep];
}

+ (NSString *)APISecret {
    if (kDKManagerAPISecret.length == 0) {
        [NSException raise:NSInternalInconsistencyException format:@"No API secret specified"];
        return nil;
    }
    return kDKManagerAPISecret;
}

+ (NSString *)sessionId {
  return kDKManagerSessionId;
}

+ (dispatch_queue_t)queue {
  static dispatch_queue_t q;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    q = dispatch_queue_create("DeploydKit queue", DISPATCH_QUEUE_SERIAL);
  });
  return q;
}

+ (void)setRequestLogEnabled:(BOOL)flag {
  kDKManagerRequestLogEnabled = flag;
}

+ (BOOL)requestLogEnabled {
  return kDKManagerRequestLogEnabled;
}

+ (BOOL)endpointReachable {
    return kDKManagerReachable;
}

+ (void)setMaxCacheAge:(NSTimeInterval)maxCacheAge{
  kDKManagerMaxCacheAge = maxCacheAge;
}

+ (NSTimeInterval)maxCacheAge{
    return kDKManagerMaxCacheAge;
}

+ (void)clearAllCachedResults{
  [[EGOCache globalCache] clearCache];
}

//Called by DKReachability whenever status changes.
+ (void)reachabilityChanged: (NSNotification* )note
{    
    DKReachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [DKReachability class]]);
    DKNetworkStatus internetStatus = [curReach currentReachabilityStatus];
    if(internetStatus == DKNotReachable) {
        kDKManagerReachable = NO;
        return;
    }
    kDKManagerReachable = YES;
}

@end
