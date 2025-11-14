//
//  DetailViewController.m
//  n-Visible
//
//  Created by Gil Creque on 7/21/14.
//  Copyright (c) 2014 n-Visible.com. All rights reserved.
//

#import "DetailViewController.h"
#import "MixModel.h"
#import "AudioPlayer.h"
#import <FacebookSDK/FacebookSDK.h>

@interface DetailViewController ()
- (IBAction)playButtonPressed;
- (IBAction)pauseButtonPressed;
- (IBAction)resumeButtonPressed;
- (IBAction)facebookButtonPressed;
- (void)configureView;
- (void)turnOnTime;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
		if (_detailItem != newDetailItem) {
				_detailItem = newDetailItem;
				
				// Update the view.
				[self configureView];
		}
}

- (IBAction)playButtonPressed {
		[playerManager playMixURL:[self.detailItem.mixURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
		[playerManager setupNowPlayingInfoCenter:self.detailItem];
		[playerManager setCurrentSong:self.detailItem];

		[items removeLastObject];
		[items addObject:pauseButton];
		[self setToolbarItems:items animated:YES];
		self.navigationController.toolbarHidden = YES;
		self.navigationController.toolbarHidden = NO;

		[self turnOnTime];

}

-(IBAction)pauseButtonPressed
{
		[playerManager pause];
		[items removeLastObject];
		[items addObject:resumeButton];
		[self setToolbarItems:items animated:YES];
		self.navigationController.toolbarHidden = YES;
		self.navigationController.toolbarHidden = NO;
}

-(IBAction)resumeButtonPressed
{
		[playerManager resume];
		[items removeLastObject];
		[items addObject:pauseButton];
		[self setToolbarItems:items animated:YES];
		self.navigationController.toolbarHidden = YES;
		self.navigationController.toolbarHidden = NO;
}

-(void)turnOnTime{
		
		self.timeElapsed.text = @"0:00";
		self.duration.text = [NSString stringWithFormat:@"-%@",[playerManager timeFormat:[playerManager getAudioDuration]]];
		self.currentTimeSlider.maximumValue = (float)[playerManager getAudioDuration];
		NSLog(@"getDuration %f", (float)playerManager.audioPlayer.duration);
		NSLog(@"maxValue %f", self.currentTimeSlider.maximumValue);

		
		self.currentTimeSlider.hidden = NO;
		self.duration.hidden = NO;
		self.timeElapsed.hidden = NO;

		[self.timer invalidate];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
																									target:self
																								selector:@selector(updateTime:)
																								userInfo:nil
																								 repeats:YES];
}

- (IBAction)facebookButtonPressed {
		// Create an facebook object
		id<FBGraphObject> object =
		[FBGraphObject openGraphObjectForPostWithType:@"passengerpodcast:mix"
																						title:self.detailItem.mixTitle
																						image:[self.detailItem.mixImageURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
																							url:(@"http://n-visible.com/music/mixes/?mixURL=%@", [self.detailItem.mixURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]])
																			description:[NSString stringWithFormat:@"%@ - %@", self.detailItem.mixDJ, self.detailItem.mixDate]];
		
		//object[@"video"] = (@"http://n-visible.com/audioplayer/player.swf?playerID=100&soundFile=%@", [self.detailItem.mixURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
		
		// Create an action
		id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
		
		// Link the object to the action
		[action setObject:object forKey:@"mix"];
		
		// Check if the Facebook app is installed and we can present the share dialog
		FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
		params.action = action;
		params.actionType = @"passengerpodcast:listen_to";
		
		// If the Facebook app is installed and we can present the share dialog
		if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
				// Show the share dialog
				[FBDialogs presentShareDialogWithOpenGraphAction:action
																							actionType:@"passengerpodcast:listen_to"
																		 previewPropertyName:@"mix"
																								 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
																										 if(error) {
																												 // An error occurred, we need to handle the error
																												 // See: https://developers.facebook.com/docs/ios/errors
																												 NSLog(@"Error publishing story: %@", error.description);
																										 } else {
																												 // Success
																												 NSLog(@"result %@", results);
																										 }
																								 }];
		}
}


