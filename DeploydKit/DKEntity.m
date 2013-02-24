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
#import "EGOCache.h"

@implementation DKEntity

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
    self.addToSetMap = [NSMutableDictionary new];      
    self.pullAllMap = [NSMutableDictionary new];
    self.loginMap = [NSMutableDictionary new];
    self.cachePolicy = DKCachePolicyIgnoreCache;
    self.maxCacheAge = [EGOCache globalCache].defaultTimeoutInterval;
  }
  return self;
}

- (NSString *)entityId {
  NSString *eid = (self.resultMap)[kDKEntityIDField];
  if ([eid isKindOfClass:[NSString class]]) {
    return eid;
  }
  return nil;
}

- (NSDate *)updatedAt {
  NSNumber *updatedAt = (self.resultMap)[kDKEntityUpdatedAtField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSDate *)createdAt {
  NSNumber *updatedAt = (self.resultMap)[kDKEntityCreatedAtField];
  if ([updatedAt isKindOfClass:[NSNumber class]]) {
    return [NSDate dateWithTimeIntervalSince1970:[updatedAt doubleValue]];
  }
  return nil;
}

- (NSString*)creatorId {
  NSString *creatorid = (self.resultMap)[kDKEntityCreatorIdField];
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
          self.addToSetMap.count +
          self.pullAllMap.count) > 0;
}

- (void)reset {
  [self.setMap removeAllObjects];
  [self.incMap removeAllObjects];
  [self.pushMap removeAllObjects];
  [self.pushAllMap removeAllObjects];
  [self.addToSetMap removeAllObjects];
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
  NSDictionary *requestDict = @{};
  
  // Send request synchronously
  DKRequest *request = [DKRequest request];
  request.cachePolicy = self.cachePolicy;
  request.maxCacheAge = self.maxCacheAge;
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
  NSDictionary *requestDict = @{};
  
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
  id obj = (self.setMap)[key];
  if (obj == nil) {
    obj = (self.resultMap)[key];
  }
  return obj;
}

- (void)setObject:(id)object forKey:(NSString *)key {
  (self.setMap)[key] = object;
}

- (void)pushObject:(id)object forKey:(NSString *)key {
  (self.pushMap)[key] = object;
}

- (void)pushAllObjects:(NSArray *)objects forKey:(NSString *)key {
  (self.pushAllMap)[key] = objects;
}

- (void)pullObject:(id)object forKey:(NSString *)key {
  [self pullAllObjects:@[object] forKey:key];
}

- (void)pullAllObjects:(NSArray *)objects forKey:(NSString *)key {
  (self.pullAllMap)[key] = objects;
}

- (void)addObjectToSet:(id)object forKey:(NSString *)key {
  [self addAllObjectsToSet:@[object] forKey:key];
}

- (void)addAllObjectsToSet:(NSArray *)objects forKey:(NSString *)key {
  NSMutableArray *list = (self.addToSetMap)[key];
  if (list == nil) {
    list = [NSMutableArray new];
    (self.addToSetMap)[key] = list;
  }
  for (id obj in objects) {
    if (![list containsObject:objects]) {
        [list addObject:obj];
    }
  }
}

- (void)incrementKey:(NSString *)key {
  [self incrementKey:key byAmount:@1];
}

- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount {
  (self.incMap)[key] = amount;
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

- (BOOL)login:(NSError **)error username:(NSString*)username password:(NSString*)password{
    (self.loginMap)[kDKEntityUserName] = username;
    (self.loginMap)[kDKEntityUserPassword] = password;
    return [self sendAction:@"login" error:error];
}

- (BOOL)logout:(NSError **)error {
    return [self sendAction:@"logout" error:error];
}

- (BOOL)loggedUser:(NSError **)error {
         
     // Create request dict
     NSDictionary *requestDict = @{};
     
     // Send request synchronously
     DKRequest *request = [DKRequest request];
     request.cachePolicy = DKCachePolicyIgnoreCache;
     NSError *requestError = nil;
     id resultMap = [request sendRequestWithObject:requestDict method:@"me" entity:[self.entityName stringByAppendingPathComponent:@"me"] error:&requestError];
     if (requestError != nil) {
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
        // Allowed use of $each
        static NSArray* allowedKeys;
        if (allowedKeys == nil) {
            allowedKeys = @[@"$each"];
        }
    
        __block id (^validateKeys)(id obj);
        validateKeys = [^(id obj) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                for (NSString *key in obj) {
                    NSRange range = [key rangeOfCharacterFromSet:forbiddenChars];
                    if (range.location != NSNotFound && [allowedKeys indexOfObject:key] == NSNotFound) { 
                        [NSException raise:NSInvalidArgumentException
                                    format:@"Invalid object key '%@'. Keys may not contain '$' or '.'", key];
                    }
                    id obj2 = obj[key];
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
                id value = (self.loginMap)[key];
                requestDict[key] = validateKeys(value);
            }
        }else{
            if (self.setMap.count > 0) {
                for (id key in self.setMap) {
                    id value = (self.setMap)[key];
                    requestDict[key] = validateKeys(value);
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
            if (self.addToSetMap.count > 0) {
                NSMutableDictionary *addToSetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];                
                for (id key in self.addToSetMap) {
                    id value = (self.addToSetMap)[key];
                    [DKEntity deploydCommands:[NSMutableDictionary dictionaryWithObjectsAndKeys: value, key, nil] operation:@"$each" requestDict:addToSetDict];
                }                
                requestDict[@"$addToSet"] = validateKeys(addToSetDict);
            }
        }
    
        // Send request synchronously
        DKRequest *request = [DKRequest request];
        request.cachePolicy = self.cachePolicy;
        request.maxCacheAge = self.maxCacheAge;
    
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
    if([method isEqualToString:@"logout"]){
        return YES; //logout: 204 No Content
    }
    if([method isEqualToString:@"me"]){
        return NO; //me (logout): 204 No Content
    }
    [NSError writeToError:error
                     code:DKErrorInvalidParams
              description:NSLocalizedString(@"Cannot commit action because result JSON is malformed (not an object)", nil)
                 original:nil];
#ifdef CONFIGURATION_Debug
    NSLog(@"result => %@: %@", NSStringFromClass([resultMap class]), resultMap);
#endif
    return NO;
  }
  else if([method isEqualToString:@"login"]){
          NSMutableDictionary *m = [resultMap mutableCopy];
          NSString* sid =m[@"id"]; //sid already saved as cookie
          NSString* uid =m[@"uid"];
          NSString* path =m[@"path"];
          if(sid != nil){
              //[DKManager setSessionId:sid];
              [m removeObjectForKey:@"id"];
          }
          if(uid != nil){
              m[@"id"] = uid;
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
        id value = map[key];
        result[op] = value;
        dict[key] = result;
    }
}

@end