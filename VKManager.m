/*
 * VKManager.m
 * VocalKit
 * 
 * Originally created by Brian King
 * Modified by Árpád Goretity on 16/03/2012.
 */

#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "VKManager.h"

#define VKFrameworkBundleID @"org.h2co3.vocalkit"
#define VKFrameworkBundle [NSBundle bundleWithIdentifier:VKFrameworkBundleID]
#define VKFrameworkBundlePath [VKFrameworkBundle bundlePath]
#define VKResourcePath(dir, file) [VKFrameworkBundle pathForResource:file ofType:NULL inDirectory:dir]


@implementation VKManager

@synthesize delegate = delegate;

- (id) init
{
	if ((self = [super init]))
	{
		/*
		 * Set up the audio subsystem for recording and playing audio
		 */
		
		OSStatus error;
		error = AudioSessionInitialize(NULL, NULL, NULL, self);
		if (error)
		{
			NSLog(@"*** VocalKit: Error initializing audio session! Error code: %d", error);
			[self release];
			return NULL;
		}
		
		UInt32 category = kAudioSessionCategory_PlayAndRecord;	
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error)
		{
			NSLog(@"*** VocalKit: Error setting audio category! Error code: %d", error);
			[self release];
			return NULL;
		}
		
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error)
		{
			NSLog(@"*** VocalKit: Error getting input availability! Error code: %d", error);
			[self release];
			return NULL;
		}

		if (!inputAvailable)
		{
			NSLog(@"*** VocalKit: No audio input available!");
			[self release];
			return NULL;
		}

		error = AudioSessionSetActive(true);
		if (error)
		{
			NSLog(@"*** VocalKit: Error setting audio sessionn as active! Error code: %d", error);
			[self release];
			return NULL;
		}
		
		/*
		 * Initialize the VKController instance, and
		 * configure it for the U. S. English language model
		 */
		controller = [[VKController alloc] initWithType:VKDecoderTypePocketSphinx configFile:VKResourcePath(@"model",  @"pocketsphinx.conf")];
	
		[controller setConfigString:VKResourcePath(@"model/lm/en_US", @"cmu07a.dic") forKey:@"-dict"];
		[controller setConfigString:VKResourcePath(@"model/lm/en_US", @"wsj0vp.5000.DMP") forKey:@"-lm"];
		[controller setConfigString:[VKFrameworkBundlePath stringByAppendingPathComponent:@"model/hmm/hub4wsj_sc_8k"] forKey:@"-hmm"];
		/*
		 * And get notified when text processing is done
		 */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recognizedText:) name:VKRecognizedPhraseNotification object:NULL];
	}
	
	return self;
}

- (void) recognizedText:(NSNotification *)notification
{
	NSString *text = [[notification userInfo] objectForKey:VKRecognizedPhraseNotificationTextKey];
	if ([delegate respondsToSelector:@selector(vkManager:recognizedText:)])
	{
		[delegate vkManager:self recognizedText:text];
	}
}

/*
 * Public (API) methods
 */

- (void) startListening
{
	[controller startListening];
}

- (void) stopListening
{
	[controller stopListening];
	[controller postNotificationOfRecognizedText];
}

@end

