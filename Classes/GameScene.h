//
//  GameScene.h
//  Ballgame
//
//  Created by Nathan Demick on 10/15/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "MyContactListener.h"

@interface GameScene : CCScene {}

@end

@interface GameOverLayer : CCScene 
{
	int time;
}
@end


@interface GameLayer : CCLayer 
{
	// Box2D
	b2World *world;
	MyContactListener *contactListener;
	
	CCSprite *ball;
	
	// Map
	CCTMXTiledMap *map;
	CCTMXLayer *border;
	
	// Vars for rotational touch controls
	float previousAngle, currentAngle, touchEndedAngle;
	
	// For timer
	int secondsLeft;
	CCLabel *timerLabel, *timerLabelShadow;
	
	// Boolean for quick check whether running on iPad
	bool iPad;
	
	// Base size of Box2D objects; doubles on iPad/iPhone 4 Retina Display
	int ptmRatio;
}
@end
