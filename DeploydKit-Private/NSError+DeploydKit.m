//
//  NSError+DeploydKit.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSError+DeploydKit.h"
#import "DKConstants.h"

@implementation NSError (DeploydKit)

+ (void)writeToError:(NSError **)error code:(NSInteger)code description:(NSString *)desc original:(NSError *)originalError {
  if (error != nil) {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (desc.length > 0) {
      userInfo[NSLocalizedDescriptionKey] = desc;
    }
    if (originalError != nil) {
      userInfo[@"DKSourceError"] = originalError;
    }
    *error = [NSError errorWithDomain:kDKErrorDomain code:code userInfo:userInfo];
  }
}

@end
