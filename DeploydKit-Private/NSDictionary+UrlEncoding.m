//
//  NSDictionary+UrlEncoding.m
//  ParseKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSDictionary+UrlEncoding.h"

static NSString *ENGetStringRepresentationForObject(NSObject *obj) {
    if ([obj isKindOfClass:[NSNumber class]]) {
        // NSNumber returns `1` and `0` for BOOL string representation
        // instead of `true` and `false`
        NSNumber *number = (NSNumber *)obj;
        if (0 == strcmp([number objCType], @encode(BOOL))) {
            return ([number boolValue])?@"true":@"false";
        }
    }
    return [NSString stringWithFormat:@"%@", obj];
}

static NSString *ENEscapeStringForURL (NSString *str) {
    //
    // rfc 3986
    // @see http://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/Foundation/GTMNSString%2BURLArguments.m
    //
    NSString *returnString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                   (__bridge CFStringRef)str,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8));
    return returnString;
}

@implementation NSDictionary (UrlEncoding)

- (NSString *)urlEncodedString {
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:[self count]];
    for (NSString *key in [self allKeys]) {
        NSObject *value = [self objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            // we use arrays for multiple values of the same key, e.g., licenses
            for (NSString *multValue in ((NSArray *)value)) {
                [params addObject:[NSString stringWithFormat:@"%@=%@", ENEscapeStringForURL(key),
                                   ENEscapeStringForURL(ENGetStringRepresentationForObject(multValue))]];
            }
            
        } else {
            [params addObject:[NSString stringWithFormat:@"%@=%@", ENEscapeStringForURL(key),
                               ENEscapeStringForURL(ENGetStringRepresentationForObject(value))]];
        }
    }
    [params sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return [params componentsJoinedByString:@"&"];
}

@end