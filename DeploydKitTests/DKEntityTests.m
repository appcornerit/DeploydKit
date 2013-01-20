//
//  DKEntityTests.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKEntityTests.h"
#import "DeploydKit.h"
#import "DKEntity-Private.h"
#import "DKTests.h"

@implementation DKEntityTests

- (void)setUp {
  [DKManager setAPIEndpoint:kDKEndpoint];
  [DKManager setRequestLogEnabled:YES];
}

-(void)createDefaultUserAndLogin {
    NSError *error = nil;
    BOOL success = NO;
    
    //Insert user (SignUp)
    DKEntity *userObject = [DKEntity entityWithName:kDKEntityTestsUser];
    [userObject setObject:@"user_1" forKey:kDKEntityUserName];
    [userObject setObject:@"password_1" forKey:kDKEntityUserPassword];
    success = [userObject save:&error];
    STAssertNil(error, @"first insert should not return error, did return %@", error);
    STAssertTrue(success, @"first insert should have been successful (return YES)");
    
    //Login user
    error = nil;
    success = [userObject login:&error username:@"user_1" password:@"password_1"];
    STAssertNil(error, @"login should not return error, did return %@", error);
    STAssertTrue(success, @"login should have been successful (return YES)");
}

-(void) deleteDefaultUser{
    NSError *error = nil;
    BOOL success = NO;
    
    //Logged user
    DKEntity *userObject = [DKEntity entityWithName:kDKEntityTestsUser];
    success = [userObject loggedUser:&error];
    STAssertNil(error, @"user logged should not return error, did return %@", error);
    STAssertTrue(success, @"user logged should be logged (return YES)");
    
    //Delete user
    error = nil;
    success = [userObject delete:&error];
    STAssertNil(error, @"delete should not return error, did return %@", error);
    STAssertTrue(success, @"delete should have been successful (return YES)");
}

