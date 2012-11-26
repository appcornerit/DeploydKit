//
//  DKEntity.m
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
#import "DKEntity-Private.h"
#import "DKRequest.h"
#import "DKConstants.h"
#import "DKManager.h"

@implementation DKEntity

DKSynthesize(entityName)
DKSynthesize(setMap)
DKSynthesize(incMap)
DKSynthesize(pushMap)
DKSynthesize(pushAllMap)
DKSynthesize(pullAllMap)
DKSynthesize(resultMap)
DKSynthesize(loginMap)

+ (DKEntity *)entityWithName:(NSString *)entityName {
  return [[self alloc] initWithName:entityName];
}

- (id)initWithName:(NSString *)entityName {
  self = [super init];
  if (self) {
    self.entityName = entityName;
    self.setMap = [NSMutableDictionary new];
    self.incMap = [NSMutableDictionary new];
    self.pushMap = [NSMutableDictionary new];
    self.pushAllMap = [NSMutableDictionary new];
    self.pullAllMap = [NSMutableDictionary new];
    self.loginMap = [NSMutableDictionary new];
  }
  return self;
}

- (NSString *)entityId {
  NSString *eid = [self.resultMap objectForKey:kDKEntityIDField];
  if ([eid isKindOfClass:[NSString class]]) {
    return eid;
  }
  return nil;
}

- (NSDate *)updatedAt {
  NSNumber *updatedAt = [self.resultMap objectForKey:kDKEntityUpdatedAtField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSDate *)createdAt {
  NSNumber *updatedAt = [self.resultMap objectForKey:kDKEntityCreatedAtField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSString*)creatorId {
  NSString *creatorid = [self.resultMap objectForKey:kDKEntityCreatorIdField];
  if ([creatorid isKindOfClass:[NSString class]]) {
      return creatorid;
  }
  return nil;
}
 
- (BOOL)isNew {
  return (self.entityId.length == 0);
}

- (BOOL)isDirty {
  return (self.setMap.count +
          self.incMap.count +
          self.pushMap.count +
          self.pushAllMap.count +
          self.pullAllMap.count) > 0;
}

- (void)reset {
  [self.setMap removeAllObjects];
  [self.incMap removeAllObjects];
  [self.pushMap removeAllObjects];
  [self.pushAllMap removeAllObjects];
  [self.pullAllMap removeAllObjects];
}

- (BOOL)save {
  return [self save:NULL];
}

- (BOOL)save:(NSError **)error {
    return [self sendAction:@"save" error:error];
}

- (void)saveInBackground {
  [self saveInBackgroundWithBlock:NULL];
}

- (void)saveInBackgroundWithBlock:(void (^)(DKEntity *entity, NSError *error))block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async([DKManager queue], ^{
    NSError *error = nil;
    [self save:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(self, error); 
      });
    }
  });
}

- (BOOL)refresh {
  return [self refresh];
}

- (BOOL)refresh:(NSError **)error {
  // Check for valid object ID and entity name
  if (!([self hasEntityId:error] &&
        [self hasEntityName:error])) {
    return NO;
  }
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:nil];
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  NSError *requestError = nil;
  id resultMap = [request sendRequestWithObject:requestDict method:@"refresh" entity:[self.entityName stringByAppendingPathComponent:self.entityId] error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return NO;
  }
  
  return [self commitObjectResultMap:resultMap method:@"refresh" error:error];
}

- (void)refreshInBackground {
  [self refreshInBackgroundWithBlock:NULL];
}

- (void)refreshInBackgroundWithBlock:(void (^)(DKEntity *entity, NSError *error))block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async([DKManager queue], ^{
    NSError *error = nil;
    [self refresh:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(self, error); 
      });
    }
  });
}

- (BOOL)delete {
  return [self delete:NULL];
}

- (BOOL)delete:(NSError **)error {
  // Check for valid object ID and entity name
  if (!([self hasEntityId:error] &&
        [self hasEntityName:error])) {
    return NO;
  }
  
  // Create request dict
  NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys: nil];
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = DKCachePolicyIgnoreCache;
  
  NSError *requestError = nil;
  [request sendRequestWithObject:requestDict method:@"delete" entity:[self.entityName stringByAppendingPathComponent:self.entityId] error:&requestError];
  if (requestError != nil) {
    if (error != nil) {
      *error = requestError;
    }
    return NO;
  }
  
  // Remove maps
  self.resultMap = [NSDictionary new];

  [self reset];
  
  return YES;
}

