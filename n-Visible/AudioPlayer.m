//
//  AudioPlayer.m
//  n-Visible
//
//  Created by Gil Creque on 7/28/14.
//  Copyright (c) 2014 n-Visible.com. All rights reserved.
//
//  Based on Singleton example here http://www.galloway.me.uk/tutorials/singleton-classes/

#import "AudioPlayer.h"
#import "STKAudioPlayer.h"
#import "STKAutoRecoveringHTTPDataSource.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MixModel.h"


@implementation AudioPlayer

+ (id)sharedAudioPlayer
{
		static AudioPlayer *sharedAudioPlayer = nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
				sharedAudioPlayer = [[self alloc] init];
		});
		return sharedAudioPlayer;
}

- (id)init {
		if (self = [super init]) {
				_audioPlayer = [[STKAudioPlayer alloc] init];
		}
		
		return self;
}

- (void)playMixURL:(NSString*)mixURL
{
		if (self.audioPlayer.state == STKAudioPlayerStateRunning)
		{
				[self.audioPlayer stop];
		}
		
		NSLog(@"Song URL : %@", mixURL);
		
		[self.audioPlayer play:mixURL];
}


- (void)setupNowPlayingInfoCenter:(MixModel*)currentSong
{
		if (currentSong == nil)
		{
				[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
				return;
		}
		else
		{
		MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:currentSong.mixImage.size requestHandler:^UIImage * _Nonnull(CGSize size) {
				return currentSong.mixImage;
		}];
		
		NSMutableDictionary *nowPlayingInfo = [@{
								MPMediaItemPropertyTitle: currentSong.mixTitle,
								MPMediaItemPropertyArtwork: artwork,
								MPMediaItemPropertyArtist: currentSong.mixDJ,
								MPNowPlayingInfoPropertyPlaybackRate: @1
		} mutableCopy];
														 //[currentSong valueForKey:MPMediaItemPropertyAlbumTitle], MPMediaItemPropertyAlbumTitle,
														 //[currentSong valueForKey:MPMediaItemPropertyAlbumTrackCount], MPMediaItemPropertyAlbumTrackCount,
														 //[currentSong valueForKey:MPMediaItemPropertyAlbumTrackNumber], MPMediaItemPropertyAlbumTrackNumber,
														 //[currentSong valueForKey:MPMediaItemPropertyComposer], MPMediaItemPropertyComposer,
														 //[currentSong valueForKey:MPMediaItemPropertyDiscCount], MPMediaItemPropertyDiscCount,
														 //[currentSong valueForKey:MPMediaItemPropertyDiscNumber], MPMediaItemPropertyDiscNumber,
														 //[currentSong valueForKey:MPMediaItemPropertyGenre], MPMediaItemPropertyGenre,
														 //[currentSong valueForKey:MPMediaItemPropertyPersistentID], MPMediaItemPropertyPersistentID,
														 //[currentSong valueForKey:MPMediaItemPropertyPlaybackDuration], MPMediaItemPropertyPlaybackDuration
														 //[NSNumber numberWithInt:self.mediaCollection.nowPlayingIndex + 1], MPNowPlayingInfoPropertyPlaybackQueueIndex,
														 //[NSNumber numberWithInt:[self.mediaCollection count]], MPNowPlayingInfoPropertyPlaybackQueueCount, nil];
		
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
				
		NSLog(@"Info Set :%@", nowPlayingInfo[MPMediaItemPropertyArtist]);
		for (id key in [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo) {
				NSLog(@"key: %@, value: %@ \n", key, [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo objectForKey:key]);
				}

		}
}

- (void)setNowPlayingInfoCenterTime
{
		NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo];
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.audioPlayer.progress);
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(self.audioPlayer.duration);
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
		
		for (id key in [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo) {
				NSLog(@"key: %@, value: %@ \n", key, [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo objectForKey:key]);
		}
}

- (void)pause
{
		[self.audioPlayer pause];
}
- (void)resume
{
		[self.audioPlayer resume];
		[self setNowPlayingInfoCenterTime];
}

/*
 * Format the float time values like duration
 * to format with minutes and seconds
 */
-(NSString*)timeFormat:(float)value{
		
		float minutes = floor(lroundf(value)/60);
		float seconds = lroundf(value) - (minutes * 60);
		
		int roundedSeconds = (int) lroundf(seconds);
		int roundedMinutes = (int) lroundf(minutes);
		
		NSString *time = [[NSString alloc]
											initWithFormat:@"%d:%02d",
											roundedMinutes, roundedSeconds];
		return time;
}

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(float)value {
		[self.audioPlayer seekToTime:(double)value];
		[self setNowPlayingInfoCenterTime];
}

/*
 * Get the time where audio is playing right now
 */
- (NSTimeInterval)getCurrentAudioTime {
		return [self.audioPlayer progress];
}

/*
 * Get the whole length of the audio file
 */
- (float)getAudioDuration {
		return (float)self.audioPlayer.duration;
}

- (void)playerStateChange{
		[self setNowPlayingInfoCenterTime];
}

@end
