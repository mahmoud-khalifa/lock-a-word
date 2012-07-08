//
//  MainMenuScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/5/12.
//  Copyright NOE 2012. All rights reserved.
//


// Import the interfaces
#import "MainMenuScene.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - MainMenuScene

// MainMenuScene implementation
@implementation MainMenuScene

// Helper class method that creates a Scene with the MainMenuScene as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        // Get the screen size
        CGSize size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * entrybackgroundImage = [CCSprite spriteWithFile:@"main_bg.png"];
        entrybackgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:entrybackgroundImage];
        
        // Creating Menu Items
        // Normal images and selected are the same 
        CCMenuItemImage *menuItem1 =[CCMenuItemImage itemFromNormalImage:@"main_btn_play.png" selectedImage:@"main_btn_play.png" target:self selector:@selector(goToGameModeScene:)];
          CCMenuItemImage *menuItem2 =[CCMenuItemImage itemFromNormalImage:@"main_btn_instr.png" selectedImage:@"main_btn_instr.png" target:self selector:@selector(goToInstructions)];
          CCMenuItemImage *menuItem3=[CCMenuItemImage itemFromNormalImage:@"main_btn_full.png" selectedImage:@"main_btn_full.png" target:self selector:@selector(goTofull)];

//        menuItem1.normalImage.position = ccp(size.width/2, size.height/2 - (.16 *size.height/2));
//        menuItem2.position=ccp(size.width/2, size.height/2 - (.368 *size.height/2));
//        menuItem3.position=ccp(size.width/2, size.height/2 - (.577 *size.height/2));
        
       
        // Adding items to the menu
        CCMenu *gameMenu = [CCMenu menuWithItems:menuItem1,menuItem2,menuItem3, nil];
//        gameMenu.anchorPoint=CGPointZero;
        [gameMenu alignItemsVertically];
        gameMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2)); 
        
        
       
       
        [self addChild:gameMenu];
	}
	return self;
}


// This method will push our Game Mode Scene
- (void)goToGameModeScene:(id) sender 
{
    [[CCDirector sharedDirector] pushScene:[GameModesScene scene]];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
