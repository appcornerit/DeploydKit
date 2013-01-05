//
//  DKManager.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//


/**
 The manager is used to configure common DeploydKit parameters
 */
@interface DKManager : NSObject

/** @name API Endpoint */

/**
 The API endpoint
 @return Returns the API endpoint absolute URL string
 @exception NSInternalInconsistencyException Raises exception if API endpoint is not set
 */
+ (NSString *)APIEndpoint;

/**
 Set the API endpoint
 @param absoluteString The absolute URL string for the API endpoint
 */
+ (void)setAPIEndpoint:(NSString *)absoluteString;

/**
 Returns the URL for the specified API method
 @param method The method name
 @return The method endpoint URL
 */
+ (NSURL *)endpointForMethod:(NSString *)method;

/** @name API Secret */

/**
 The API secret used for SecureUDID in DKChannel
 @return Returns the API secret string
 @exception NSInternalInconsistencyException Raises exception if API secret is not set
 */
+ (NSString *)APISecret;

/**
 Set the API secret used for SecureUDID in DKChannel
 @param secret The API secret
 */
+ (void)setAPISecret:(NSString *)secret;

/** @name Session id */

/**
 The session id
 @return Returns the session id
 */
//+ (NSString *)sessionId;

/**
 Set the session id
 @param sid The session id
 */
//+ (void)setSessionId:(NSString *)sid;

/** @name Serial Request Queue */

/**
 Dispatch queue for API requests
 @return The shared serial dispatch queue for API requests
 */
+ (dispatch_queue_t)queue;

/** @name Debug */

/**
 Enables the request log.
 
 This is useful for tracking down performance issues during development
 @param flag `YES` to enable logging, `NO` to disable
 */
+ (void)setRequestLogEnabled:(BOOL)flag;

/**
 Returns the request log status
 @return `YES` if the request log is enabled, `NO` otherwise
 */
+ (BOOL)requestLogEnabled;

/**
 Returns the reachability status
 @return `YES` if the endpoint is reachable, `NO` otherwise
 */
+ (BOOL)endpointReachable;


/** @name Controlling Caching Behavior (only used for GET requests)*/

/**
 Clears the cached results for all requests.
 */
+ (void)clearAllCachedResults;

@end
