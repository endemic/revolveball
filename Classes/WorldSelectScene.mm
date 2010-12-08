//
//  WorldSelectScene.m
//  Ballgame
//
//  Created by Nathan Demick on 12/2/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "WorldSelectScene.h"
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

@synthesize carouselItems;

- (id)init
{
	if ((self = [super init]))
	{
		// Do stuff
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// Set up two buttons
		CCLabel *labelOne = [CCLabel labelWithString:@"Previous" fontName:@"yoster.ttf" fontSize:32.0];
		CCLabel *labelTwo = [CCLabel labelWithString:@"Next" fontName:@"yoster.ttf" fontSize:32.0];
		
		CCMenuItemLabel *prev = [CCMenuItemLabel itemWithLabel:labelOne target:self selector:@selector(carouselReverse:)];
		CCMenuItemLabel *next = [CCMenuItemLabel itemWithLabel:labelTwo target:self selector:@selector(carouselAdvance:)];
		
		CCMenu *carouselMenu = [CCMenu menuWithItems:prev, next, nil];
		[carouselMenu setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[carouselMenu alignItemsHorizontallyWithPadding:winSize.width / 2];
		
		[self addChild:carouselMenu];
		
		CCSprite *itemOne = [CCSprite spriteWithFile:@"background.png"];
		CCSprite *itemTwo = [CCSprite spriteWithFile:@"background.png"];
		CCSprite *itemThree = [CCSprite spriteWithFile:@"background.png"];
		
		carouselItems = [NSMutableArray arrayWithObjects:itemOne, itemTwo, itemThree, nil];
		
		float step = 2 * M_PI / [carouselItems count];
		float start = M_PI / 2;
		int radius = 20;
		int tilt = 10;
		
		for (uint i = 0; i < [carouselItems count]; i++)
		{
			int angle = start + i * step;
			
			int x = (winSize.width / 2) + (radius * cos(angle));
			int y = (winSize.height / 2) + tilt + sin(angle);
			
			[[carouselItems objectAtIndex:i] setScale:0.25];
			[[carouselItems objectAtIndex:i] setPosition:ccp(x, y)];
			[self addChild:[carouselItems objectAtIndex:i]];
		}
		
	}
	return self;
}

- (void)carouselAdvance:(id)sender
{
	CCLOG(@"Advance!");
}

- (void)carouselReverse:(id)sender
{
	CCLOG(@"Reverse!");
}
								 
- (void)dealloc
{
	[super dealloc];
}

@end