- (void)configureView
{
		// Update the user interface for the detail item.
		if (self.detailItem)
		{
				redColor = [UIColor colorWithRed:255/255.0f green:1/255.0f blue:0/255.0f alpha:1.0f];
				playerManager = [AudioPlayer sharedAudioPlayer];
				isDurationInfoSet = NO;
				
 
				self.currentTimeSlider.hidden = YES;
				self.duration.hidden = YES;
				self.timeElapsed.hidden = YES;
				
				self.mixTitleLabel.text = self.detailItem.mixTitle;
				self.mixDJLabel.text = self.detailItem.mixDJ;
				
				// Load image asynchronously
				NSURL *imageURL = [NSURL URLWithString:[self.detailItem.mixImageURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
				NSURLSessionDataTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
						if (data && !error) {
								self.detailItem.mixImage = [UIImage imageWithData:data];
								dispatch_async(dispatch_get_main_queue(), ^{
										[self.mixImageView setImage:self.detailItem.mixImage];
								});
						}
				}];
				[imageTask resume];
				
				self.mixDateLabel.text = self.detailItem.mixDate;

				
				playButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playButtonPressed)];
				[playButton setTintColor:redColor];

				pauseButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseButtonPressed)];
				[pauseButton setTintColor:redColor];

				resumeButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(resumeButtonPressed)];
				[resumeButton setTintColor:redColor];

				spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

				UIBarButtonItem *facebookButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(facebookButtonPressed)];
				[facebookButton setTintColor:redColor];
				
				items = [[NSMutableArray alloc] init];

				[items addObject:facebookButton];
				[items addObject:spacer];
				[items addObject:playButton];
				
				if (self.detailItem == playerManager.currentSong)
				{
						[self turnOnTime];
						[items removeLastObject];
						if (playerManager.audioPlayer.state == STKAudioPlayerStatePlaying || playerManager.audioPlayer.state == STKAudioPlayerStateBuffering)
						{
								[items addObject:pauseButton];
						}
						else if (playerManager.audioPlayer.state == STKAudioPlayerStatePaused)
						{
								[items addObject:resumeButton];
						}
				}

				self.toolbarItems = items;
				self.navigationController.toolbarHidden = NO;
		}
}

/*
 * Updates the time label display and
 * the current value of the slider
 * while audio is playing
 */
- (void)updateTime:(NSTimer *)timer {
		playerManager = [AudioPlayer sharedAudioPlayer];
		//to don't update every second. When scrubber is mouseDown the the slider will not set
		if (!self.scrubbing) {
				self.currentTimeSlider.value = [playerManager getCurrentAudioTime];
		}
		self.currentTimeSlider.maximumValue = (float)[playerManager getAudioDuration];
		self.timeElapsed.text = [NSString stringWithFormat:@"%@",
														[playerManager timeFormat:[playerManager getCurrentAudioTime]]];
		
		self.duration.text = [NSString stringWithFormat:@"-%@",
												 [playerManager timeFormat:[playerManager getAudioDuration] - [playerManager getCurrentAudioTime]]];

		if (!isDurationInfoSet && [playerManager getCurrentAudioTime] > 0 && [playerManager getAudioDuration] > 0)
		{
				[playerManager setNowPlayingInfoCenterTime];
				isDurationInfoSet = YES;
		}
}

/*
 * Sets the current value of the slider/scrubber
 * to the audio file when slider/scrubber is used
 */
- (IBAction)setCurrentTime:(id)scrubber {
		playerManager = [AudioPlayer sharedAudioPlayer];
		//if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it
		[NSTimer scheduledTimerWithTimeInterval:0.01
																		 target:self
																	 selector:@selector(updateTime:)
																	 userInfo:nil
																		repeats:NO];
		
		[playerManager setCurrentAudioTime:self.currentTimeSlider.value];
		
		self.scrubbing = FALSE;
}

/*
 * Sets if the user is scrubbing right now
 * to avoid slider update while dragging the slider
 */
- (IBAction)userIsScrubbing:(id)sender {
		self.scrubbing = TRUE;
}


- (void)viewDidLoad
{
		[super viewDidLoad];
		// Do any additional setup after loading the view, typically from a nib.
		
		[self configureView];
}

- (void)didReceiveMemoryWarning
{
		[super didReceiveMemoryWarning];
		// Dispose of any resources that can be recreated.
}

@end
