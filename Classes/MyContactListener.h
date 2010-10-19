//
//  MyContactListener.h
//  Ballgame
//
//  Created by Nathan Demick on 10/6/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "Box2D.h"
#import "cocos2d.h"

class MyContactListener : public b2ContactListener 
{
public:
	NSMutableArray *contactQueue;
	MyContactListener();
	~MyContactListener();
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact);
};
