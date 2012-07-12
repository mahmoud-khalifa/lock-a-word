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



@implementation GameModesScene {
    Controller *controller;
}

+(id)scene {
    CCScene *scene = [CCScene node];
    
    GameModesScene *layer = [GameModesScene node];
    
    [scene addChild:layer];
    
    return scene;
}


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

		
        
	}
	return self;
}


// implementing our selector methods
// the Go to free plastic lock levels [free]

- (void) goToPlasticLock : (id) sender {
    [controller selectChapter:1];
    [controller selectLevel:1];
    [[CCDirector sharedDirector] pushScene:[GameScene scene]];
    NSLog(@"Plastic Lock button has been pressed !!");
}

// the Go to Bronze lock levels [free]

- (void) goToBronzeLock: (id) sender {
    [controller selectChapter:2];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    NSLog(@"Bronze Lock button has been pressed !!");
}

// the Go to Silver lock levels [free]

- (void) goToSilverLock: (id) sender {
    [controller selectChapter:3];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    NSLog(@"Silver Lock button has been pressed !!");
}
// the Go to Gold lock levels [free]

- (void) goToGoldLock: (id) sender {
    [controller selectChapter:4];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    NSLog(@"Gold Lock button has been pressed !!");
}



@end
