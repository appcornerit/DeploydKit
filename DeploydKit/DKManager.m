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

@implementation DKManager

static NSString *kDKManagerAPIEndpoint;
static BOOL kDKManagerRequestLogEnabled;
static NSString *kDKManagerSessionId;

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

@end
