//
//  GameData.m
//  Ballgame
//
//  Created by Nathan Demick on 10/15/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "SynthesizeSingleton.h"
#import "GameData.h"

@implementation GameData

@synthesize currentWorld, currentLevel, restoreLevel, bestTime, secondsLeft, paused, isTablet;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameData);

- (id)init 
{
	if ((self = [super init]))
	{
		// Initialize any variables here
	}
	return self;
}

+ (void)loadState
{
	@synchronized([GameData class]) 
	{
		// just in case loadState is called before GameData inits
		if(!sharedGameData)
			[GameData sharedGameData];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		// NSString *file = [documentsDirectory stringByAppendingPathComponent:kSaveFileName];
		NSString *file = [documentsDirectory stringByAppendingPathComponent:@"GameData.bin"];
		Boolean saveFileExists = [[NSFileManager defaultManager] fileExistsAtPath:file];
		
		if(saveFileExists) 
		{
			// don't need to set the result to anything here since we're just getting initwithCoder to be called.
			// if you try to overwrite sharedGameData here, an assert will be thrown.
			[NSKeyedUnarchiver unarchiveObjectWithFile:file];
		}
	}
}

+ (void)saveState
{
	@synchronized([GameData class]) 
	{  
		GameData *state = [GameData sharedGameData];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		// NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:kSaveFileName];
		NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:@"GameData.bin"];
		
		[NSKeyedArchiver archiveRootObject:state toFile:saveFile];
	}
}

#pragma mark -
#pragma mark NSCoding Protocol Methods

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:self.currentWorld forKey:@"currentWorld"];
	[coder encodeInt:self.currentLevel forKey:@"currentLevel"];
	[coder encodeBool:self.restoreLevel forKey:@"restoreLevel"];
	[coder encodeInt:self.bestTime forKey:@"bestTime"];
	[coder encodeInt:self.secondsLeft forKey:@"secondsLeft"];
	[coder encodeBool:self.paused forKey:@"paused"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = [super init])) 
	{
		self.currentWorld = [coder decodeIntForKey:@"currentWorld"];
		self.currentLevel = [coder decodeIntForKey:@"currentLevel"];
		self.restoreLevel = [coder decodeBoolForKey:@"restoreLevel"];
		self.bestTime = [coder decodeIntForKey:@"bestTime"];
		self.secondsLeft = [coder decodeIntForKey:@"secondsLeft"];
		self.paused = [coder decodeBoolForKey:@"paused"];
	}
	return self;
}

@end
