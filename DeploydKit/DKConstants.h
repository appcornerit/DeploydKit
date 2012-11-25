//
//  DKConstants.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDKErrorDomain @"DKErrorDomain"

enum {
  DKCachePolicyIgnoreCache = NSURLRequestReloadIgnoringLocalCacheData,
  DKCachePolicyUseCacheElseLoad = NSURLRequestReturnCacheDataElseLoad,
  DKCachePolicyUseCacheDontLoad = NSURLRequestReturnCacheDataDontLoad
};
typedef NSInteger DKCachePolicy;

enum {
  DKErrorNone = 0,
  DKErrorInvalidParams = 100,
  DKErrorOperationFailed = 101,
  DKErrorOperationNotAllowed = 102,
  DKErrorDuplicateKey = 103,
  DKErrorConnectionFailed = 200,
  DKErrorInvalidResponse,
  DKErrorUnknownStatus
};
typedef NSInteger DKError;

enum {
  DKRegexOptionCaseInsensitive = (1 << 0),
  DKRegexOptionMultiline = (1 << 1),
  DKRegexOptionDotall = (1 << 2)
};
typedef NSInteger DKRegexOption;

//deployd collections for files handle on Amazon S3
#define kDKRequestFileHandler @"s3bucket"
#define kDKRequestFileCollection @"files"
//deployd field name of files collection
#define kDKRequestAssignedFileName @"fileName"
//deployd user fields for login
#define kDKEntityUserName @"username"
#define kDKEntityUserPassword @"password"
//deployd fields name for all collections
#define kDKEntityIDField @"id"
#define kDKEntityUpdatedAtField @"updatedAt"
#define kDKEntityCreatedAtField @"createdAt"
#define kDKEntityCreatorIdField @"creatorId"

