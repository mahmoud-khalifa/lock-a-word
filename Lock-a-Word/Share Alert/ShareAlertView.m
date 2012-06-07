//
//  ShareAlertView.m
//  TextTwistGame
//
//  Created by Log n Labs on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShareAlertView.h"
#import "AppDelegate.h"
#import "FBConnect.h"


#import <Accounts/Accounts.h>

#import "FBViewController.h"

#import "GameConfig.h"
#import "BlockAlertView.h"

//#import "StatisticsCollector.h"

#define kAlertDelay 0.15

#define SinglePlayerAlertBgImage @"game_over_top_share.png"


//static CGSize screenSize;

@implementation ShareAlertView

@synthesize Message, SubMessage, Button1, Button2;
@synthesize button1Target, button1Selector, button2Target, button2Selector;


-(id) initShareAlertWithGameMode:(GameModes)mode{
    
    if((self = [super init]))
        
    {
        CCSpriteFrameCache*  frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache  addSpriteFramesWithFile:@"share_alert.plist"];
        
        if (IS_IPAD()) {
            iPadDoubleFactor=2;
        }else{
        
            iPadDoubleFactor=1;
        }
        //screenSize=[[CCDirector sharedDirector]winSize];
        
        NSString * bgImage=SinglePlayerAlertBgImage;
        
        switch (mode) {
            case GameModeHorizontal:
               levelName=[[NSString alloc]initWithString:@"Hovering Cross-Step"];
                break;
            case GameModeVertical:
               levelName=[[NSString alloc]initWithString:@"Vertical Cha-Cha"];
                break;
            case GameModeBoth:
                levelName=[[NSString alloc]initWithString:@"Alien Jig"];
                break;
            case GameModeDropAll:
                levelName=[[NSString alloc]initWithString:@"Humanoid Twist"];
                break;
                
            default:
                break;
        }
        NSString * button1Image=@"game_over_twitter_icon.png";
        NSString * button2Image=@"game_over_facebook_icon.png";
        
        self.isTouchEnabled = YES;
        //tODO
		alertViewSprite = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:bgImage]];
		
        [self addChild:alertViewSprite z:0];

        self.anchorPoint = ccp(0,0);

        
        OK = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:button1Image]] selectedSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:button1Image]] target:self selector:@selector(buttonOneClicked:)];
        Cancel = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:button2Image]] selectedSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:button2Image]] target:self selector:@selector(buttonTwoClicked:)];
        
        OK.anchorPoint = ccp(0,0);
        Cancel.anchorPoint = ccp(0,0);
        OK.position=ccp(155*iPadDoubleFactor,14*iPadDoubleFactor);
        Cancel.position=ccp(105*iPadDoubleFactor,14*iPadDoubleFactor);
        
        CCMenu *alertMenu = [CCMenu menuWithItems:Cancel, OK, nil];
		alertMenu.anchorPoint = ccp(0,0);
		alertMenu.position = ccp(0, 0);
		[alertViewSprite addChild:alertMenu];

        alertViewSprite.anchorPoint=ccp(0.5,1);
        CGPoint toPosition;
        alertViewSprite.position=ccp(screenSize.width*0.5, screenSize.height+alertViewSprite.contentSize.height);
            
        toPosition=CGPointMake(screenSize.width*0.5,screenSize.height);
                
        CCMoveTo* move=[CCMoveTo actionWithDuration:kAlertDelay position:toPosition];
        [alertViewSprite runAction:move];

        if (NSClassFromString(@"TWTweetComposeViewController")) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError* error) {
                
//                ACAccount *account = [[ACAccount alloc] initWithAccountType:accountType];
//#ifdef DEBUG
//                NSLog(@"%@, %@", account.username, account.description);
//#endif
            }]; 
        }
    }
    return self;
}

