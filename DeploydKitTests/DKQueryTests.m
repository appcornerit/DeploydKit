//
//  DKQueryTests.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQueryTests.h"
#import "DKEntity.h"
#import "DKEntity-Private.h"
#import "DKQuery.h"
#import "DKQuery-Private.h"
#import "DKManager.h"
#import "DKTests.h"
#import "DKEntityTests.h"

@implementation DKQueryTests

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

- (void)testEqualNotEqualToQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@"post1" forKey:kDKEntityTestsPostText];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@"post2" forKey:kDKEntityTestsPostText];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Fetch matching 'post1'
  error = nil;
  DKQuery *q0 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q0 whereKey:kDKEntityTestsPostText equalTo:@"post1"];
  NSArray *results = [q0 findAll:&error];
  STAssertNil(error, @"%@", error);
  STAssertEquals([results count], (NSUInteger)1, nil);
  
  DKEntity *result = [results lastObject];
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSTimeInterval createdAt = result.createdAt.timeIntervalSince1970;
  STAssertNotNil(result.entityId, nil);
  STAssertEqualsWithAccuracy(createdAt, now, 2.0, nil);
  STAssertEqualObjects([result objectForKey:kDKEntityTestsPostText], @"post1", nil);
  
  //Fetch matching not 'post1'
  error = nil;    
  DKQuery *q1 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q1 whereKey:kDKEntityTestsPostText notEqualTo:@"post1"];
  results = [q1 findAll:&error];
  STAssertNil(error, @"%@", error);
  STAssertEquals([results count], (NSUInteger)1, nil);
  result = [results lastObject];
  now = [[NSDate date] timeIntervalSince1970];
  createdAt = result.createdAt.timeIntervalSince1970;
  STAssertNotNil(result.entityId, nil);
  STAssertEqualsWithAccuracy(createdAt, now, 2.0, nil);
  STAssertEqualObjects([result objectForKey:kDKEntityTestsPostText], @"post2", nil);
  
  //Fetch all posts
  error = nil;    
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  results = [q2 findAll:&error];
  STAssertNil(error, @"%@", error);
  STAssertEquals([results count], (NSUInteger)2, nil);
  
  NSSet *matchSet = [NSSet setWithObjects:@"post1", @"post2", nil];
  NSMutableSet *nameSet = [NSMutableSet new];
  for (DKEntity *entity in results) {
    [nameSet addObject:[entity objectForKey:kDKEntityTestsPostText]];
  }
  STAssertTrue([matchSet isEqualToSet:nameSet], nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testGreaterLesserThanQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@1.5 forKey:kDKEntityTestsPostPrice];
  [postObject1 setObject:@9.3 forKey:kDKEntityTestsPostQuantity];    
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@4.3 forKey:kDKEntityTestsPostPrice];
  [postObject2 setObject:@7.0 forKey:kDKEntityTestsPostQuantity];    
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Query gt/lt
  error = nil;    
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKey:kDKEntityTestsPostPrice greaterThan:@1.0];
  [q whereKey:kDKEntityTestsPostPrice lessThan:@4.3];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostPrice], @1.5, nil);
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @9.3, nil);
  
  //Query gt/lte
  error = nil;
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q2 whereKey:kDKEntityTestsPostPrice greaterThan:@1.0];
  [q2 whereKey:kDKEntityTestsPostPrice lessThanOrEqualTo:@4.3];
  results = [q2 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  DKEntity *r1 = results[0];
  DKEntity *r2 = results[1];
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostPrice], @1.5, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostQuantity], @9.3, nil);
  STAssertEqualObjects([r2 objectForKey:kDKEntityTestsPostPrice], @4.3, nil);
  STAssertEqualObjects([r2 objectForKey:kDKEntityTestsPostQuantity], @7.0, nil);
  
  //Compound
  error = nil;
  DKQuery *q3 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q3 whereKey:kDKEntityTestsPostPrice greaterThan:@1.0];
  [q3 whereKey:kDKEntityTestsPostQuantity lessThanOrEqualTo:@7.0];
  results = [q3 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *r3 = [results lastObject];
  STAssertEqualObjects([r3 objectForKey:kDKEntityTestsPostPrice], @4.3, nil);
  STAssertEqualObjects([r3 objectForKey:kDKEntityTestsPostQuantity], @7.0, nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testOrQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@1.0 forKey:kDKEntityTestsPostVisits];
  [postObject1 setObject:@2.0 forKey:kDKEntityTestsPostPrice];
  [postObject1 setObject:@1.0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@2.0 forKey:kDKEntityTestsPostVisits];
  [postObject2 setObject:@1.0 forKey:kDKEntityTestsPostPrice];
  [postObject2 setObject:@1.0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject3 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject3 setObject:@2.0 forKey:kDKEntityTestsPostVisits];
  [postObject3 setObject:@2.0 forKey:kDKEntityTestsPostPrice];
  [postObject3 setObject:@1.0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject3 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Or
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [[q or] whereKey:kDKEntityTestsPostVisits equalTo:@1.0];
  [[q or] whereKey:kDKEntityTestsPostPrice lessThanOrEqualTo:@1.0];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  DKEntity *r0 = results[0];
  DKEntity *r1 = results[1];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostVisits], @1.0, nil);
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostPrice], @2.0, nil);
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @1.0, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostVisits], @2.0, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostPrice], @1.0, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostQuantity], @1.0, nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject3 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testAndQuery { 
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@1.0 forKey:kDKEntityTestsPostPrice];
  [postObject1 setObject:@3.0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@1.0 forKey:kDKEntityTestsPostPrice];
  [postObject2 setObject:@2.0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //And (NOT WORK, NOT DOCUMENTED IN DEPLOYD 0.6.9v, MAY WORK IN FUTURE VERSIONS)
  /*
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKey:kDKEntityTestsPostPrice equalTo:[NSNumber numberWithDouble:1.0]];
  [[q and] whereKey:kDKEntityTestsPostQuantity lessThanOrEqualTo:[NSNumber numberWithDouble:2.0]];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostPrice], [NSNumber numberWithDouble:1.0], nil);
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], [NSNumber numberWithDouble:2.0], nil);
  */
    
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testInQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@"post1" forKey:kDKEntityTestsPostText];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@"post2" forKey:kDKEntityTestsPostText];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject3 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject3 setObject:@"post3" forKey:kDKEntityTestsPostText];
  success = [postObject3 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Test contained-in
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKey:kDKEntityTestsPostText containedIn:@[@"post1", @"post2"]];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  DKEntity *r0 = results[0];
  DKEntity *r1 = results[1];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostText], @"post1", nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostText], @"post2", nil);
  
  //Test not-contained-in
  error = nil;    
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q2 whereKey:kDKEntityTestsPostText notContainedIn:@[@"post1", @"post2"]];
  error = nil;
  results = [q2 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = results[0];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostText], @"post3", nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject3 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testAllInQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@[@"user1", @"user2", @"user3"] forKey:kDKEntityTestsPostSharedTo];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@[@"user1", @"user2"] forKey:kDKEntityTestsPostSharedTo];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Test all-in
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKey:kDKEntityTestsPostSharedTo containsAllIn:@[@"user1", @"user2"]];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  DKEntity *r0 = results[0];
  DKEntity *r1 = results[1];
  NSArray *m0 = @[@"user1", @"user2", @"user3"];
  NSArray *m1 = @[@"user1", @"user2"];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostSharedTo], m0, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostSharedTo], m1, nil);
  
  //Test all-in (2)
  error = nil;
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q2 whereKey:kDKEntityTestsPostSharedTo containsAllIn:@[@"user1", @"user2", @"user3"]];
  error = nil;
  results = [q2 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = results[0];
  m0 = @[@"user1", @"user2", @"user3"];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostSharedTo], m0, nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testExistsQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@1.0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@50.0 forKey:kDKEntityTestsPostPrice];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);

  //Test exists
  error = nil;    
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKeyExists:kDKEntityTestsPostQuantity];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @1.0, nil);
    
  //Test not exists
  error = nil;
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q2 whereKeyDoesNotExist:kDKEntityTestsPostQuantity];
  results = [q2 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostPrice], @50.0, nil);
    
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testAscDescLimitSkipQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@0 forKey:kDKEntityTestsPostVisits];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@1 forKey:kDKEntityTestsPostVisits];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject3 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject3 setObject:@2 forKey:kDKEntityTestsPostVisits];
  success = [postObject3 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
    
  //Test asc
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q orderAscendingByKey:kDKEntityTestsPostVisits];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)3, nil);
  DKEntity *r0 = results[0];
  DKEntity *r1 = results[1];
  DKEntity *r2 = results[2];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostVisits], @0, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostVisits], @1, nil);
  STAssertEqualObjects([r2 objectForKey:kDKEntityTestsPostVisits], @2, nil);
  
  //Test desc
  error = nil;
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q2 orderDescendingByKey:kDKEntityTestsPostVisits];
  results = [q2 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)3, nil);
  r0 = results[0];
  r1 = results[1];
  r2 = results[2];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostVisits], @2, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostVisits], @1, nil);
  STAssertEqualObjects([r2 objectForKey:kDKEntityTestsPostVisits], @0, nil);
  
  //Test limit
  error = nil;
  DKQuery *q3 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q3 orderDescendingByKey:kDKEntityTestsPostVisits];
  [q3 setLimit:2];
  results = [q3 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)2, nil);
  r0 = results[0];
  r1 = results[1];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostVisits], @2, nil);
  STAssertEqualObjects([r1 objectForKey:kDKEntityTestsPostVisits], @1, nil);
  
  //Test skip
  error = nil;
  DKQuery *q4 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q4 orderDescendingByKey:kDKEntityTestsPostVisits];
  [q4 setSkip:2];
  error = nil;
  results = [q4 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = results[0];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostVisits], @0, nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject3 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
 
  [self deleteDefaultUser];
}

