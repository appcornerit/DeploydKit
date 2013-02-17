//
//  DKNetworkActivity.h
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
 Helper class for displaying the network activity indicator
 */
@interface DKNetworkActivity : NSObject

/**
 Begin a network activity.

 Must be balanced with <end>.
 */
+ (void)begin;

/**
 End a network activity.

 Must be balanced with <begin>.
 */
+ (void)end;

/**
 Returns the number of current network activities
 @return The number of current network activities
 */
+ (NSInteger)activityCount;

@end
