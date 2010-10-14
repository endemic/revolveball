//
//  TitleScene.m
//  Ballgame
//
//  Created by Nathan Demick on 10/14/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "TitleScene.h"
#import "HelloWorldScene.h"

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
		
		// Add moving background
		CCSprite *background = [CCSprite spriteWithFile:@"title-screen-background.png"];
		[background setPosition:ccp(320, 240)];
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
	[[CCDirector sharedDirector] replaceScene:[CCFlipXTransition transitionWithDuration:0.75 scene:[HelloWorld scene]]];
}
@end