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

//Needed for Instruction Scene
#import "InstructionsScene.h"

//Needed for Sound effects
#import "SimpleAudioEngine.h"


@interface MainMenuScene()
{
    CCMenuItemImage *menuItemAnimate1; 
    CCMenuItemImage *menuItemAnimate2;
    CCMenuItemImage *menuItemAnimate3;
    CGSize size;
    
    Controller* controller;
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
-(id) init{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        controller = [Controller sharedController];
		
        // Get the screen size
        size =[[CCDirector sharedDirector] winSize];
        
        CCSpriteFrameCache*frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache  addSpriteFramesWithFile:@"menu_buttons.plist"];
        [frameCache  addSpriteFramesWithFile:@"tiles.plist"];
        
        // load resources
		ResourcesLoader *loader = [ResourcesLoader sharedLoader];
		NSArray *extensions = [NSArray arrayWithObjects:@"png", @"mp3", nil];
		
		for (NSString *extension in extensions) {
			NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
			for (NSString *filename in paths) {
                filename = [[filename componentsSeparatedByString:@"/"] lastObject];
                if( [filename rangeOfString:@"-hd"].location==NSNotFound &&[filename rangeOfString:@"@2x"].location==NSNotFound){
                    [loader addResources:filename, nil];
                }
			}
		}
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        CCSprite * entrybackgroundImage = [CCSprite spriteWithFile:@"main_bg.png"];
        entrybackgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:entrybackgroundImage];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        [[SimpleAudioEngine sharedEngine]playEffect:@"Fanfare.mp3"];
        [self performSelector:@selector(playApplause) withObject:nil afterDelay:1.3];
        
        [self animateMenuItems];
//        [self performSelector:@selector(shrinkMenu) withObject:nil afterDelay:2.0];
        
        [self performSelector:@selector(hideMenuItems) withObject:nil afterDelay:4.0f];
        [self performSelector:@selector(showMainMenu) withObject:nil afterDelay:4.0f];
       
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
- (void)goToGameModeScene:(id) sender {
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    [[CCDirector sharedDirector] pushScene:[GameModesScene scene]];
}

-(void)hideMenuItems {
    menuItemAnimate1.visible=NO;
    menuItemAnimate2.visible=NO;
    menuItemAnimate3.visible=NO;
}

// This method will show our main menu
-(void)animateMenuItems{
    // Here I will add my begining of the intro animation "LOCK - A - WORD"
//    menuItemAnimate1 =[CCMenuItemImage itemWithNormalImage:@"btn_lock.png" selectedImage:@"btn_lock.png"];
//    menuItemAnimate2 =[CCMenuItemImage itemWithNormalImage:@"btn_a.png" selectedImage:@"btn_a.png"];
//    menuItemAnimate3 =[CCMenuItemImage itemWithNormalImage:@"btn_word.png" selectedImage:@"btn_word.png"];
    
    menuItemAnimate1 =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_lock.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_lock.png"]];
    
    menuItemAnimate2 =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_a.png"] 
                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_a.png"]];
                       
    menuItemAnimate3 =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_word.png"] 
                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_word.png"]];
    
    menuItemAnimate1.rotation = 180;
    menuItemAnimate3.rotation = 180;
    
    // Adding "LOCK - A - WORD" items to the menu
    CCMenu *introMenu = [CCMenu menuWithItems:menuItemAnimate1,menuItemAnimate2,menuItemAnimate3, nil];
    // gameMenu.anchorPoint=CGPointZero;
    [introMenu alignItemsVertically];
    introMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2));      
    
    [self addChild:introMenu];
    
    id oneSpin = [CCRotateBy actionWithDuration:1 angle: 180];
    [menuItemAnimate1 runAction:oneSpin];
    [self performSelector:@selector(rotate) withObject:nil afterDelay:2];
    
    // Here is the animation part of the LOCK-A-WORD Menu
//    menuItemAnimate1.scale=.75;        
//    [menuItemAnimate1 runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
//    menuItemAnimate2.scale=.75;
//    [menuItemAnimate2 runAction:[CCScaleTo actionWithDuration:1.0 scale:1.0]];
//    menuItemAnimate3.scale=.75;
//    [menuItemAnimate3 runAction:[CCScaleTo actionWithDuration:1.5 scale:1.0]];
}

