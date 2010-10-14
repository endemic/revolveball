//
// Demo of calling integrating Box2D physics engine with cocos2d AtlasSprites
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// by Steve Oldmeadow
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "math.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

/**
 * IDEAS
 * Create diagonal surfaces; too easy to lose momentum on totally square map
 * Remove rotation if user's fingers are too close to ball; prevents "insta-rotation"
 */

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if ((self = [super init])) 
	{
		previousAngle = currentAngle = 0;
		
		// Set accelerometer enabled
		self.isAccelerometerEnabled = YES;
		
		// Set touch enabled
		[self setIsTouchEnabled:YES];
		
		// Get window size
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// Add static background
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		[background setPosition:ccp(160, 240)];
		[self addChild:background z:0];
		
		// Create/add ball
		ball = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0,0,32,32)];
		ball.position = ccp(winSize.width / 2, winSize.height / 2);
		[self addChild:ball z:2];
		
		// Add TMX map
		map = [CCTMXTiledMap tiledMapWithTMXFile:@"Default.tmx"];
		[map setPosition:ccp(winSize.width / 2, winSize.height / 2)];
		[self addChild:map z:1];

		border = [map layerNamed:@"Border"];
		
		// Create Box2D world
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		bool doSleep = false;
		world = new b2World(gravity, doSleep);
		
		// Initialize contact listener
		world->SetContactListener(new MyContactListener);
		
		b2Vec2 vertices[3];
		int32 count = 3;
		
		for (int x = 0; x < map.mapSize.width; x++)
			for (int y = 0; y < map.mapSize.height; y++)
			{
				if ([border tileGIDAt:ccp(x, y)])
				{
					//NSLog(@"Trying to create an object with GID %i at (%i, %i)", [border tileGIDAt:ccp(x, y)], x, y);
					
					// Body
					b2BodyDef groundBodyDef;
					groundBodyDef.position.Set(x + 0.5, map.mapSize.height - y - 0.5);		// Box2D uses inverse Y of TMX maps
					//groundBodyDef.userData = [border tileAt:ccp(x, y)];		// Assign sprite to userData property
					
					b2Body *groundBody = world->CreateBody(&groundBodyDef);
					
					// Shape
					b2PolygonShape groundBox;
					
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
							vertices[0].Set(-0.5f, -0.5f);
							vertices[1].Set(0.5f, 0.5f);
							vertices[2].Set(-0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						case 5:
							// Upper right triangle
							vertices[0].Set(-0.5f, 0.5f);
							vertices[1].Set(0.5f, -0.5f);
							vertices[2].Set(0.5f, 0.5f);
							groundBox.Set(vertices, count);
							break;
						default:
							break;
					}
					
					// Fixture
					b2FixtureDef boxShapeDef;
					boxShapeDef.shape = &groundBox;
					
					groundBody->CreateFixture(&boxShapeDef);
				}
			}

		// Create ball body & shape
		b2BodyDef ballBodyDef;
		ballBodyDef.type = b2_dynamicBody;
		ballBodyDef.position.Set(8, map.mapSize.height - 2);		// Y values are inverted between TMX and Box2D
		ballBodyDef.userData = ball;		// Set to CCSprite
		body = world->CreateBody(&ballBodyDef);
		
		b2CircleShape circle;
		circle.m_radius = 15.0 / PTM_RATIO;		// Changed from 16px radius... perfectly 1m circle would get stuck in 1m gaps
		
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circle;
		ballShapeDef.density = 1.0f;
		ballShapeDef.friction = 0.2f;
		ballShapeDef.restitution = 0.6f;
		body->CreateFixture(&ballShapeDef);
		
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
		if (b->GetUserData() != NULL)
		{
			// Get the CCSprite attached to Box2D obj
			//CCSprite *ballData = (CCSprite *)b->GetUserData();

			// Update map's anchor point based on ball position; position within width/height of map?
			float anchorX = b->GetPosition().x / map.mapSize.width;
			float anchorY = b->GetPosition().y / map.mapSize.height;
			
			//NSLog(@"Anchor point is %f, %f", anchorX, anchorY);
			
			[map setAnchorPoint:ccp(anchorX, anchorY)];
		}
	}
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	//b2Vec2 gravity(-acceleration.y * 15, acceleration.x * 15);
	//world->SetGravity(gravity);
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
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

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
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

-(void)inertialRotation:(ccTime)dt
{
	NSLog(@"Trying to do inertial rotation!");
	
	int inertialDeccelleration = 0.1;
	
	float difference = currentAngle - previousAngle;
	NSLog(@"Difference: %f, %f", currentAngle, previousAngle);
	
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
	body = NULL;
	world = NULL;
	[super dealloc];
}

@end
