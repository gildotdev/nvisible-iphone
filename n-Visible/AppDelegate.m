//
//  AppDelegate.m
//  n-Visible
//
//  Created by Gil Creque on 7/21/14.
//  Copyright (c) 2014 n-Visible.com. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"

@interface AppDelegate ()
						

@end

@implementation AppDelegate
						
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
				// Check if the user is on a newer iPhone / iPod with a 4-inch screen
				if ([[UIScreen mainScreen] bounds].size.height == 568) {
						// The user is on a newer device with a 4-inch screen - load your custom iPhone 5 storyboard
						UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
						UIViewController *initViewController = [storyBoard instantiateInitialViewController];
						[self.window setRootViewController:initViewController];
				} else {
						// The user is on an older device with a 3.5-inch screen - load the regular storyboard
						UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainiPhone4" bundle:nil];
						UIViewController *initViewController = [storyBoard instantiateInitialViewController];
						[self.window setRootViewController:initViewController];
				}
		}
		
		
		// Override point for customization after application launch.
		
		[[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Autobahn" size:20]}];

		NSError* error;
		
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
		
		//To get remote events from lock screen
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
		[self becomeFirstResponder];
		
		return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		//AudioPlayer *playerManager = [AudioPlayer sharedAudioPlayer];
		//[playerManager pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		//AudioPlayer *playerManager = [AudioPlayer sharedAudioPlayer];
		//if (playerManager.audioPlayer.state == STKAudioPlayerStatePaused)
		//{
		//    [playerManager resume];
		//}
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		[[NSNotificationCenter defaultCenter] postNotificationName:@"appDidBecomeActive" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
		[self resignFirstResponder];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
		NSLog(@"received remote event!");
		if (receivedEvent.type == UIEventTypeRemoteControl)
		{
				AudioPlayer *playerManager = [AudioPlayer sharedAudioPlayer];
				
				switch (receivedEvent.subtype)
				{
						case UIEventSubtypeRemoteControlPlay:
								[playerManager resume];
								break;
								
						case  UIEventSubtypeRemoteControlPause:
								[playerManager pause];
								break;
								
						case  UIEventSubtypeRemoteControlNextTrack:
								// to change the video
								break;
								
						case  UIEventSubtypeRemoteControlPreviousTrack:
								// to play the privious video
								break;
								
						default:
								break;
				}
		}
}



@end
