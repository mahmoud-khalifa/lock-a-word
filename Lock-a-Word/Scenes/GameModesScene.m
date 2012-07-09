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

@implementation GameModesScene

+(id)scene {
    CCScene *scene = [CCScene node];
    
    GameModesScene *layer = [GameModesScene node];
    
    [scene addChild:layer];
    
    return scene;
}


-(id) init {
    
	if( (self=[super init] )) {
       
        // Get the screen size
        CGSize size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"main_bg.png"];
        backgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:backgroundImage];
        
        // Creating Menu Items
        // Normal images and selected are the same 
        CCMenuItemImage *menuItem1 =[CCMenuItemImage itemFromNormalImage:@"main_btn_plast.png" selectedImage:@"main_btn_plast.png" target:self selector:@selector(goToPlasticLock:)];
        CCMenuItemImage *menuItem2 =[CCMenuItemImage itemFromNormalImage:@"main_btn_bronz.png" selectedImage:@"main_btn_bronz.png" target:self selector:@selector(goToBronzeLock:)];
        CCMenuItemImage *menuItem3 =[CCMenuItemImage itemFromNormalImage:@"main_btn_silver.png" selectedImage:@"main_btn_silver.png" target:self selector:@selector(goToSilverLock:)];
        CCMenuItemImage *menuItem4 =[CCMenuItemImage itemFromNormalImage:
            @"main_btn_gold.png" selectedImage:@"main_btn_gold.png" target:self selector:@selector(goToGoldLock:)];
        
              
        // Adding items to the menu
        CCMenu *gameModesSceneMenu = [CCMenu menuWithItems:menuItem1,menuItem2,menuItem3,menuItem4,nil];
       
        [gameModesSceneMenu alignItemsVerticallyWithPadding:0];
        gameModesSceneMenu.position=ccp(size.width/2,size.height/2 - (.380 *size.height/2));       
        
        
        
        [self addChild:gameModesSceneMenu];

		
        
	}
	return self;
}


// implementing our selector methods
// the Go to free plastic lock levels [free]

- (void) goToPlasticLock : (id) sender {
    [[CCDirector sharedDirector] pushScene:(CCScene*)[[GameScene alloc]initWithGameMode:PlasticLock andLevel:0]];
    NSLog(@"Plastic Lock button has been pressed !!");
}

// the Go to Bronze lock levels [free]

- (void) goToBronzeLock: (id) sender {
    [[CCDirector sharedDirector] pushScene:(CCScene*)[[LevelSelectionScene alloc]initWithGameMode:BronzeLock]];
    NSLog(@"Bronze Lock button has been pressed !!");
}

// the Go to Silver lock levels [free]

- (void) goToSilverLock: (id) sender {
    [[CCDirector sharedDirector] pushScene:(CCScene*)[[LevelSelectionScene alloc]initWithGameMode:SilverLock]];
    NSLog(@"Silver Lock button has been pressed !!");
}
// the Go to Gold lock levels [free]

- (void) goToGoldLock: (id) sender {
    [[CCDirector sharedDirector] pushScene:(CCScene*)[[LevelSelectionScene alloc]initWithGameMode:GoldLock]];
    NSLog(@"Gold Lock button has been pressed !!");
}






@end