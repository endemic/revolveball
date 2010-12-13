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
#import <vector>	// Easy data structure to store Box2D bodies

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
	
	// Player
	CCSprite *ball;
	
	// Map
	CCTMXTiledMap *map;
	CCTMXLayer *border;
	
	// Vector of Box2D bodies that can be toggled off/on in a level
	std::vector<b2Body *> toggleGroup;
	
	// Vars for rotational touch controls
	float previousAngle, currentAngle, touchEndedAngle;
	
	// For time limit
	int secondsLeft;
	CCBitmapFontAtlas *timerLabel;
	
	// For countdown at start of level
	int countdownTime;
	
	// Boolean for quick check whether running on iPad
	bool iPad;
	
	// Base size of Box2D objects; doubles on iPad/iPhone 4 Retina Display
	int ptmRatio;
}

- (void)loseTime:(int)seconds;	// Method to subtract from countdown timer & display a label w/ lost time

@end
