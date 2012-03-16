/*
 * VKManager.h
 * VocalKit
 * 
 * Originally created by Brian King
 * Modified by Árpád Goretity on 16/03/2012.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VKController.h"

@protocol VKManagerDelegate;

@interface VKManager: NSObject {
	VKController *controller;
	id <VKManagerDelegate> delegate;
}

@property (nonatomic, assign) id <VKManagerDelegate> delegate;

- (void) startListening;
- (void) stopListening;

@end


@protocol VKManagerDelegate <NSObject>
@optional
- (void) vkManager:(VKManager *)manager recognizedText:(NSString *)text;
@end

