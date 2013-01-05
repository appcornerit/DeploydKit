//
//  DKChannel.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//

#import "DKEntity.h"
#import "DKQuery.h"

/*!
 Representation of an installation persisted to the Deployd backend. 
 DKChannel objects which have a valid deviceToken and are saved to
 the Deployd backend can be used to target push notifications.
 */
@interface DKChannel : DKEntity {
}

/** @name Accessing the Current Channel */

/*!
 Gets the currently channel 

 @result Returns a DKChannel that represents the currently installation.
 */
+ (DKChannel *)currentChannel;

/*! @name Configuring a Push Notification */

/*!
 Store the device token locally for push notifications. Usually called from you main app delegate's didRegisterForRemoteNotificationsWithDeviceToken.
 @param deviceToken Either as an NSData straight from didRegisterForRemoteNotificationsWithDeviceToken or as an NSString if you converted it yourself.
 */
+ (void)storeDeviceToken:(id)deviceToken;

/*!
 Sets the channel on which this push notification will be received.
 @param privateChannel The channel to set for received push. The channel name must start
 with a letter and contain only letters, numbers, dashes, and underscores.
 */
+ (void)storePrivateChannel:(id)privateChannel;

/*! @name Sending Push Notifications */

/*!
 Send a push message to a channel.
 @param channel The channel to set for this push. The channel name must start
 with a letter and contain only letters, numbers, dashes, and underscores.
 */
- (void)sendPushInBackground:(NSDictionary *)data channel:(NSString *)channel;

/*!
 Send a push message to more channels.
 @param channels The array of channels to set for this push. Each channel name
 must start with a letter and contain only letters, numbers, dashes, and underscores.
 */
- (void)sendPushInBackground:(NSDictionary *)data channels:(NSArray *)channels;

@end