- (void)testUserAuth {
  NSError *error = nil;
  BOOL success = NO;
 
  [self createDefaultUserAndLogin];

  //Logged user
  DKEntity *userObject = [DKEntity entityWithName:kDKEntityTestsUser];
  success = [userObject loggedUser:&error];
  STAssertNil(error, @"user logged should not return error, did return %@", error);        
  STAssertTrue(success, @"user logged should be logged (return YES)");
    
  //Log out user
  error = nil;
  success = [userObject logout:&error];
  STAssertNil(error, @"logout should not return error, did return %@", error);    
  STAssertTrue(success, @"logout should have been successful (return YES)");
    
  //Logged user
  error = nil;
  success = [userObject loggedUser:&error];
  STAssertNotNil(error, @"user logged should return error, did return %@", error);
  STAssertFalse(success, @"user logged shouldn't be logged (return NO)");  
    
  //Delete user
  error = nil;
  success = [userObject delete:&error];
  STAssertNotNil(error, @"delete not logged should return error, did return %@", error);
  STAssertFalse(success, @"delete shouldn't have been successful (return NO)");

  //Login user
  error = nil;
  success = [userObject login:&error username:@"user_1" password:@"password_1"];
  STAssertNil(error, @"login should not return error, did return %@", error);        
  STAssertTrue(success, @"login should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testObjectCRUD {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];  
    
  //Insert post
  DKEntity *postObject = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject setObject:@"My first post" forKey:kDKEntityTestsPostText];
  success = [postObject save:&error];
  STAssertNil(error, @"post insert should not return error, did return %@", error);
  STAssertTrue(success, @"post insert should have been successful (return YES)");
  
  NSUInteger mapCount = postObject.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)4, @"result map should have 4 elements, has %i", mapCount);
  
  NSString *userId = [postObject objectForKey:kDKEntityIDField];
  NSString *text = [postObject objectForKey:kDKEntityTestsPostText];

  STAssertTrue(userId.length > 0, @"result map should have field 'id'");
  STAssertEqualObjects(text, @"My first post", @"result map should have name field set to 'My first post', is '%@'", text);
  
  NSTimeInterval createdAt = postObject.createdAt.timeIntervalSince1970;
  NSTimeInterval createdNow = [[NSDate date] timeIntervalSince1970];
  NSString *creatorId = [postObject objectForKey:kDKEntityIDField];
    
  STAssertEqualsWithAccuracy(createdAt, createdNow, 1.0, nil);
  STAssertEqualObjects(userId, creatorId, @"result map should have the same creatorIs as is', is '%@'", creatorId);
    
  //Update post
  error = nil;    
  [postObject setObject:@"My first post udpated" forKey:kDKEntityTestsPostText];
  NSArray * sharedArray = @[@"user_2",@"user_3"];
  [postObject setObject:sharedArray forKey:kDKEntityTestsPostSharedTo];
  success = [postObject save:&error];
  STAssertNil(error, @"update should not return error, did return %@", error);
  STAssertTrue(success, @"update should have been successful (return YES)");
  
  mapCount = postObject.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)4, @"result map should have 6 elements, has %i", mapCount);
  
  userId = [postObject objectForKey:kDKEntityIDField];
  text = [postObject objectForKey:kDKEntityTestsPostText];
  sharedArray = [postObject objectForKey:kDKEntityTestsPostSharedTo];
    
  STAssertTrue(userId.length > 0, @"result map should have field 'id'");
  STAssertEqualObjects(text, @"My first post udpated", @"result map should have name field set to 'My first post udpated', is '%@'", text);
   
  NSTimeInterval updatedAt = postObject.updatedAt.timeIntervalSince1970;
  NSTimeInterval updatedNow = [[NSDate date] timeIntervalSince1970];
  STAssertEqualsWithAccuracy(updatedAt, updatedNow, 1.0, nil);

  //Refresh post
  error = nil;
  NSString *refreshField = [postObject objectForKey:kDKEntityTestsPostText];    
  [postObject setObject:@"My post unsaved" forKey:kDKEntityTestsPostText];    

  success = [postObject refresh:&error];
  STAssertNil(error, @"refresh should not return error, did return %@", error);
  STAssertTrue(success, @"refresh should have been successful (return YES)");
  
  mapCount = postObject.resultMap.count;
  STAssertEquals(mapCount, (NSUInteger)6, @"result map should have 5 elements, has %i", mapCount);
  STAssertEqualObjects([postObject objectForKey:kDKEntityTestsPostText], refreshField, @"result map should have the same creatorIs as is', is '%@'", [postObject objectForKey:kDKEntityTestsPostText]);

  //Delete post
  error = nil;
  success = [postObject delete:&error];
  STAssertNil(error, @"delete post should not return error, did return %@", error);
  STAssertTrue(success, @"delete post should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testObjectKeyIncrement {
  NSError *error = nil;
  BOOL success = NO;
  
  [self createDefaultUserAndLogin];    
    
  //Insert post
  DKEntity *postObject = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject setObject:@"My first post" forKey:kDKEntityTestsPostText];
  [postObject setObject:@3 forKey:kDKEntityTestsPostVisits];
  success = [postObject save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  STAssertEquals([[postObject objectForKey:kDKEntityTestsPostVisits] integerValue], (NSInteger)3, nil);
  
  //Increment
  error = nil; 
  [postObject incrementKey:kDKEntityTestsPostVisits byAmount:@2];
  success = [postObject save:&error];
  STAssertEquals([[postObject objectForKey:kDKEntityTestsPostVisits] integerValue], (NSInteger)5, nil);
    
  //Delete post
  error = nil;
  success = [postObject delete:&error];
  STAssertNil(error, @"delete post should not return error, did return %@", error);
  STAssertTrue(success, @"delete post should have been successful (return YES)");
    
  [self deleteDefaultUser];    
}