- (void)deleteInBackground {
  [self deleteInBackgroundWithBlock:NULL];
}

- (void)deleteInBackgroundWithBlock:(void (^)(DKEntity *entity, NSError *error))block {
  block = [block copy];
  dispatch_queue_t q = dispatch_get_current_queue();
  dispatch_async([DKManager queue], ^{
    NSError *error = nil;
    [self delete:&error];
    if (block != NULL) {
      dispatch_async(q, ^{
        block(self, error); 
      });
    }
  });
}

- (id)objectForKey:(NSString *)key {
  id obj = [self.setMap objectForKey:key];
  if (obj == nil) {
    obj = [self.resultMap objectForKey:key];
  }
  return obj;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  [self.setMap setObject:object forKey:key];
}

- (void)pushObject:(id)object forKey:(NSString *)key {
  [self.pushMap setObject:object forKey:key];
}

- (void)pushAllObjects:(NSArray *)objects forKey:(NSString *)key {
  [self.pushAllMap setObject:objects forKey:key];
}

- (void)pullObject:(id)object forKey:(NSString *)key {
  [self pullAllObjects:[NSArray arrayWithObject:object] forKey:key];
}

- (void)pullAllObjects:(NSArray *)objects forKey:(NSString *)key {
  [self.pullAllMap setObject:objects forKey:key];
}

- (void)incrementKey:(NSString *)key {
  [self incrementKey:key byAmount:[NSNumber numberWithInteger:1]];
}

- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount {
  [self.incMap setObject:amount forKey:key];
}

- (BOOL)isEqual:(id)object {
  if ([object isKindOfClass:isa]) {
    return [[(DKEntity *)object entityId] isEqualToString:self.entityId];
  }
  return NO;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p %@> %@", NSStringFromClass(isa), self, self.entityId, self.resultMap];
}

- (BOOL)login:(NSError **)error username:(NSString*)username password:(NSString*)pssword{
    [self.loginMap setObject:username forKey:kDKEntityUserName];
    [self.loginMap setObject:pssword forKey:kDKEntityUserPassword];    
    return [self sendAction:@"login" error:error];
}

- (BOOL)logout:(NSError **)error {
    return [self sendAction:@"logout" error:error];
}

- (BOOL)loggedUser:(NSError **)error {
         
     // Create request dict
     NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys: nil];
     
     // Send request synchronously
     DKRequest *request = [DKRequest request];
     request.cachePolicy = DKCachePolicyIgnoreCache;
     NSError *requestError = nil;
     id resultMap = [request sendRequestWithObject:requestDict method:@"me" entity:[self.entityName stringByAppendingPathComponent:@"me"] error:&requestError];
     if (requestError != nil) { //TODO: something problem for not logged: "Unknown response (204)";
         if (error != nil) {
             *error = requestError;
         }
         return NO;
     }
     
     return [self commitObjectResultMap:resultMap method:@"me" error:error];
}

