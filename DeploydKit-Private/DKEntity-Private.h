//
//  DKObject+Private.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntity.h"

@interface DKEntity () // CLS_EXT
@property (nonatomic, copy, readwrite) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *setMap;
@property (nonatomic, strong) NSMutableDictionary *incMap;
@property (nonatomic, strong) NSMutableDictionary *pushMap;
@property (nonatomic, strong) NSMutableDictionary *pushAllMap;
@property (nonatomic, strong) NSMutableDictionary *addToSetMap;
@property (nonatomic, strong) NSMutableDictionary *pullAllMap;
@property (nonatomic, strong) NSDictionary *resultMap;
@property (nonatomic, strong) NSMutableDictionary *loginMap;
@end

@interface DKEntity (Private)

- (BOOL)hasEntityId:(NSError **)error;
- (BOOL)hasEntityName:(NSError **)error;
- (BOOL)commitObjectResultMap:(NSDictionary *)resultMap method:(NSString *) method error:(NSError **)error;
+ (void)deploydCommands:(NSMutableDictionary*)map operation:(NSString*)op requestDict:(NSMutableDictionary*)dict;

@end
