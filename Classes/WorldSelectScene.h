//
//  WorldSelectScene.h
//  Ballgame
//
//  Created by Nathan Demick on 12/2/10.
//  Copyright 2010 Ganbaru Games. All rights reserved.
//

#import "cocos2d.h"

@interface WorldSelectScene : CCScene {}
@end

@interface WorldSelectLayer : CCLayer 
{
	NSMutableArray *carouselItems;
}

@property (nonatomic, retain) NSMutableArray *carouselItems;

- (void)carouselAdvance:(id)sender;
- (void)carouselReverse:(id)sender;

@end

