
//
//  ShareAlertView.h
//  TextTwistGame
//
//  Created by Log n Labs on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>


#import "FBConnect.h"
#import <Twitter/TWTweetComposeViewController.h>
#import "TwitterRushViewController.h"
#import "cocos2d.h"
#import "Controller.h"
typedef enum
{
    ShareAlertTypeSinglePlayer,
    ShareAlertTypeMultiplayer,
    
    
} ShareAlertTypes;
@interface ShareAlertView : CCLayer{
	
    NSString *Message;
	NSString *SubMessage;
    
    CCSprite *alertViewSprite;
    
    CCLabelBMFont *MessageLabel;
    CCLabelBMFont *SubMessageLabel;
    CCMenuItemImage *OK;
    CCMenuItemImage *Cancel;
    
    id button1Target;
    SEL button1Selector;
    
    id button2Target;
    SEL button2Selector;
    
    NSString*  levelName;
    
    int iPadDoubleFactor;
    
}
@property (nonatomic, retain) NSString *Message;
@property (nonatomic, retain) NSString *SubMessage;
@property (nonatomic, retain) NSString *Button1;
@property (nonatomic, retain) NSString *Button2;
@property (nonatomic, retain) id button1Target;
@property (nonatomic) SEL button1Selector;
@property (nonatomic, retain) id button2Target;
@property (nonatomic) SEL button2Selector;



-(id) initShareAlertWithGameMode:(GameModes)mode;
-(void)updateTwitter:(ccTime)delta;
@end
