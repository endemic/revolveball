//
//  GameScene.mm
//  Ballgame
//
//  Created by Nathan Demick on 10/15/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "GameScene.h"
#import "GameData.h"
#import "math.h"
#import <vector>	// Easy data structure to store Box2D bodies

// Constants for tile GIDs
#define kSquare 1
#define kLowerLeftTriangle 2
#define kLowerRightTriangle 3
#define kUpperLeftTriangle 4
#define kUpperRightTriangle 5
#define kGoal 6
#define kPlayerStart 7

#define kDownSpikes 22
#define kLeftSpikes 23
#define kRightSpikes 24
#define kUpSpikes 25

#define kDownBoost 38
#define kLeftBoost 39
#define kRightBoost 40
#define kUpBoost 41

#define kBreakable 100

@implementation GameScene
- (id)init
{
	if ((self = [super init]))
	{
		// Add game layer
		[self addChild:[GameLayer node] z:0];
	}
	return self;
}
@end

@implementation GameOverLayer

- (id)init
{
	if ((self = [super init]))
	{
		// Get window size
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// Do stuff
		CCBitmapFontAtlas *finishLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"FINISH!" fntFile:@"yoster-48.fnt"];
		[finishLabel setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[self addChild:finishLabel z:1];
		
//		CCLabel *finishLabel = [CCLabel labelWithString:@"FINISH!" fontName:@"yoster.ttf" fontSize:48.0];
//		[finishLabel setColor:ccc3(255, 255, 255)];
//		[finishLabel setPosition:ccp(winSize.width / 2, winSize.height / 2)];
//		[self addChild:finishLabel z:1];
//		
//		CCLabel *finishLabelShadow = [CCLabel labelWithString:@"FINISH!" fontName:@"yoster.ttf" fontSize:48.0];
//		[finishLabelShadow setColor:ccc3(0, 0, 0)];
//		[finishLabelShadow setPosition:ccp((winSize.width / 2) - 2, (winSize.height / 2) - 2)];
//		[self addChild:finishLabelShadow z:0];
		
		// Display your time/best time
		int bestTime = [GameData sharedGameData].bestTime;
		int minutes = floor(bestTime / 60);
		int seconds = bestTime % 60;
		
		CCBitmapFontAtlas *bestTimeLabel = [CCBitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"Best time: %i:%02d", minutes, seconds] fntFile:@"yoster-32.fnt"];
		[bestTimeLabel setPosition:ccp(winSize.width / 2, winSize.height / 2 - 50)];
		[self addChild:bestTimeLabel z:1];
		
//		CCLabel *bestTimeLabel = [CCLabel labelWithString:[NSString stringWithFormat:@"Best time: %i:%02d", minutes, seconds] fontName:@"yoster.ttf" fontSize:32.0];
//		[bestTimeLabel setColor:ccc3(255, 255, 255)];
//		[bestTimeLabel setPosition:ccp(winSize.width / 2, winSize.height / 2 - 50)];
//		[bestTimeLabel.texture setAliasTexParameters];
//		[self addChild:bestTimeLabel z:1];
		
		
		// Add button which takes us to game scene
		CCMenuItem *startButton = [CCMenuItemImage itemFromNormalImage:@"start-button.png" selectedImage:@"start-button.png" target:self selector:@selector(restartGame:)];
		CCMenu *titleMenu = [CCMenu menuWithItems:startButton, nil];
		[titleMenu setPosition:ccp(160, 50)];
		[self addChild:titleMenu z:1];
	}
	return self;
}

- (void)restartGame:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CCFlipXTransition transitionWithDuration:0.75 scene:[GameScene node]]];
}

@end


@implementation GameLayer

