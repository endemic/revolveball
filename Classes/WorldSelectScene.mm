//
//  WorldSelectScene.m
//  Ballgame
//
//  Created by Nathan Demick on 12/2/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "WorldSelectScene.h"
#import "GameScene.h"
#import "GameData.h"

#define COCOS2D_DEBUG 1

@implementation WorldSelectScene

- (id)init
{
	if ((self = [super init]))
	{
		[self addChild:[WorldSelectLayer node]];
	}
	return self;
}

@end

@implementation WorldSelectLayer

- (id)init
{
	if ((self = [super init]))
	{
		// Init layer
		CGSize windowSize = [CCDirector sharedDirector].winSize;
		
		// Set up some buttons that will take the player to different game worlds
		
		CCMenuItemLabel *worldOneButton = [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString:@"World 1" fntFile:@"yoster-32.fnt"] target:self selector:@selector(playWorldOne)];
		CCMenuItemLabel *worldTwoButton = [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString:@"World 2" fntFile:@"yoster-32.fnt"] target:self selector:@selector(playWorldTwo)];
		CCMenuItemLabel *worldThreeButton = [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString:@"World 3" fntFile:@"yoster-32.fnt"] target:self selector:@selector(playWorldThree)];
		CCMenuItemLabel *worldFourButton = [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString:@"World 4" fntFile:@"yoster-32.fnt"] target:self selector:@selector(playWorldFour)];
		CCMenuItemLabel *worldFiveButton = [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString:@"World 5" fntFile:@"yoster-32.fnt"] target:self selector:@selector(playWorldFive)];
		
		// Temporarily disable these buttons, because we don't have levels go with 'em
		[worldTwoButton setIsEnabled:NO];
		[worldThreeButton setIsEnabled:NO];
		[worldFourButton setIsEnabled:NO];
		[worldFiveButton setIsEnabled:NO];
		
		// Add buttons to menu
		CCMenu *menu = [CCMenu menuWithItems:worldOneButton, worldTwoButton, worldThreeButton, worldFourButton, worldFiveButton, nil];
		[menu alignItemsVerticallyWithPadding:20.0];
		[menu setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:menu];
	}
	return self;
}

- (void)playWorldOne
{
	// Set world/level
	[GameData sharedGameData].currentWorld = 1;
	[GameData sharedGameData].currentLevel = 1;
	
	// Transition to gameplay scene
	CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameScene node]];
	[[CCDirector sharedDirector] replaceScene:transition];
}

- (void)playWorldTwo
{
	// Set world/level
	[GameData sharedGameData].currentWorld = 2;
	[GameData sharedGameData].currentLevel = 1;
	
	// Transition to gameplay scene
	CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameScene node]];
	[[CCDirector sharedDirector] replaceScene:transition];
}

- (void)playWorldThree
{
	// Set world/level
	[GameData sharedGameData].currentWorld = 3;
	[GameData sharedGameData].currentLevel = 1;
	
	// Transition to gameplay scene
	CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameScene node]];
	[[CCDirector sharedDirector] replaceScene:transition];
}

- (void)playWorldFour
{
	// Set world/level
	[GameData sharedGameData].currentWorld = 4;
	[GameData sharedGameData].currentLevel = 1;
	
	// Transition to gameplay scene
	CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameScene node]];
	[[CCDirector sharedDirector] replaceScene:transition];
}

- (void)playWorldFive
{
	// Set world/level
	[GameData sharedGameData].currentWorld = 5;
	[GameData sharedGameData].currentLevel = 1;
	
	// Transition to gameplay scene
	CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[GameScene node]];
	[[CCDirector sharedDirector] replaceScene:transition];
}
@end