- (BOOL)sendAction:(NSString*)action error:(NSError **)error {
    
        // Check if data has been written
        if (!self.isDirty &&
            !([action isEqualToString:@"login"] || [action isEqualToString:@"logout"])) {
            return YES;
        }
        
        // Prevent use of '!', '$' and '.' in keys
        static NSCharacterSet *forbiddenChars;
        if (forbiddenChars == nil) {
            forbiddenChars = [NSCharacterSet characterSetWithCharactersInString:@"$."];
        }
        
        __block id (^validateKeys)(id obj);
        validateKeys = [^(id obj) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                for (NSString *key in obj) {
                    NSRange range = [key rangeOfCharacterFromSet:forbiddenChars];
                    if (range.location != NSNotFound) {
                        [NSException raise:NSInvalidArgumentException
                                    format:@"Invalid object key '%@'. Keys may not contain '$' or '.'", key];
                    }
                    id obj2 = [obj objectForKey:key];
                    validateKeys(obj2);
                }
            }
            else if ([obj isKindOfClass:[NSArray class]]) {
                for (id obj2 in obj) {
                    validateKeys(obj2);
                }
            }
            return obj;
        } copy];

        // Create request dict
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
        if([action isEqualToString:@"login"]){
            for (id key in self.loginMap) {
                id value = [self.loginMap objectForKey:key];
                [requestDict setObject:validateKeys(value) forKey:key];
            }
        }else{
    
            if (self.setMap.count > 0) {
                for (id key in self.setMap) {
                    id value = [self.setMap objectForKey:key];
                    [requestDict setObject:validateKeys(value) forKey:key];
                }
            }
            if (self.incMap.count > 0) {
                [DKEntity deploydCommands:self.incMap operation:@"$inc" requestDict:requestDict];
            }
            if (self.pushMap.count > 0) {
                [DKEntity deploydCommands:self.pushMap operation:@"$push" requestDict:requestDict];
            }
            if (self.pushAllMap.count > 0) {
                [DKEntity deploydCommands:self.pushAllMap operation:@"$pushAll" requestDict:requestDict];
            }
            if (self.pullAllMap.count > 0) {
                [DKEntity deploydCommands:self.pullAllMap operation:@"$pullAll" requestDict:requestDict];
            }
        }
    
        // Send request synchronously
        DKRequest *request = [DKRequest request];
        request.cachePolicy = DKCachePolicyIgnoreCache;
    
        NSString* actionUri = self.entityName;
        NSString *oid = self.entityId;
        if([action isEqualToString:@"login"] || [action isEqualToString:@"logout"] ){
            actionUri = [self.entityName stringByAppendingPathComponent:action];            
        }
        else if(oid.length > 0){
            actionUri = [self.entityName stringByAppendingPathComponent:oid];
            action = @"update";
        }
        
        NSError *requestError = nil;
        NSDictionary *resultMap = [request sendRequestWithObject:requestDict method:action entity:actionUri error:&requestError];
        if (requestError != nil) {
            if (error != nil) {
                *error = requestError;
            }
            return NO;
        }

        NSError *commitError = nil;
        BOOL success = [self commitObjectResultMap:resultMap
                                            method:action
                                              error:&commitError];
        if (!success) {
            if (error != NULL) {
                *error = commitError;
            }
            return NO;
        }
    
        return YES;
}

@end

@implementation DKEntity (Private)

- (BOOL)hasEntityId:(NSError **)error {
  if (self.entityId.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidParams
              description:NSLocalizedString(@"Entity ID invalid", nil)
                 original:nil];
    return NO;
  }
  return YES;
}

- (BOOL)hasEntityName:(NSError **)error {
  if (self.entityName.length == 0) {
    [NSError writeToError:error
                     code:DKErrorInvalidParams
              description:NSLocalizedString(@"Entity name invalid", nil)
                 original:nil];
    return NO;
  }
  return YES;
}

- (BOOL)commitObjectResultMap:(NSDictionary *)resultMap
                       method:(NSString *) method
                        error:(NSError **)error {
  if (![resultMap isKindOfClass:[NSDictionary class]]) {
    [NSError writeToError:error
                     code:DKErrorInvalidParams
              description:NSLocalizedString(@"Cannot commit action because result JSON is malformed (not an object)", nil)
                 original:nil];
    if([method isEqualToString:@"logout"]){
        error = nil; //TODO: something problem: "Cannot commit action because result JSON is malformed (not an object)";
        return YES;
    }
#ifdef CONFIGURATION_Debug
    NSLog(@"result => %@: %@", NSStringFromClass([resultMap class]), resultMap);
#endif
    return NO;
  }
  else if([method isEqualToString:@"login"]){
          NSMutableDictionary *m = [resultMap mutableCopy];
          NSString* sid =[m objectForKey:@"id"]; //sid already saved as cookie
          NSString* uid =[m objectForKey:@"uid"];
          NSString* path =[m objectForKey:@"path"];
          if(sid != nil){
              //[DKManager setSessionId:sid];
              [m removeObjectForKey:@"id"];
          }
          if(uid != nil){
              [m setObject:uid forKey:@"id"];
              [m removeObjectForKey:@"uid"];
          }
          if(path != nil){
              [m removeObjectForKey:@"path"];
          }
          resultMap = m;
  }
  self.resultMap = resultMap;
  
  [self reset];
  
  return YES;
}

+(void)deploydCommands:(NSMutableDictionary*)map operation:(NSString*)op requestDict:(NSMutableDictionary*)dict {
    for (id key in map) {
        NSMutableDictionary* result = [NSMutableDictionary new];
        id value = [map objectForKey:key];
        [result setObject:value forKey:op];
        [dict setObject:result forKey:key];
    }
}

@end