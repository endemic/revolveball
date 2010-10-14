
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "MyContactListener.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	b2World *world;
	b2Body *body;
	CCSprite *ball;

	CCTMXTiledMap *map;
	CCTMXLayer *border;
	
	float previousAngle, currentAngle;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
