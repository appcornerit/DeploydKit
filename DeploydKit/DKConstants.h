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

#define kDKErrorDomain @"DKErrorDomain"

enum {
  DKCachePolicyIgnoreCache = 0,
  DKCachePolicyUseCacheIfOffline = 1,
  DKCachePolicyUseCacheElseLoad = 2
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
//deployd collections for apn
#define kDKRequestPushChannel @"apn"
//deployd channel fields
#define kDKEntityChannel @"channel"
#define kDKEntityChannelUDID @"udid"
#define kDKEntityChannelBadge @"badge"
#define kDKEntityChannelPrivateChannels @"channels"
#define kDKEntityChannelAppVersion @"appVersion"
#define kDKEntityChannelDeviceToken @"deviceToken"
#define kDKEntityChannelTimeZone @"timeZone"
#define kDKEntityChannelLocale @"locale"
#define kDKEntityChannelLanguage @"language"
#define kDKEntityChannelDeviceModel @"deviceModel"
#define kDKEntityChannelDeviceSystem @"deviceSystem"
#define kDKEntityChannelLocation @"location"