- (id)init
{
	if ((self = [super init]))
	{
		// Check if running on iPad
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			iPad = YES;
			ptmRatio = 64;
		}
		else
		{
			iPad = NO;
			ptmRatio = 32;
		}
		
		previousAngle = currentAngle = 0;
		
		// Set accelerometer enabled
		self.isAccelerometerEnabled = YES;
		
		// Set touch enabled
		[self setIsTouchEnabled:YES];
		
		// Get window size
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// Set up timer
		secondsLeft = 3 * 60;	// Three minutes?!
		
		if (![GameData sharedGameData].bestTime)
			[GameData sharedGameData].bestTime = 0;
		
		timerLabel = [CCLabel labelWithString:@"3:00" fontName:@"yoster.ttf" fontSize:16.0];
		[timerLabel setPosition:ccp(winSize.width - 30, winSize.height - 20)];
		[timerLabel setColor:ccc3(255, 255, 255)];	// White
		[timerLabel.texture setAliasTexParameters];
		[self addChild:timerLabel z:3];
		
		timerLabelShadow = [CCLabel labelWithString:@"3:00" fontName:@"yoster.ttf" fontSize:16.0];
		[timerLabelShadow setPosition:ccp(winSize.width - 29, winSize.height - 21)];
		[timerLabelShadow setColor:ccc3(0, 0, 0)];	// White
		[timerLabelShadow.texture setAliasTexParameters];
		[self addChild:timerLabelShadow z:2];
				
		// Add static background
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		[background setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[self addChild:background z:0];
		
		// Create/add ball
		if (iPad)
			ball = [CCSprite spriteWithFile:@"ball-hd.png"];
		else
			ball = [CCSprite spriteWithFile:@"ball.png"];
		[ball setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[ball.texture setAliasTexParameters];
		[self addChild:ball z:2];
		
		// Add TMX map
		//map = [CCTMXTiledMap tiledMapWithTMXFile:@"Default.tmx"];
		if (iPad)
			map = [CCTMXTiledMap tiledMapWithTMXFile:@"test-hd.tmx"];
		else
			map = [CCTMXTiledMap tiledMapWithTMXFile:@"test.tmx"];
		[map setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[self addChild:map z:1];
		
		border = [[map layerNamed:@"Border"] retain];
				
		// Create Box2D world
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		bool doSleep = false;
		world = new b2World(gravity, doSleep);
		
		// Initialize contact listener
		contactListener = new MyContactListener();
		world->SetContactListener(contactListener);
		
		b2Vec2 vertices[3];
		int32 count = 3;
		CGPoint startPosition;
		bool sensorFlag;
		
		for (int x = 0; x < map.mapSize.width; x++)
			for (int y = 0; y < map.mapSize.height; y++)
			{
				if ([border tileGIDAt:ccp(x, y)])
				{
					//NSLog(@"Trying to interpret an object with GID %i at (%i, %i)", [border tileGIDAt:ccp(x, y)], x, y);
					
					// Body
					b2BodyDef groundBodyDef;
					groundBodyDef.position.Set(x + 0.5, map.mapSize.height - y - 0.5);		// Box2D uses inverse Y of TMX maps
					groundBodyDef.userData = [border tileAt:ccp(x, y)];		// Assign sprite to userData property
					
					b2Body *groundBody = world->CreateBody(&groundBodyDef);
					
					// Shape
					b2PolygonShape groundBox;
					
					// Default sensor flag to false
					sensorFlag = NO;
					
					switch ([border tileGIDAt:ccp(x, y)]) 
					{
						case kSquare:
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							break;
						case kLowerLeftTriangle:
							// Lower left triangle
							vertices[0].Set(-0.5f, -0.5f);
							vertices[1].Set(0.5f, -0.5f);
							vertices[2].Set(-0.5f, 0.5f);
							
							groundBox.Set(vertices, count);
							//NSLog(@"Trying to create a triangle at %i, %i", x, y);
							
							//groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(1,0));
							//groundBox.SetAsEdge(b2Vec2(1,0), b2Vec2(0,1));
							//groundBox.SetAsEdge(b2Vec2(0,1), b2Vec2(0,0));
							break;
						case kLowerRightTriangle:
							// Lower right triangle
							vertices[0].Set(-0.5f, -0.5f);
							vertices[1].Set(0.5f, -0.5f);
							vertices[2].Set(0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case kUpperLeftTriangle:
							// Upper left triangle
							vertices[0].Set(-0.5f, 0.5f);
							vertices[1].Set(0.5f, -0.5f);
							vertices[2].Set(0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case kUpperRightTriangle:
							// Upper right triangle
							vertices[0].Set(-0.5f, -0.5f);
							vertices[1].Set(0.5f, 0.5f);
							vertices[2].Set(-0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case kGoal:
							// Goal block
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							sensorFlag = YES;
							break;
						case kPlayerStart:
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							sensorFlag = YES;
							
							// Player starting location
							startPosition = ccp(x, y);
							
							// Delete tile that showed start position
							[border removeTileAt:ccp(x, y)];
							groundBodyDef.userData = NULL;
							break;
						case kDownBoost:
						case kLeftBoost:
						case kRightBoost:
						case kUpBoost:
							groundBox.SetAsBox(0.4f, 0.4f);		// Create smaller than 1x1 box shape, so player has to overlap the tile slightly
							sensorFlag = YES;
							break;
						case kDownSpikes:
						case kLeftSpikes:
						case kRightSpikes:
						case kUpSpikes:
							groundBox.SetAsBox(0.5f, 0.5f);
							break;
						default:
							// Default is to create sensor that then triggers an NSLog that tells us we're missing something
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							sensorFlag = YES;
							break;
					}
					
					// Fixture
					b2FixtureDef boxShapeDef;
					boxShapeDef.shape = &groundBox;
					boxShapeDef.isSensor = sensorFlag;
					
					groundBody->CreateFixture(&boxShapeDef);
				}
			}
		
		// Create ball body & shape
		b2BodyDef ballBodyDef;
		ballBodyDef.type = b2_dynamicBody;
		//ballBodyDef.position.Set(startPosition.x + 0.5, map.mapSize.height - startPosition.y - 0.5);		// Y values are inverted between TMX and Box2D
		
		// For some reason, this always fucks up
		ballBodyDef.position.Set(3, map.mapSize.height - 3);
		
		ballBodyDef.userData = ball;		// Set to CCSprite
		b2Body *ballBody = world->CreateBody(&ballBodyDef);
		
		b2CircleShape circle;
		//circle.m_radius = (((float)ptmRatio / 2) - 1) / ptmRatio;		// A 32px / 2 = 16px - 1px = 15px radius - a perfect 1m circle would get stuck in 1m gaps
		circle.m_radius = ((float)ptmRatio / 2) / ptmRatio;
		
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circle;
		ballShapeDef.density = 1.0f;
		ballShapeDef.friction = 0.2f;
		ballShapeDef.restitution = 0.6f;
		ballBody->CreateFixture(&ballShapeDef);
		
		// Set default map anchor point - Need to do this here once so the map actually appears around the ball
		float anchorX = ballBody->GetPosition().x / map.mapSize.width;
		float anchorY = ballBody->GetPosition().y / map.mapSize.height;
		[map setAnchorPoint:ccp(anchorX, anchorY)];
		
		// Schedule countdown timer
		countdownTime = 3;
		[self schedule:@selector(countdown:) interval:1.0];
	}
	return self;
}

- (void)countdown:(ccTime)dt
{
	// Get window size
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	NSString *text;
	if (countdownTime == 0)
		text = @"GO";
	else
		text = [NSString stringWithFormat:@"%i", countdownTime];
	
	CCLabel *countdownLabel = [CCLabel labelWithString:text fontName:@"yoster.ttf" fontSize:48.0];
	[countdownLabel setPosition:ccp(winSize.width / 2, winSize.height / 2)];
	[countdownLabel setColor:ccc3(255, 255, 255)];	// White
	[countdownLabel.texture setAliasTexParameters];
	[self addChild:countdownLabel z:3];
	
	// Move and fade actions
	id moveAction = [CCMoveTo actionWithDuration:1 position:ccp(ball.position.x, ball.position.y + 64)];
	id fadeAction = [CCFadeOut actionWithDuration:1];
	id removeAction = [CCCallFuncN actionWithTarget:self selector:@selector(removeSpriteFromParent:)];
	
	[countdownLabel runAction:[CCSequence actions:[CCSpawn actions:moveAction, fadeAction, nil], removeAction, nil]];
	
	countdownTime--;
	
	if (countdownTime == -1)
	{
		// Unschedule self
		[self unschedule:@selector(countdown:)];
		
		// Schedule regular game loop
		[self schedule:@selector(tick:)];
		
		// Schedule timer function for 1 second intervals
		[self schedule:@selector(timer:) interval:1];
	}
}

- (void)tick:(ccTime)dt
{
	// Step through world collisions - (timeStep, velocityIterations, positionIterations)
	world->Step(dt, 10, 10);
	
	// Vector containing Box2D bodies to be destroyed
	std::vector<b2Body *> discardedItems;
	
	// Local convenience variable
	b2Body *ballBody;
	
	for (b2Body *b = world->GetBodyList(); b; b = b->GetNext()) 
	{
		//if (b->GetUserData() != NULL)
		if ((CCSprite *)b->GetUserData() == ball)
		{
			// Get the CCSprite attached to Box2D obj
			CCSprite *ballSprite = (CCSprite *)b->GetUserData();
			ballSprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			
			// Update map's anchor point based on ball position; position within width/height of map?
			float anchorX = b->GetPosition().x / map.mapSize.width;
			float anchorY = b->GetPosition().y / map.mapSize.height;
			
			//NSLog(@"Anchor point is %f, %f", anchorX, anchorY);
			
			[map setAnchorPoint:ccp(anchorX, anchorY)];
			
			ballBody = b;
		}
		
		// Loop thru sprite contact queue
		for (CCSprite *s in contactListener->contactQueue)
		{
			// Ignore when ball is in contact queue
			if ((CCSprite *)b->GetUserData() == ball)
				continue;
			
			// Process all other objects
			if ((CCSprite *)b->GetUserData() == s)
			{
				int tileGID = [border tileGIDAt:ccp(s.position.x / ptmRatio, map.mapSize.height - (s.position.y / ptmRatio) - 1)];	// Box2D and TMX y-coords are inverted
				//NSLog(@"GID of touched tile %i at map location %f, %f", tileGID, s.position.x / ptmRatio, map.mapSize.height - (s.position.y / ptmRatio) - 1);
				
				switch (tileGID) 
				{
					case kSquare:
					case kUpperLeftTriangle:
					case kUpperRightTriangle:
					case kLowerLeftTriangle:
					case kLowerRightTriangle:
						// Regular blocks - do nothing
						break;
					case kBreakable:
						discardedItems.push_back(b);
						
						// Plan for breakable blocks:
						// 1. Create 4 quarter-sized blocks in the same space as the broken block
						// 2. Set them to animate/disappear based on current Box2D world gravity
						// 3. Breakable block is then automatically removed
						break;
					case kGoal:
						{
						[self unschedule:@selector(tick:)];		// Need a better way of determining the end of a level
						[self unschedule:@selector(timer:)];
						
						// Figure out best time (for prototype only)
						int bestTime = [GameData sharedGameData].bestTime;
						NSLog(@"Best time is %i", bestTime);
						
						// Overwrite the best time value
						if (secondsLeft > bestTime)
							[GameData sharedGameData].bestTime = secondsLeft;
						
						// Add "Game Over" layer
						[self addChild:[GameOverLayer node] z:4];
						}
						break;
					case kDownBoost:
						ballBody->ApplyLinearImpulse(b2Vec2(0.0f, -1.0f), ballBody->GetPosition());
						break;
					case kLeftBoost:
						ballBody->ApplyLinearImpulse(b2Vec2(-1.0f, 0.0f), ballBody->GetPosition());
						break;
					case kRightBoost:
						ballBody->ApplyLinearImpulse(b2Vec2(1.0f, 0.0f), ballBody->GetPosition());
						break;
					case kUpBoost:
						ballBody->ApplyLinearImpulse(b2Vec2(0.0f, 1.0f), ballBody->GetPosition());
						break;
					case kDownSpikes:
					case kLeftSpikes:
					case kRightSpikes:
					case kUpSpikes:
						{
						// Lose time
						secondsLeft -= 5;
						
						// Create a label that shows how much time you lost
						CCLabel *deductedTimeLabel = [CCLabel labelWithString:@"-5 seconds" fontName:@"yoster.ttf" fontSize:16];
						[deductedTimeLabel setPosition:ccp(ball.position.x, ball.position.y + 16)];
						[deductedTimeLabel setColor:ccc3(255,255,255)];		// White
						[deductedTimeLabel.texture setAliasTexParameters];
						[self addChild:deductedTimeLabel z:5];
						
						// Move and fade actions
						id moveAction = [CCMoveTo actionWithDuration:1 position:ccp(ball.position.x, ball.position.y + 64)];
						id fadeAction = [CCFadeOut actionWithDuration:1];
						id removeAction = [CCCallFuncN actionWithTarget:self selector:@selector(removeSpriteFromParent:)];
						
						[deductedTimeLabel runAction:[CCSequence actions:[CCSpawn actions:moveAction, fadeAction, nil], removeAction, nil]];
						
						// Make invincible so touching spikes again doesn't immediately drain the timer
						}
						break;
					default:
						NSLog(@"Touching unrecognized tile GID: %i", tileGID);
						break;
				}
			}
		}
	}
	
	// Remove any Box2D bodies in "discardedItems" vector
	std::vector<b2Body *>::iterator position;
	for (position = discardedItems.begin(); position != discardedItems.end(); ++position) 
	{
		b2Body *body = *position;     
		if (body->GetUserData() != NULL) 
		{
			CCSprite *sprite = (CCSprite *)body->GetUserData();
			[border removeChild:sprite cleanup:YES];
		}
		world->DestroyBody(body);
	}
}

/**
 Update the game timer
 */
- (void)timer:(ccTime)dt
{
	secondsLeft--;
	
	int minutes = floor(secondsLeft / 60);
	int seconds = secondsLeft % 60;
	NSString *time = [NSString stringWithFormat:@"%i:%02d", minutes, seconds];
	
	[timerLabel setString:time];
	[timerLabelShadow setString:time];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	//b2Vec2 gravity(-acceleration.y * 15, acceleration.x * 15);
	//world->SetGravity(gravity);
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if (touch)
	{		
		// Get window size
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// Convert location
		CGPoint touchPoint = [touch locationInView:[touch view]];
		
		currentAngle = currentAngle = CC_RADIANS_TO_DEGREES(atan2(winSize.width / 2 - touchPoint.x, winSize.height / 2 - touchPoint.y));
		
		if (currentAngle < 0) currentAngle += 360;
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if (touch)
	{
		// Get window size
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// Convert location
		CGPoint touchPoint = [touch locationInView:[touch view]];
		
		previousAngle = currentAngle;
		
		currentAngle = CC_RADIANS_TO_DEGREES(atan2(winSize.width / 2 - touchPoint.x, winSize.height / 2 - touchPoint.y));
		
		if (currentAngle < 0) currentAngle += 360;
		
		float difference = currentAngle - previousAngle;
		
		// Change rotation of map
		map.rotation -= difference;
		
		b2Vec2 gravity(sin(CC_DEGREES_TO_RADIANS(map.rotation)) * 15, -cos(CC_DEGREES_TO_RADIANS(map.rotation)) * 15);
		world->SetGravity(gravity);
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if (touch)
	{
		// Determine whether to do intertial rotation here
		/*
		// Get window size
		CGSize winSize = [CCDirector sharedDirector].winSize;

		// Convert location
		CGPoint touchPoint = [touch locationInView:[touch view]];

		previousAngle = currentAngle;

		currentAngle = CC_RADIANS_TO_DEGREES(atan2(winSize.width / 2 - touchPoint.x, winSize.height / 2 - touchPoint.y));

		if (currentAngle < 0) currentAngle += 360;

		float difference = currentAngle - previousAngle;
		*/
		// If map was rotating fast enough when the player lifted their finger, schedule a function that continues to rotate but slows down over time
		//[self schedule:@selector(inertialRotation:)];
	}
}

- (void)inertialRotation:(ccTime)dt
{
	// Current idea w/ inertial rotation is to modify the decelleration so that it takes place over a constant time; i.e. 1s
	// That way the effect doesn't become too disorienting
	// Plus the effect will only fire if the previousAngle vs. currentAngle value is above a certain amount
	
	float inertialDeccelleration = 0.1;
	
	//previousAngle = currentAngle;
	
	if (currentAngle > previousAngle)
		currentAngle -= inertialDeccelleration;
	else
		currentAngle += inertialDeccelleration;
	
	float difference = currentAngle - previousAngle;
	NSLog(@"Difference: %f, %f", currentAngle, previousAngle);
	
	// Change rotation of map
	map.rotation -= difference;
	
	b2Vec2 gravity(sin(CC_DEGREES_TO_RADIANS(map.rotation)) * 15, -cos(CC_DEGREES_TO_RADIANS(map.rotation)) * 15);
	world->SetGravity(gravity);
	
	if (abs(difference) <= inertialDeccelleration)
		[self unschedule:@selector(inertialRotation:)];
}

- (void)removeSpriteFromParent:(CCNode *)sprite
{
	//[sprite.parent removeChild:sprite cleanup:YES];
	
	// Trying this from forum post http://www.cocos2d-iphone.org/forum/topic/981#post-5895
	// Apparently fixes a memory error?
	CCNode *parent = sprite.parent;
	[sprite retain];
	[parent removeChild:sprite cleanup:YES];
	[sprite autorelease];
}

- (void)dealloc
{
	delete world;
	delete contactListener;
	world = NULL;
	contactListener = NULL;
	[super dealloc];
}

@end