- (void)testObjectPush {
  NSError *error = nil;
  BOOL success = NO;
  
  [self createDefaultUserAndLogin];  
    
  //Insert post
  DKEntity *postObject = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject setObject:@[@"user_2"] forKey:kDKEntityTestsPostSharedTo];  
  success = [postObject save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  //Push object
  error = nil;    
  [postObject pushObject:@"user_3" forKey:kDKEntityTestsPostSharedTo];
  success = [postObject save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  NSArray *list = [postObject objectForKey:kDKEntityTestsPostSharedTo];
  NSArray *comp = @[@"user_2", @"user_3"];
  STAssertEqualObjects(list, comp, nil);

  //Push all objects    
  error = nil;    
  [postObject pushAllObjects:@[@"user_4", @"user_5"] forKey:kDKEntityTestsPostSharedTo];
  success = [postObject save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  list = [postObject objectForKey:kDKEntityTestsPostSharedTo];
  comp = @[@"user_2", @"user_3", @"user_4", @"user_5"];
  STAssertEqualObjects(list, comp, nil);
  
  //Delete post
  error = nil;
  success = [postObject delete:&error];
  STAssertNil(error, @"delete post should not return error, did return %@", error);
  STAssertTrue(success, @"delete post should have been successful (return YES)");
    
  [self deleteDefaultUser];    
}

- (void)testObjectPull {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];  
    
  //Insert post
  DKEntity *postObject = [DKEntity entityWithName:kDKEntityTestsPost];
  NSMutableArray *values = [NSMutableArray arrayWithObjects:@"a", @"b", @"b", @"c", @"d", @"d", nil];    
  [postObject setObject:values forKey:kDKEntityTestsPostSharedTo];
  success = [postObject save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  
  //Pull object
  error = nil;
  [postObject pullObject:@"b" forKey:kDKEntityTestsPostSharedTo];
  success = [postObject save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  NSArray *list = [postObject objectForKey:kDKEntityTestsPostSharedTo];
  [values removeObject:@"b"];    
  STAssertEqualObjects(values, list, nil);
  
  //Pull all objects
  error = nil;
  [postObject pullAllObjects:@[@"c", @"d"] forKey:kDKEntityTestsPostSharedTo];
  success = [postObject save:&error];
  STAssertTrue(success, nil);
  STAssertNil(error, error.description);
  [values removeObject:@"c"];
  [values removeObject:@"d"];
  list = [postObject objectForKey:kDKEntityTestsPostSharedTo];
  STAssertEqualObjects(values, list, nil);

  //Delete post
  error = nil;
  success = [postObject delete:&error];
  STAssertNil(error, @"delete post should not return error, did return %@", error);
  STAssertTrue(success, @"delete post should have been successful (return YES)");
    
  [self deleteDefaultUser];    
}
/*
- (void)testObjectAddToSet {
    NSError *error = nil;
    BOOL success = NO;
    
    [self createDefaultUserAndLogin];
    
    //Insert post
    DKEntity *postObject = [DKEntity entityWithName:kDKEntityTestsPost];
    NSMutableArray *values = [NSMutableArray arrayWithObjects:@"b", nil];
    [postObject setObject:values forKey:kDKEntityTestsPostSharedTo];
    success = [postObject save:&error];
    STAssertTrue(success, nil);
    STAssertNil(error, error.description);
    
    //Add to set (NOT WORK, NOT DOCUMENTED IN DEPLOYD 0.6.9v, MAY WORK IN FUTURE VERSIONS)
    error = nil;
    [postObject addObjectToSet:@"d" forKey:kDKEntityTestsPostSharedTo];
    [postObject addAllObjectsToSet:[NSArray arrayWithObjects:@"a", @"b", @"c", nil] forKey:kDKEntityTestsPostSharedTo];
    [postObject addObjectToSet:@"1" forKey:kDKEntityTestsPostLocation];
    success = [postObject save:&error];
    STAssertTrue(success, nil);
    STAssertNil(error, error.description);    
    NSArray *list = [postObject objectForKey:kDKEntityTestsPostSharedTo];
    NSArray *comp = [NSArray arrayWithObjects:@"b", @"d", @"a", @"c", nil];
    STAssertEqualObjects(list, comp, nil);
    list = [postObject objectForKey:kDKEntityTestsPostLocation];
    comp = [NSArray arrayWithObjects:@"1", nil];
    STAssertEqualObjects(list, comp, nil);
        
    //Delete post
    error = nil;
    success = [postObject delete:&error];
    STAssertNil(error, @"delete post should not return error, did return %@", error);
    STAssertTrue(success, @"delete post should have been successful (return YES)");
    
    [self deleteDefaultUser];
}
*/ 
@end
