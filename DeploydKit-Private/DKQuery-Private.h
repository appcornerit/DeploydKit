//
//  DKQuery-Private.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQuery.h"
#import "DKRequest.h"

@interface DKQuery () // CLS_EXT
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *queryMap;
@property (nonatomic, strong) NSMutableDictionary *sort;
@property (nonatomic, strong) NSMutableArray *ors;
@property (nonatomic, strong) NSMutableArray *ands;
@property (nonatomic, strong) NSMutableDictionary *fieldInclExcl;
@property (nonatomic, strong) DKRequest *request;
@end

@interface DKQuery (Private)
- (NSMutableDictionary*)queryDictForKey:(NSString *)key;
- (NSString *)makeRegexSafeString:(NSString *)string;
@end