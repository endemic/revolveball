//
//  RevolveBallAppDelegate.h
//  RevolveBall
//
//  Created by Nathan Demick on 12/17/10.
//  Copyright Ganbaru Games 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface RevolveBallAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
