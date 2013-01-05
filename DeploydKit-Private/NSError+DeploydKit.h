//
//  NSError+DeploydKit.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

@interface NSError (DeploydKit)

+ (void)writeToError:(NSError **)error code:(NSInteger)code description:(NSString *)desc original:(NSError *)originalError;

@end
