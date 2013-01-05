//
//  DKFile.h
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

/**
 Represents a block of binary data.
 */
@interface DKFile : NSObject

/**
 If `YES` the file is not stored on the server, `NO` otherwise.
 */
@property (nonatomic, assign, readonly) BOOL isVolatile;

/**
 If 'YES' the file is currently loading (or saving), `NO` otherwise.
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 The file name (must be unique)
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 The file data
 */
@property (nonatomic, strong, readonly) NSData *data;

/**
 The cache policy to use for the query
 */
@property (nonatomic, assign) DKCachePolicy cachePolicy;

/**
 The age after which a cached value will be ignored
 */
@property (readwrite, assign) NSTimeInterval maxCacheAge;

/** @name Creating and Initializing Files */

/**
 Creates a new file with the given data.
 
 The server will asign a random name for the file on save.
 @param data The file data
 @return The initialized file
 */
+ (DKFile *)fileWithData:(NSData *)data;

/**
 Creates a new file with the given name.
 
 You can then load the data using one of the load methods.
 @param name The filename
 @return The empty initialized file
 */
+ (DKFile *)fileWithName:(NSString *)name;

/**
 Creates a new file with the given name and data
 @param name The filename
 @param data The file data
 @return The initialized file
 */
+ (DKFile *)fileWithName:(NSString *)name data:(NSData *)data;

/**
 Initializes a new file with the given data and name.
 
 The file name must be unique, otherwise save will return an error.
 @param name The file name, if `nil` the server will assign a random name.
 @param data The file data
 @return The initialized file
 */
- (id)initWithName:(NSString *)name data:(NSData *)data;

/** @name Checking Existence */

/**
 Checks if a file with the specified name exists.
 @param fileName The file name to check
 @return `YES` if the file exists, `NO` if it doesn't
 */
+ (BOOL)fileExists:(NSString *)fileName;

/**
 Checks if a file with the specified name exists.
 @param fileName The file name to check
 @param error The error object set on error
 @return `YES` if the file exists, `NO` if it doesn't
 */
+ (BOOL)fileExists:(NSString *)fileName error:(NSError **)error;

/**
 Checks if a file with the specified name exists in the background
 @param fileName The file name to check
 @param block The result callback
 */
+ (void)fileExists:(NSString *)fileName inBackgroundWithBlock:(void (^)(BOOL exists, NSError *error))block;

/** @name Deleting Files */

/**
 Deletes the specified file
 @param fileName The file name
 @param error The error object set on error
 @return `YES` if the file was deleted, `NO` if not
 */
+ (BOOL)deleteFile:(NSString *)fileName error:(NSError **)error;

/**
 Deletes the current file
 @return `YES` if the file was deleted, `NO` if not
 */
- (BOOL)delete;

/**
 Deletes the current file
 @param error The error object set on error
 @return `YES` if the file was deleted, `NO` if not
 */
- (BOOL)delete:(NSError **)error;

/**
 Deletes the current file in the background
 @param block The result callback
 */
- (void)deleteInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))block;

/** @name Saving Files */

/**
 Saves the current file
 @return `YES` if the file was saved, otherwise `NO`.
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (BOOL)save;

/**
 Saves the current file
 @param error The error object set on error
 @return `YES` if the file was saved, otherwise `NO`.
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (BOOL)save:(NSError **)error;

/**
 Saves the current file in the background
 @param block The result block
 @exception NSInternalInconsistencyException Raised if data is not set
 */
- (void)saveInBackgroundWithBlock:(void (^)(BOOL success, NSError *error))block;

/** @name Loading Data */

/**
 Loads data for the specified filename
 @return The file data
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (NSData *)loadData;

/**
 Loads data for the specified filename
 @param error The error object set on error
 @return The file data
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (NSData *)loadData:(NSError **)error;

/**
 Loads data for the specified filename in the background
 @param block The result callback block
 @exception NSInternalInconsistencyException Raised if name is not set
 */
- (void)loadDataInBackgroundWithBlock:(void (^)(BOOL success, NSData *data, NSError *error))block;

@end
