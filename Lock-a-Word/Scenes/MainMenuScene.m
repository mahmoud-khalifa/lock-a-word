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

// Nedded to instert the TapforTap Ads
#import "TapForTap.h"


@interface MainMenuScene()
{
    CCMenuItemImage *menuItemAnimate1; 
    CCMenuItemImage *menuItemAnimate2;
    CCMenuItemImage *menuItemAnimate3;
    CGSize size;
}

-(void) animateMenuItems;
-(void) hideMenuItems;
-(void) showMainMenu;

@end

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
        size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * entrybackgroundImage = [CCSprite spriteWithFile:@"main_bg.png"];
        entrybackgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:entrybackgroundImage];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        [self animateMenuItems];
        [self performSelector:@selector(hideMenuItems) withObject:nil afterDelay:2.0f];
        [self performSelector:@selector(showMainMenu) withObject:nil afterDelay:2.0f];
        
         
        
        
       
        
        
        
        
        
        // Creating Menu Items
        // Normal images and selected are the same 
        
//        CCMenuItemImage *menuItem1 =[CCMenuItemImage itemWithNormalImage:@"main_btn_play.png" selectedImage:@"main_btn_play.png" target:self selector:@selector(goToGameModeScene:)];
//          CCMenuItemImage *menuItem2 =[CCMenuItemImage itemWithNormalImage:@"main_btn_instr.png" selectedImage:@"main_btn_instr.png" target:self selector:@selector(goToInstructions)];
//          CCMenuItemImage *menuItem3=[CCMenuItemImage itemWithNormalImage:@"main_btn_full.png" selectedImage:@"main_btn_full.png" target:self selector:@selector(goTofull)];
//
////        menuItem1.normalImage.position = ccp(size.width/2, size.height/2 - (.16 *size.height/2));
////        menuItem2.position=ccp(size.width/2, size.height/2 - (.368 *size.height/2));
////        menuItem3.position=ccp(size.width/2, size.height/2 - (.577 *size.height/2));
//        
//       
//        // Adding items to the menu
//        CCMenu *gameMenu = [CCMenu menuWithItems:menuItem1,menuItem2,menuItem3, nil];
////        gameMenu.anchorPoint=CGPointZero;
//        [gameMenu alignItemsVertically];
//        gameMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2));      
//       
//        [self addChild:gameMenu];

	}
	return self;
}


// This method will push our Game Mode Scene
- (void)goToGameModeScene:(id) sender 
{
    [[CCDirector sharedDirector] pushScene:[GameModesScene scene]];
}



-(void)hideMenuItems {
    menuItemAnimate1.visible=NO;
    menuItemAnimate2.visible=NO;
    menuItemAnimate3.visible=NO;
}

// This method will show our main menu
-(void)animateMenuItems
{
    // Here I will add my begining of the intro animation "LOCK - A - WORD"
    menuItemAnimate1 =[CCMenuItemImage itemWithNormalImage:@"btn_lock.png" selectedImage:@"btn_lock.png"];
    menuItemAnimate2 =[CCMenuItemImage itemWithNormalImage:@"btn_a.png" selectedImage:@"btn_a.png"];
    menuItemAnimate3 =[CCMenuItemImage itemWithNormalImage:@"btn_word.png" selectedImage:@"btn_word.png"];
    
    
    // Adding "LOCK - A - WORD" items to the menu
    CCMenu *introMenu = [CCMenu menuWithItems:menuItemAnimate1,menuItemAnimate2,menuItemAnimate3, nil];
    // gameMenu.anchorPoint=CGPointZero;
    [introMenu alignItemsVertically];
    introMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2));      
    
    [self addChild:introMenu];
    
    // Here is the animation part of the LOCK-A-WORD Menu
    menuItemAnimate1.scale=.75;        
    [menuItemAnimate1 runAction:[CCScaleTo actionWithDuration:1.0 scale:1.0]];
    menuItemAnimate2.scale=.75;
    [menuItemAnimate2 runAction:[CCScaleTo actionWithDuration:1.5 scale:1.0]];
    menuItemAnimate3.scale=.75;
    [menuItemAnimate3 runAction:[CCScaleTo actionWithDuration:2.0 scale:1.0]];  
    
}

// This method will be used to show "PLAY-INSTRUCTION-FULL" menu items
-(void)showMainMenu 
{
    // Here I will add my begining of the intro animation "PLAY - INSTRUCTION - FULL"
    CCMenuItemImage* mainMenuItem1 =[CCMenuItemImage itemWithNormalImage:@"main_btn_play.png" selectedImage:@"main_btn_play.png" target:self selector:@selector(goToGameModeScene:)];
    CCMenuItemImage* mainMenuItem2 =[CCMenuItemImage itemWithNormalImage:@"main_btn_instr.png" selectedImage:@"main_btn_instr.png" target:self selector:@selector(goToInstructions)];
    CCMenuItemImage* mainMenuItem3 =[CCMenuItemImage itemWithNormalImage:@"main_btn_full.png" selectedImage:@"main_btn_full.png" target:self selector:@selector(goTofull)];
    
    
   
    // Adding "PLAY - INSTRUCTION - FULL" items to the menu
    CCMenu *mainMenu = [CCMenu menuWithItems:mainMenuItem1,mainMenuItem2,mainMenuItem3, nil];
    // gameMenu.anchorPoint=CGPointZero;
    [mainMenu alignItemsVertically];
    mainMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2));      
    
    [self addChild:mainMenu];
    
    // Here is the animation part of the LOCK-A-WORD Menu
    mainMenuItem1.scale=.75;        
    [mainMenuItem1 runAction:[CCScaleTo actionWithDuration:1.0 scale:1.0]];
    mainMenuItem2.scale=.75;
    [mainMenuItem2 runAction:[CCScaleTo actionWithDuration:1.5 scale:1.0]];
    mainMenuItem3.scale=.75;
    [mainMenuItem3 runAction:[CCScaleTo actionWithDuration:2.0 scale:1.0]];    
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
