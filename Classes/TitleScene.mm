//
//  TitleScene.m
//  Ballgame
//
//  Created by Nathan Demick on 10/14/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "TitleScene.h"
#import "WorldSelectScene.h"
#import "GameData.h"

@implementation TitleScene
- (id)init
{
	if ((self = [super init]))
	{
		[self addChild:[TitleLayer node] z:0];
	}
	return self;
}
@end

@implementation TitleLayer
- (id)init
{
	if ((self = [super init]))
	{
		[self setIsTouchEnabled:YES];
		
		CGSize windowSize = [CCDirector sharedDirector].winSize;
		
		// Add moving background
		CCSprite *background = [CCSprite spriteWithFile:@"title-screen-background.png"];
		[background setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
		[self addChild:background z:0];
		
		// Add game logo
		CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
		[logo setPosition:ccp(160, 370)];
		[self addChild:logo z:1];
		
		// Add button which takes us to game scene
		CCMenuItem *startButton = [CCMenuItemImage itemFromNormalImage:@"start-button.png" selectedImage:@"start-button.png" target:self selector:@selector(startGame:)];
		CCMenu *titleMenu = [CCMenu menuWithItems:startButton, nil];
		[titleMenu setPosition:ccp(160, 50)];
		[self addChild:titleMenu z:1];
		
		// Check if running on iPad
		if ([GameData sharedGameData].isTablet)
		{
			[background setScale:2.0];
			[background setPosition:ccp(windowSize.width / 2, windowSize.height / 2)];
			
			[logo setScale:2.0];
			[logo setPosition:ccp(320, 740)];
			
			[startButton setScale:2.0];
			[startButton setPosition:ccp(320, 100)];
		}
		
		// Run animation which moves background
		[background runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
																 [CCDelayTime actionWithDuration:1.0],
																 [CCMoveTo actionWithDuration:15.0 position:ccp(0, 240)], 
																 [CCDelayTime actionWithDuration:1.0],
																 [CCMoveTo actionWithDuration:15.0 position:ccp(320, 240)], 
																 nil]]];
	}
	return self;
}

- (void)startGame:(id)sender
{
	CCTransitionRotoZoom *transition = [CCTransitionRotoZoom transitionWithDuration:1.0 scene:[WorldSelectScene node]];
	[[CCDirector sharedDirector] replaceScene:transition];
}
@end