-(void) buttonOneClicked:(id) sender //Twitter
{

    //self.visible=NO;
    [self schedule:@selector(updateTwitter:)];
    NSMethodSignature * sig = nil;
    
    if( button1Target && button1Selector ) {
        sig = [button1Target methodSignatureForSelector:button1Selector];
        
        NSInvocation *invocation = nil;
        invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:button1Target];
        [invocation setSelector:button1Selector];
#if NS_BLOCKS_AVAILABLE
        if ([sig numberOfArguments] == 3)
#endif
			[invocation setArgument:&self atIndex:2];
        
        [invocation invoke];
    }
    
    
}
-(void)updateTwitter:(ccTime)delta{
    NSString *finalMsg =[NSString stringWithFormat: @"My new high score for #AlphaPanic / (%@) is %@. My new TOTAL high score is %@.\nCan you beat these scores?!",levelName,Message,SubMessage];
        
    if (NSClassFromString(@"TWTweetComposeViewController")) {
        if([TWTweetComposeViewController canSendTweet]) {
            
            TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
            
            [controller setInitialText:finalMsg];
            //[controller addURL:[NSURL URLWithString:@"http://bit.ly/vJGj42"]];
            
            [controller addImage:[UIImage imageNamed:@"Icon-Small.png"]];
            
            controller.completionHandler = ^(TWTweetComposeViewControllerResult result)  {
                
                [kAPP_DELEGATE.window.rootViewController dismissModalViewControllerAnimated:YES];
                BlockAlertView* alert;
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled: 
//                        alert=[[UIAlertView alloc ]initWithTitle:@"Cancelled" message:@"Action Cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                        [alert show];
//                        [alert release];
                        break;
                        
                    case TWTweetComposeViewControllerResultDone:
                        alert=[BlockAlertView alertWithTitle:@"Success" message:@"Your Tweet was sent successfully" andLoadingviewEnabled:NO];
                        [alert setCancelButtonWithTitle:@"OK" block:nil];
//                        alert=[[UIAlertView alloc ]initWithTitle:@"Success" message:@"Your Tweet was sent successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
//                        [alert release];
//                        
//                        [StatisticsCollector logEvent:@"Post On Twitter"];
                        break;
                        
                    default:
                        break;
                }
            };
            
            [kAPP_DELEGATE.window.rootViewController presentModalViewController:controller animated:YES];
            
        }else{
            

            CCLOG(@"problem in sending tweets using ios 5 twitter framework");

            TwitterRushViewController* twitterController=[[TwitterRushViewController alloc]initWithMessage:finalMsg];
            [kAPP_DELEGATE.window.rootViewController presentModalViewController:twitterController animated:YES];
            [twitterController release];
            
        }
    }else{

        CCLOG(@"can't see twitter class for ios5");

        TwitterRushViewController* twitterController=[[TwitterRushViewController alloc]initWithMessage:finalMsg];
        [kAPP_DELEGATE.window.rootViewController presentModalViewController:twitterController animated:YES];
        [twitterController release];
    }
 
    [self unschedule:_cmd]; 
//    [self  removeFromParentAndCleanup:YES];
}
-(void) buttonTwoClicked:(id) sender //FaceBook
{
    
    //self.visible=NO;
 
    NSString* msg=[NSString stringWithFormat: @"My new high score for Alpha Panic / (%@) is %@. My new TOTAL high score is %@.\nCan you beat these scores?!",levelName,Message,SubMessage];
         
    
    FBViewController* fbController=[[FBViewController alloc ]initWithMsg:msg];
    
    [kAPP_DELEGATE.window.rootViewController presentModalViewController:fbController animated:YES];
    
    [FBViewController release];
    
    NSMethodSignature * sig = nil;
    
    if( button2Target && button2Selector ) {
        sig = [button2Target methodSignatureForSelector:button2Selector];
        
        NSInvocation *invocation = nil;
        invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:button2Target];
        [invocation setSelector:button2Selector];
#if NS_BLOCKS_AVAILABLE
        if ([sig numberOfArguments] == 3)
#endif
			[invocation setArgument:&self atIndex:2];
        
        [invocation invoke];
    }
    
//    [self removeFromParentAndCleanup:YES];
}

-(void)setMessage:(NSString *)Message_{
    if (Message == nil) {
        [MessageLabel removeFromParentAndCleanup:YES];
    }
    [Message release];
    Message = [Message_ retain];
    
    if (Message_ != nil) {
        MessageLabel = [CCLabelBMFont labelWithString:Message fntFile: @"score_bitmapfont.fnt" ];
        MessageLabel.anchorPoint = ccp(0,0.5);
        MessageLabel.color=ccc3(60, 60, 60);
        MessageLabel.scale=0.8;
        MessageLabel.position = ccp(112*iPadDoubleFactor, 95*iPadDoubleFactor);
        [alertViewSprite addChild:MessageLabel];
     
    }
}

-(void)setSubMessage:(NSString *)SubMessage_{
    if (SubMessage == nil) {
        [SubMessageLabel removeFromParentAndCleanup:YES];
    }
    
    [SubMessage release];
    SubMessage = [SubMessage_ retain];
    
    if (SubMessage_ != nil) {
        
        SubMessageLabel = [CCLabelBMFont labelWithString:SubMessage fntFile: @"score_bitmapfont.fnt"  ];
        SubMessageLabel.anchorPoint = ccp(0,0.5);
        SubMessageLabel.color=ccc3(60, 60, 60);
        SubMessageLabel.scale=0.8;
        SubMessageLabel.position = ccp(112*iPadDoubleFactor, 68*iPadDoubleFactor);
        [alertViewSprite addChild:SubMessageLabel];
          
    }
}

-(void)dealloc{
    
    [levelName release];
    [super dealloc];
}



@end