- (void)testRegexSafeString {
  DKQuery *q = [DKQuery queryWithEntityName:@"SafeRegexTest"];
  NSString *unsafeString = @"[some\\^$words.|in?*+(between)";
  NSString *expectedString = @"\\[some\\\\\\^\\$words\\.\\|in\\?\\*\\+\\(between\\)";
  NSString *safeString = [q makeRegexSafeString:unsafeString];
  STAssertEqualObjects(safeString, expectedString, @"%@", safeString);
}

- (void)testRegexQuery {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@"some words\nwith a newline\ninbetween" forKey:kDKEntityTestsPostText];
  [postObject1 setObject:@0 forKey:kDKEntityTestsPostQuantity];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@"another\nrandom regex\nstring" forKey:kDKEntityTestsPostText];
  [postObject2 setObject:@1 forKey:kDKEntityTestsPostQuantity];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Test standard regex
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKey:kDKEntityTestsPostText matchesRegex:@"\\s+words"];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @0, nil);
  
  //Test multiline regex
  error = nil;
  DKQuery *q2 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q2 whereKey:kDKEntityTestsPostText matchesRegex:@"regex$" options:DKRegexOptionMultiline];
  results = [q2 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @1, nil);
  
  //Test multiline regex fail
  error = nil;
  DKQuery *q3 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q3 whereKey:kDKEntityTestsPostText matchesRegex:@"regex$" options:0];
  results = [q3 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)0, nil);
  
  //Test dotall regex
  error = nil;
  DKQuery *q4 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q4 whereKey:kDKEntityTestsPostText matchesRegex:@"regex.*string" options:DKRegexOptionDotall];
  results = [q4 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @1, nil);
  
  //Test dotall regex fail
  error = nil;
  DKQuery *q5 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q5 whereKey:kDKEntityTestsPostText matchesRegex:@"regex.*string" options:0];
  results = [q5 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)0, nil);
  
  //Test contains string (simple regex)
  error = nil;
  DKQuery *q6 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q6 whereKey:kDKEntityTestsPostText containsString:@"newline\nin" caseInsensitive:YES];
  results = [q6 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @0, nil);
  
  //Test prefix
  error = nil;
  DKQuery *q7 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q7 whereKey:kDKEntityTestsPostText hasPrefix:@"some"];
  results = [q7 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @0, nil);
  
  //Test suffix
  error = nil;
  DKQuery *q8 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q8 whereKey:kDKEntityTestsPostText hasSuffix:@"ing"];
  results = [q8 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  r0 = [results lastObject];
  STAssertEqualObjects([r0 objectForKey:kDKEntityTestsPostQuantity], @1, nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testCountAndById {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject1 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject1 setObject:@10 forKey:kDKEntityTestsPostQuantity];
  [postObject1 setObject:@50 forKey:kDKEntityTestsPostPrice];
  success = [postObject1 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  DKEntity *postObject2 = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject2 setObject:@10 forKey:kDKEntityTestsPostQuantity];
  success = [postObject2 save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
    
  //Verify find all returns 2 objects
  error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereKey:kDKEntityTestsPostQuantity equalTo:@10];
  NSArray *results = [q findAll:&error];
  STAssertNil(error, error.localizedDescription);    
  STAssertEquals(results.count, (NSUInteger)2, nil);
  
  //Test count (NOT WORK, NOT DOCUMENTED IN DEPLOYD 0.6.9v, MAY WORK IN FUTURE VERSIONS)
  /*
  error = nil;
  DKQuery *q3 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q3 whereKey:kDKEntityTestsPostQuantity equalTo:[NSNumber numberWithInteger:10]];
  NSUInteger count = [q3 countAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(count, (NSUInteger)2, nil);
  */
    
  //Test find by id
  error = nil;
  DKQuery *q4 = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q4 whereEntityIdMatches:postObject2.entityId];
  results = [q4 findAll:&error];
  STAssertNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *r0 = results[0];
  STAssertEqualObjects(postObject2.entityId, r0.entityId, nil);
  
  //Delete posts
  error = nil;
  success = [postObject1 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
  error = nil;
  success = [postObject2 delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}

- (void)testFieldIncludeExclude {
  NSError *error = nil;
  BOOL success = NO;
    
  [self createDefaultUserAndLogin];
    
  //Insert posts
  DKEntity *postObject = [DKEntity entityWithName:kDKEntityTestsPost];
  [postObject setObject:@"post" forKey:kDKEntityTestsPostText];
  [postObject setObject:@10 forKey:kDKEntityTestsPostQuantity];
  [postObject setObject:@50 forKey:kDKEntityTestsPostPrice];
  success = [postObject save:&error];
  STAssertNil(error, error.description);
  STAssertTrue(success, nil);
  
  //Test exclude
  error = nil;    
  DKQuery *q = [DKQuery queryWithEntityName:kDKEntityTestsPost];
  [q whereEntityIdMatches:postObject.entityId];
  [q excludeKeys:@[kDKEntityTestsPostText, kDKEntityTestsPostQuantity]];
  NSArray * results = [q findAll:&error];
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *e2 = results[0];
  STAssertNil(error, error.localizedDescription);
  STAssertNotNil(e2, nil);
  STAssertNil([e2 objectForKey:kDKEntityTestsPostText], nil);
  STAssertNil([e2 objectForKey:kDKEntityTestsPostQuantity], nil);
  STAssertEqualObjects([e2 objectForKey:kDKEntityTestsPostPrice], @50, nil);
  
  //Test include
  error = nil;
  [q includeKeys:@[kDKEntityTestsPostText, kDKEntityTestsPostQuantity]];
  results = [q findAll:&error];
  STAssertEquals(results.count, (NSUInteger)1, nil);
  DKEntity *e3 = results[0];
  STAssertNil(error, error.localizedDescription);
  STAssertNotNil(e3, nil);
  STAssertEqualObjects([e3 objectForKey:kDKEntityTestsPostText], @"post", nil);
  STAssertEqualObjects([e3 objectForKey:kDKEntityTestsPostQuantity], @10, nil);
  STAssertNil([e3 objectForKey:kDKEntityTestsPostPrice], nil);
  
  //Delete post
  error = nil;
  success = [postObject delete:&error];
  STAssertNil(error, @"delete should not return error, did return %@", error);
  STAssertTrue(success, @"delete should have been successful (return YES)");
    
  [self deleteDefaultUser];
}


- (void)testQueryOnNonExistentCollection {
  NSError *error = nil;
  DKQuery *q = [DKQuery queryWithEntityName:@"NonExistentCollection"];
  [q whereKey:@"a" equalTo: @"x"];
  NSArray *results = [q findAll:&error];
  STAssertNotNil(error, error.localizedDescription);
  STAssertEquals(results.count, (NSUInteger)0, @"not nil: %@", results);
}

@end
