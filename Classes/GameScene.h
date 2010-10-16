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

@interface GameLayer : CCLayer 
{
	b2World *world;
	b2Body *body;
	CCSprite *ball;
	
	CCTMXTiledMap *map;
	CCTMXLayer *border;
	
	float previousAngle, currentAngle;
}

@end
