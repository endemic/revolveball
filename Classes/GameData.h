//
//  GameData.h
//  Ballgame
//
//  Created by Nathan Demick on 10/15/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//
// Serializes certain game variables on exit then restores them on game load
// Taken from http://stackoverflow.com/questions/2670815/game-state-singleton-cocos2d-initwithencoder-always-returns-null

#import "cocos2d.h"
#import "SynthesizeSingleton.h"

@interface GameData : NSObject <NSCoding> 
{
	// The current level
	int currentLevel;
	
	// Variable we check to see if player quit in the middle of a level
	bool restoreLevel;
	
	// Time remaining
	int secondsLeft;

	int bestTime;
	
	bool paused;
}

@property (nonatomic) bool restoreLevel;
@property (readwrite, nonatomic) int bestTime;
@property (readwrite, nonatomic) int secondsLeft;
@property (nonatomic) bool paused;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GameData);

+ (void)loadState;
+ (void)saveState;

@end