-(void)rotate{
    id oneSpin = [CCRotateBy actionWithDuration:1 angle: 180];
    [menuItemAnimate3 runAction:oneSpin];
}

-(void)playApplause{
    [[SimpleAudioEngine sharedEngine]playEffect:@"Applause.mp3"];
}

-(void)shrinkMenu {
    [menuItemAnimate1 runAction:[CCScaleTo actionWithDuration:1.0 scale:.75]];
    [menuItemAnimate2 runAction:[CCScaleTo actionWithDuration:1.0 scale:.75]];
    [menuItemAnimate3 runAction:[CCScaleTo actionWithDuration:1.0 scale:.75]];
}


// This method will be used to show "PLAY-INSTRUCTION-FULL" menu items
-(void)showMainMenu {
    // Here I will add my begining of the intro animation "PLAY - INSTRUCTION - FULL"
//    CCMenuItemImage* mainMenuItem1 =[CCMenuItemImage itemWithNormalImage:@"main_btn_play.png" selectedImage:@"main_btn_play.png" target:self selector:@selector(goToGameModeScene:)];
//    CCMenuItemImage* mainMenuItem2 =[CCMenuItemImage itemWithNormalImage:@"main_btn_instr.png" selectedImage:@"main_btn_instr.png" target:self selector:@selector(goToInstructions)];
//    CCMenuItemImage* mainMenuItem3 =[CCMenuItemImage itemWithNormalImage:@"main_btn_upgr.png" selectedImage:@"main_btn_upgr.png" target:self selector:@selector(goTofull)];
    
    CCMenuItemImage* mainMenuItem1 =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"main_btn_play.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"main_btn_play.png"] target:self selector:@selector(goToGameModeScene:)];
                                     
    CCMenuItemImage* mainMenuItem2 =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"main_btn_instr.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"main_btn_instr.png"] target:self selector:@selector(goToInstructions)];
                                     
    CCMenuItemImage* mainMenuItem3 =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"main_btn_upgr.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"main_btn_upgr.png"] target:self selector:@selector(goToFull)];
                                     
    // Adding "PLAY - INSTRUCTION - FULL" items to the menu
    CCMenu *mainMenu = [CCMenu menuWithItems:mainMenuItem1,mainMenuItem2,mainMenuItem3, nil];
    // gameMenu.anchorPoint=CGPointZero;
    [mainMenu alignItemsVertically];
    mainMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2));      
    
    [self addChild:mainMenu];
    
    // Here is the animation part of the "PLAY - INSTRUCTION - FULL" Menu
    mainMenuItem1.scale=.75;        
    [mainMenuItem1 runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    mainMenuItem2.scale=.75;
    [mainMenuItem2 runAction:[CCScaleTo actionWithDuration:1.0 scale:1.0]];
    mainMenuItem3.scale=.75;
    [mainMenuItem3 runAction:[CCScaleTo actionWithDuration:1.5 scale:1.0]];    
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

#pragma mark Next Scene
-(void) goToInstructions
{  
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    
    [[CCDirector sharedDirector] pushScene:[InstructionsScene scene]];   
    CCLOG(@"Instruction button has been pressed!!");   
}

-(void) goToFull
{
    if ([controller isGameModesUnlocked]) {
        BlockAlertView *alertView=[BlockAlertView alertWithTitle:@"Upgrade" message:@"You are already upgraded to full version." andLoadingviewEnabled:NO];
        [alertView setCancelButtonWithTitle:@"OK" block:nil];
        [alertView show];
    }else {
        BlockAlertView *alertView=[BlockAlertView alertWithTitle:@"Upgrade" message:@"Do you want to upgrade to full version?" andLoadingviewEnabled:NO];
        [alertView addButtonWithTitle:@"Upgrade" block:^{
            [controller unlockAllGameModes];
        }];
        [alertView addButtonWithTitle:@"No" block:nil];
        [alertView show];
    }
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
