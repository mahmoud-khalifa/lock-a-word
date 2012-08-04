//
//  GameModesScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "GameModesScene.h"
#import "GameScene.h"
#import "LevelSelectionScene.h"
#import "Controller.h"
#import "GameConfig.h"
#import "TapForTap.h"



@implementation GameModesScene {
    Controller *controller;
    UITextView* t;
    CCMenuItemImage *stars;
}

+(id)scene {
    CCScene *scene = [CCScene node];
    
    GameModesScene *layer = [GameModesScene node];
    
    [scene addChild:layer];
    
    return scene;
}

//- (void)onExit {
//    t.hidden = YES;
//}
-(id) init {
    
	if( (self=[super init] )) {
        // get shared controller
        controller = [Controller sharedController];
        
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"main_bg.png"];
        backgroundImage.position =ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:backgroundImage];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        // Creating Menu Items
        // Normal images and selected are the same 
       
        
        CCMenuItemImage *menuItem1 =[CCMenuItemImage itemWithNormalImage:@"main_btn_plast.png" selectedImage:@"main_btn_plast.png" target:self selector:@selector(goToPlasticLock:)];
        CCMenuItemImage *menuItem2 =[CCMenuItemImage itemWithNormalImage:@"main_btn_bronz.png" selectedImage:@"main_btn_bronz.png" target:self selector:@selector(goToBronzeLock:)];
        CCMenuItemImage *menuItem3 =[CCMenuItemImage itemWithNormalImage:@"main_btn_silver.png" selectedImage:@"main_btn_silver.png" target:self selector:@selector(goToSilverLock:)];
        CCMenuItemImage *menuItem4 =[CCMenuItemImage itemWithNormalImage:
            @"main_btn_gold.png" selectedImage:@"main_btn_gold.png" target:self selector:@selector(goToGoldLock:)];
        
        // Adding items to the menu
        CCMenu *gameModesSceneMenu = [CCMenu menuWithItems:menuItem1,menuItem2,menuItem3,menuItem4,nil];
       
        [gameModesSceneMenu alignItemsVerticallyWithPadding:0];
        gameModesSceneMenu.position=ccp(screenSize.width/2,screenSize.height/2 - (.380 *screenSize.height/2));   
        
        [self addChild:gameModesSceneMenu];
        int numberOfStars = [controller getPlasticModeStars];
        // Here we will add stars to Plastic level 
        
        if (numberOfStars == 0) {
            stars =[CCMenuItemImage itemWithNormalImage:@"stars.png" selectedImage:@"stars.png"];
        } else if (numberOfStars == 1)
        {
           stars =[CCMenuItemImage itemWithNormalImage:@"star1.png" selectedImage:@"star1.png"]; 
        } else if (numberOfStars == 2)
        {
          stars =[CCMenuItemImage itemWithNormalImage:@"star2.png" selectedImage:@"star2.png"]; 
        } else
            
        {
           stars =[CCMenuItemImage itemWithNormalImage:@"star3.png" selectedImage:@"star3.png"]; 
        }

  
//        stars.scale = 1.5 ;
        stars.position=ADJUST_XY(.625*screenSize.width,.479*screenSize.height);
        [self addChild:stars];
    

//        t = [[UITextView alloc] initWithFrame: CGRectMake(0,300, 320,50)];
//        t.backgroundColor = [UIColor blackColor];
//        t.textColor = [UIColor whiteColor];
//        t.text = @"Hello UIKit!";
//        t.editable = NO;
//        
//        [[[CCDirector sharedDirector] view] addSubview:t];


		
        
	}
	return self;
}


// implementing our selector methods
// the Go to free plastic lock levels [free]

- (void) goToPlasticLock : (id) sender {
    [controller selectChapter:PlasticLock];
    [controller selectLevel:1];
    [[CCDirector sharedDirector] pushScene:[GameScene scene]];
    CCLOG(@"Plastic Lock button has been pressed !!");
}

// the Go to Bronze lock levels [free]

- (void) goToBronzeLock: (id) sender {
    [controller selectChapter:BronzeLock];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    CCLOG(@"Bronze Lock button has been pressed !!");
}

// the Go to Silver lock levels [free]

- (void) goToSilverLock: (id) sender {
    [controller selectChapter:SilverLock];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    CCLOG(@"Silver Lock button has been pressed !!");
}
// the Go to Gold lock levels [free]

- (void) goToGoldLock: (id) sender {
    [controller selectChapter:GoldLock];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    CCLOG(@"Gold Lock button has been pressed !!");
}



@end
