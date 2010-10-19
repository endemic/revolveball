//
//  MyContactListener.mm
//  Ballgame
//
//  Created by Nathan Demick on 10/6/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "MyContactListener.h"
#import "cocos2d.h"

struct ContactPoint 
{
	b2Fixture *fixtureA;
	b2Fixture *fixtureB;
	b2Vec2 normal;
	b2Vec2 position;
	b2PointState state;
};

const int32 k_maxContactPoints = 2048;
int32 m_pointCount;
ContactPoint m_points[k_maxContactPoints];

MyContactListener::MyContactListener()
{
	contactQueue = [[[NSMutableArray alloc] init] retain];
}

MyContactListener::~MyContactListener()
{
	[contactQueue release];
}

void MyContactListener::BeginContact(b2Contact *contact)
{
	// bodyB will be the only object we're interested in
	b2Body *body = contact->GetFixtureA()->GetBody();
	
	//if (contact->IsTouching()) 
	{
		//CCSprite *spriteA = (CCSprite *)bodyA->GetUserData();
		CCSprite *sprite = (CCSprite *)body->GetUserData();
		//NSLog(@"Added sprite at (%f, %f) from the contact queue", item.position.x, item.position.y);
		[contactQueue addObject:sprite];
	}
}

void MyContactListener::EndContact(b2Contact *contact)
{
	b2Body *body = contact->GetFixtureA()->GetBody();
	NSMutableArray *discardedItems = [NSMutableArray array];
	CCSprite *item;
	
	for (item in contactQueue)
	{
		if ((CCSprite *)body->GetUserData() == item)
		{
			[discardedItems addObject:item];
			//NSLog(@"Removed sprite at (%f, %f) from the contact queue", item.position.x, item.position.y);
		}
	}
	
	[contactQueue removeObjectsInArray:discardedItems];
}

void MyContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold)
{
	//const b2Manifold *manifold = contact->GetManifold();
}

void MyContactListener::PostSolve(b2Contact *contact)
{
	//const b2ContactImpulse *impulse;
}
