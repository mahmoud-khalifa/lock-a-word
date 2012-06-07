//
//  AppDelegate.h
//  Word9
//
//  Created by Log n Labs on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "Controller.h"
@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate,FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate,NSURLConnectionDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
      Facebook *facebook;
    
    Controller* gameController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;


#pragma mark facebook Methods
- (void)connectToFacebook:(NSString *)msg; 
- (void)postFacebookMessage;

@end
