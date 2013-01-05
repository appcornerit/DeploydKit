//
//  DKEntity.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKConstants.h"

@class DKEntity;

/**
 A DKEntity represents an object stored in the collection with the given name.
 
 @warning *Important*: `$` and `.` characters cannot be used in object keys
 */
@interface DKEntity : NSObject

/** @name Getting Entity Info */

/**
 The name of the entity collection
 */
@property (nonatomic, copy, readonly) NSString *entityName;

/**
 The entity ID
 */
@property (nonatomic, readonly) NSString *entityId;

/**
 The update date
 */
@property (nonatomic, readonly) NSDate *updatedAt;

/**
 The creation date
 */
@property (nonatomic, readonly) NSDate *createdAt;

/**
 `YES` if the entity has not been saved, `NO` otherwise
 */
@property (nonatomic, readonly) BOOL isNew;

/**
 `YES` if changes have been made to the entity since last save, `NO` otherwise
 */
@property (nonatomic, readonly) BOOL isDirty;

/**
  User creation about the entity.
 */
@property (nonatomic, readonly) id creatorId;

/**
 The cache policy to use for the query
 */
@property (nonatomic, assign) DKCachePolicy cachePolicy;

/**
 The age after which a cached value will be ignored
 */
@property (readwrite, assign) NSTimeInterval maxCacheAge;

/** @name Creating and Initializing Entities */

/**
 Create entity with given name
 @param entityName The entity name
 @return The initialized entity
 */
+ (DKEntity *)entityWithName:(NSString *)entityName;

/**
 Initialize a new entity
 @param entityName The entity name
 @return The initialized entity
 */
- (id)initWithName:(NSString *)entityName;

/** @name Saving Entities */

/**
 Saves the entity
 @return `YES` on success, `NO` on error
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (BOOL)save;

/**
 Saves the entity
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (BOOL)save:(NSError **)error;

/**
 Saves the entity in the background
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (void)saveInBackground;

/**
 Saves the entity in the background and invokes callback on completion
 @param block The save callback block
 @exception NSInvalidArgumentException Raised if any key contains an `$` or `.` character.
 */
- (void)saveInBackgroundWithBlock:(void (^)(DKEntity *entity, NSError *error))block;

/** @name Refreshing Entities */

/**
 Refreshes the entity
 
 Refreshes the entity with data stored on the server.
 @return `YES` on success, `NO` on error
 */
- (BOOL)refresh;

/**
 Refreshes the entity
 
 Refreshes the entity with data stored on the server.
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 */
- (BOOL)refresh:(NSError **)error;

/**
 Refreshes the entity in the background
 
 Refreshes the entity with data stored on the server.
 */
- (void)refreshInBackground;

/**
 Refreshes the entity in the background and invokes the callback on completion
 
 Refreshes the entity with data stored on the server.
 @param block The callback block
 */
- (void)refreshInBackgroundWithBlock:(void (^)(DKEntity *entity, NSError *error))block;

/** @name Deleting Entities */

/**
 Deletes the entity
 @return `YES` on success, `NO` on error
 */
- (BOOL)delete;

/**
 Deletes the entity
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 */
- (BOOL)delete:(NSError **)error;

/**
 Deletes the entity in the background
 */
- (void)deleteInBackground;

/**
 Deletes the entity in the background and invokes the callback block on completion
 @param block The callback block
 */
- (void)deleteInBackgroundWithBlock:(void (^)(DKEntity *entity, NSError *error))block;

/** @name Getting Objects*/

/**
 Gets the object stored at `key`.
 
 If the key does not exist in the saved object, tries to return a value from the unsaved changes.
 @param key The object key
 @return The object or `nil` if no object is set for `key`
 */
- (id)objectForKey:(NSString *)key;

/** @name Modifying Objects*/

/**
 Sets the object on a given `key`
 
 The object must be of type NSString, NSNumber, NSArray, NSDictionary, NSNull
 @param object The object to store
 @param key The object key
 @warning The key must not include an `$` or `.` character
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 Pushes (appends) the object to the list at `key`.
 
 Appends the object if a list exists at `key`, otherwise sets a single elemenet list containing `object` on `key`. If the `key` exists, but is not a list, the entity save will fail. Object must be a *JSON* type.
 @param object The object to push
 @param key The list key
 @warning The key must not include an `$` or `.` character
 */
- (void)pushObject:(id)object forKey:(NSString *)key;

/**
 Pushes (appends) all objects to the list at `key`
 
 Appends the objects if a list exists at `key`, otherwise sets `key` to the `objects` list. If the `key` exists, but is not a list, the entity save will fail. List may only contain *JSON* types.
 @param objects The object list
 @param key The list key
 @warning The key must not include an `$` or `.` character
 */
- (void)pushAllObjects:(NSArray *)objects forKey:(NSString *)key;

/**
 Removes all occurrences of object from the list at `key`
 
 If the `key` exists, but is not a list, entity save will fail.
 @param object The object to remove
 @param key The list key
 */
- (void)pullObject:(id)object forKey:(NSString *)key;

/**
 Removes all occurrences of objects from the list at `key`
 
 If the `key` exists, but is not a list, entity save will fail.
 @param objects The objects to remove
 @param key The list key
 */
- (void)pullAllObjects:(NSArray *)objects forKey:(NSString *)key;

/**
 Increments the number at `key` by `1`
 @param key The key to increment
 */
- (void)incrementKey:(NSString *)key;

/**
 Increments the number at `key` by `amount`
 @param key The key to increment 
 @param amount The increment amount. Can also be negative
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount;

/**
 Adds the object to the list at `key`, if it is not already in the list.
 (NOT WORK, NOT DOCUMENTED IN DEPLOYD 0.6.9v, MAY WORK IN FUTURE VERSIONS)  
 Appends the objects if a list exists at `key` and `object` is not already in that list, otherwise sets `key` to a single object array containing `object`. 
 If the `key` exists, but is not a list, the entity save will fail. List may only contain *JSON* types.
 @param object The object to add
 @param key The list key
 @warning The key must not include an `$` or `.` character
 */
//- (void)addObjectToSet:(id)object forKey:(NSString *)key;

/**
 Adds all objects to the list at `key`, if object is not already in the list.
 (NOT WORK, NOT DOCUMENTED IN DEPLOYD 0.6.9v, MAY WORK IN FUTURE VERSIONS)  
 Adds the objects to the list only if the objects do not already exist in the list and if `key` is a list, otherwise sets `key` to a list containting `objects`. 
 If the `key` is present, but not a list, entity save will fail. All objects in the list must be *JSON* types.
 @param objects The object list
 @param key The list key
 @warning The key must not include an `$` or `.` character
 */
//- (void)addAllObjectsToSet:(NSArray *)objects forKey:(NSString *)key;

/**
 Resets the entity to it's last saved state
 */
- (void)reset;

/** @name User collection methods */

/**
 Log in a user
 @param error The error object to be set on error
 @param username The username for login the user 
 @param password The password for login the user 
 @return `YES` on success, `NO` on error
 */
- (BOOL)login:(NSError **)error username:(NSString*)username password:(NSString*)password;

/**
 Log out a user
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 */
- (BOOL)logout:(NSError **)error;

/**
 Return if the current user is logged
 @param error The error object to be set on error
 @return `YES` on success, `NO` on error
 */
- (BOOL)loggedUser:(NSError **)error;

+ (id)new UNAVAILABLE_ATTRIBUTE;
- (id)init UNAVAILABLE_ATTRIBUTE;
@end