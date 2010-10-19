//
//  GameScene.mm
//  Ballgame
//
//  Created by Nathan Demick on 10/15/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "GameScene.h"
#import "math.h"

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

@implementation GameLayer

- (id)init
{
	if ((self = [super init]))
	{
		// Check if running on iPad
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			ptmRatio = 64;
			//spriteScale = 2.0;
		}
		else
		{
		 	ptmRatio = 32;
			//spriteScale = 1.0;
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
		
		timerLabel = [CCLabel labelWithString:@"00:00" fontName:@"yoster.ttf" fontSize:16.0];
		[timerLabel setPosition:ccp(winSize.width - 30, winSize.height - 20)];
		[timerLabel setColor:ccc3(255, 255, 255)];	// White
		[timerLabel.texture setAliasTexParameters];
		[self addChild:timerLabel z:3];
		
		timerLabelShadow = [CCLabel labelWithString:@"00:00" fontName:@"yoster.ttf" fontSize:16.0];
		[timerLabelShadow setPosition:ccp(winSize.width - 29, winSize.height - 21)];
		[timerLabelShadow setColor:ccc3(0, 0, 0)];	// White
		[timerLabelShadow.texture setAliasTexParameters];
		[self addChild:timerLabelShadow z:2];
		
		// Schedule timer function for 1 second intervals
		[self schedule:@selector(timer:) interval:1];
		
		// Add static background
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		[background setPosition:ccp(160, 240)];
		[self addChild:background z:0];
		
		// Create/add ball
		ball = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0,0,32,32)];
		[ball setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[ball.texture setAliasTexParameters];
		[self addChild:ball z:2];
		
		// Add TMX map
		//map = [CCTMXTiledMap tiledMapWithTMXFile:@"Default.tmx"];
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
						case 1:
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							break;
						case 2:
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
						case 3:
							// Lower right triangle
							vertices[0].Set(-0.5f, -0.5f);
							vertices[1].Set(0.5f, -0.5f);
							vertices[2].Set(0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case 4:
							// Upper left triangle
							vertices[0].Set(-0.5f, 0.5f);
							vertices[1].Set(0.5f, -0.5f);
							vertices[2].Set(0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case 5:
							// Upper right triangle
							vertices[0].Set(-0.5f, -0.5f);
							vertices[1].Set(0.5f, 0.5f);
							vertices[2].Set(-0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case 6:
							// Goal block
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							sensorFlag = YES;
							break;
						case 7:
							groundBox.SetAsBox(0.5f, 0.5f);		// Create 1x1 box shape
							sensorFlag = YES;
							
							// Player starting location
							startPosition = ccp(x, y);
							
							// Delete tile that showed start position
							[border removeTileAt:ccp(x, y)];
							break;
						default:
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
		body = world->CreateBody(&ballBodyDef);
		
		b2CircleShape circle;
		//circle.m_radius = (((float)ptmRatio / 2) - 1) / ptmRatio;		// A 32px / 2 = 16px - 1px = 15px radius - a perfect 1m circle would get stuck in 1m gaps
		circle.m_radius = ((float)ptmRatio / 2) / ptmRatio;
		
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circle;
		ballShapeDef.density = 1.0f;
		ballShapeDef.friction = 0.2f;
		ballShapeDef.restitution = 0.6f;
		body->CreateFixture(&ballShapeDef);
		
		// Schedule updater
		[self schedule:@selector(tick:)];
	}
	return self;
}

- (void)tick:(ccTime)dt
{
	// Step through world collisions? (timeStep, velocityIterations, positionIterations)
	world->Step(dt, 10, 10);
	
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
		}
		
		// Loop thru sprite contact queue
		for (CCSprite *s in contactListener->contactQueue)
		{
			if ((CCSprite *)b->GetUserData() == s)
			{
				int tileGID = [border tileGIDAt:ccp(s.position.x / ptmRatio, map.mapSize.height - (s.position.y / ptmRatio))];	// Box2D and TMX y-coords are inverted
				switch (tileGID) 
				{
					case 1: 
						// Regular square block
						world->DestroyBody(b);
						[border removeTileAt:ccp(s.position.x / ptmRatio, map.mapSize.height - (s.position.y / ptmRatio))]
						break;
					case 6:
						// Goal tile
						break;
					default:
						break;
				}
			}
		}
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
	NSString *time = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
	
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
	//NSLog(@"Trying to do inertial rotation!");
	
	int inertialDeccelleration = 0.1;
	
	float difference = currentAngle - previousAngle;
	//NSLog(@"Difference: %f, %f", currentAngle, previousAngle);
	
	// Change rotation of map
	map.rotation -= difference;
	
	b2Vec2 gravity(sin(CC_DEGREES_TO_RADIANS(map.rotation)) * 15, -cos(CC_DEGREES_TO_RADIANS(map.rotation)) * 15);
	world->SetGravity(gravity);
	
	if (currentAngle > previousAngle)
		currentAngle -= inertialDeccelleration;
	else
		currentAngle += inertialDeccelleration;
	
	if (abs(difference) <= inertialDeccelleration)
		[self unschedule:@selector(inertialRotation:)];
}

- (void)dealloc
{
	delete world;
	delete contactListener;
	body = NULL;
	world = NULL;
	contactListener = NULL;
	[super dealloc];
}

@end