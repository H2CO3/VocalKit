//
//  VKController.m
//  VocalKit
//
//  Created by Brian King on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VKController.h"
#import "VKPocketSphinxDecoder.h"
#import "VKAQRecorder.h"

NSString *const VKRecognizedPhraseNotification = @"VKRecognizedPhraseNotification";
NSString *const VKRecognizedPhraseNotificationTextKey = @"VKRecognizedPhraseNotificationTextKey";
NSString *const VKRecognizedPhraseNotificationIDKey = @"VKRecognizedPhraseNotificationIDKey";
NSString *const VKRecognizedPhraseNotificationScoreKey = @"VKRecognizedPhraseNotificationScoreKey";


@interface VKController(Private)
- (void) configureConnector;
@end


@implementation VKController


- (id) initWithType:(VKDecoderType)dType configFile:(NSString *)configFile
{
	if ((self = [super init]))
	{
		if (type == VKDecoderTypePocketSphinx)
		{
			VKPocketSphinxDecoder *psDecoder = [[VKPocketSphinxDecoder alloc] initWithConfigFile:configFile];
			decoder = psDecoder;
			type = dType;
		}
		else
		{
			NSAssert(false, @"*** VocalKit: Unsupported Decoder Type");
		}	
		[self configureConnector];
	}
	
	return self;
}


- (void) setMode:(VKDecoderMode)dMode
{
	mode = dMode;
}

- (void) setConfigString:(NSString *)str forKey:(NSString *)key
{
	VKPocketSphinxDecoder *psDecoder = (VKPocketSphinxDecoder *)decoder;
	[psDecoder setConfigString:str forKey:key];
}

- (void) setConfigInt:(int)iValue forKey:(NSString *)key
{
	VKPocketSphinxDecoder *psDecoder = (VKPocketSphinxDecoder *)decoder;
	[psDecoder setConfigInt:iValue forKey:key];	
}

- (void) setConfigFloat:(float)fValue forKey:(NSString *)key
{
	VKPocketSphinxDecoder *psDecoder = (VKPocketSphinxDecoder *)decoder;
	[psDecoder setConfigFloat:fValue forKey:key];
}

- (void) configureConnector
{
	connector = [[VKAQRecorder alloc] initWithDecorder:decoder];
}

- (void) startListening
{
	[decoder startDecode];
	[connector startListening];
}

- (void) stopListening
{
	[connector stopListening];
	[decoder stopDecode];
}

- (BOOL) isListening
{
	return [connector listening];
}

- (void) postNotificationOfRecognizedText
{
	[decoder postNotificationOfRecognizedText];
}

- (void) showListened
{
	[decoder printDebug];
}

- (void) dealloc
{
	[decoder release];
	[connector release];
	[super dealloc];
}

@end

