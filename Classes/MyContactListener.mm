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

void MyContactListener::BeginContact(b2Contact *contact)
{
	b2Fixture *fixtureA = contact->GetFixtureA();
	b2Fixture *fixtureB = contact->GetFixtureB();
	if (contact->IsEnabled()) 
	{
		CCSprite *spriteA = (CCSprite *)fixtureA->GetUserData();
		CCSprite *spriteB = (CCSprite *)fixtureB->GetUserData();

		//NSLog(@"Fixture A (%@) is colliding against fixture B (%@)", spriteA, spriteB);
	}
}

void MyContactListener::EndContact(b2Contact *contact)
{
	//NSLog(@"End contact");
}

void MyContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold)
{
	//const b2Manifold *manifold = contact->GetManifold();
}

void MyContactListener::PostSolve(b2Contact *contact)
{
	//const b2ContactImpulse *impulse;
}
