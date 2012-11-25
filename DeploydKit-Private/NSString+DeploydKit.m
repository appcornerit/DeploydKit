//
//  NSString+DeploydKit.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSString+DeploydKit.h"

@implementation NSString (DeploydKit)

- (NSString *)URLEncoded {
  CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                  (__bridge CFStringRef)self,
                                                                  NULL,
                                                                  (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                  kCFStringEncodingUTF8 );
  return CFBridgingRelease(urlString);
}

@end
