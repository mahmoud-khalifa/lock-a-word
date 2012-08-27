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
#import "SimpleAudioEngine.h"

@interface GameModesScene()
{
    
}

-(CCMenuItemImage *) showStars :(int)gamemode;

@end


@implementation GameModesScene {
    Controller *controller;
    UITextView* t;
    
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
        CCMenuItemImage *menuItem1=[self showStars:PlasticLock];
        CCMenuItemImage *menuItem2=[self showStars:BronzeLock];
        CCMenuItemImage *menuItem3=[self showStars:SilverLock];
        CCMenuItemImage *menuItem4=[self showStars:GoldLock];
     
        //Remove the scaling from the Ipad version
        if (!IS_IPAD()) {
            menuItem1.scale = 1.10;
            menuItem2.scale = 1.10;
            menuItem3.scale = 1.10;
            menuItem4.scale = 1.10;
        }
        
        
//        CCMenuItemImage *menuItem1 =[CCMenuItemImage itemWithNormalImage:@"main_btn_plast.png" selectedImage:@"main_btn_plast.png" target:self selector:@selector(goToPlasticLock:)];
//        CCMenuItemImage *menuItem2 =[CCMenuItemImage itemWithNormalImage:@"main_btn_bronz.png" selectedImage:@"main_btn_bronz.png" target:self selector:@selector(goToBronzeLock:)];
//        CCMenuItemImage *menuItem3 =[CCMenuItemImage itemWithNormalImage:@"main_btn_silver.png" selectedImage:@"main_btn_silver.png" target:self selector:@selector(goToSilverLock:)];
//        CCMenuItemImage *menuItem4 =[CCMenuItemImage itemWithNormalImage:
//            @"main_btn_gold.png" selectedImage:@"main_btn_gold.png" target:self selector:@selector(goToGoldLock:)];
     
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
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    
    [self performSelector:@selector(plasticLock) withObject:nil afterDelay:0.6];
}

- (void) plasticLock {
    [controller selectChapter:PlasticLock];
    [controller selectLevel:1];
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    CCLOG(@"Plastic Lock button has been pressed !!");
}

// the Go to Bronze lock levels [free]

- (void) goToBronzeLock: (id) sender {
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    
    [self performSelector:@selector(bronzeLock) withObject:nil afterDelay:0.6];
}

- (void) bronzeLock {
    [controller selectChapter:BronzeLock];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    CCLOG(@"Bronze Lock button has been pressed !!");
}

// the Go to Silver lock levels [free]

- (void) goToSilverLock: (id) sender {
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    
    [self performSelector:@selector(silverLock) withObject:nil afterDelay:0.6];
}

- (void) silverLock{
    [controller selectChapter:SilverLock];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    CCLOG(@"Silver Lock button has been pressed !!");
}
// the Go to Gold lock levels [free]

- (void) goToGoldLock: (id) sender {
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    
    [self performSelector:@selector(goldLock) withObject:nil afterDelay:0.6];
}

- (void) goldLock{
    [controller selectChapter:GoldLock];
    [[CCDirector sharedDirector] pushScene:[LevelSelectionScene scene]];
    CCLOG(@"Gold Lock button has been pressed !!");
}

-(CCMenuItemImage *) showStars :(int)gameMode 
{   
    int numberOfStars = [controller getModeStars:gameMode];    
    CCMenuItemImage *stars;
    CCMenuItemImage *gameModeItemImage; 
    CCMenuItemImage *finalItemImage; 
    // This will get the stars images
                switch (numberOfStars) {
                    case 0:
//                        stars =[CCMenuItemImage itemWithNormalImage:@"stars.png" selectedImage:@"stars.png" ];
                        stars =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"stars.png"] 
                                                      selectedSprite:[CCSprite spriteWithSpriteFrameName:@"stars.png"]];
                        break;
                        
                    case 1:
//                        stars =[CCMenuItemImage itemWithNormalImage:@"star1.png" selectedImage:@"star1.png"];
                        stars =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"star1.png"] 
                                                      selectedSprite:[CCSprite spriteWithSpriteFrameName:@"star1.png"]];
                        break;
                        
                    case 2:
//                        stars =[CCMenuItemImage itemWithNormalImage:@"star2.png" selectedImage:@"star2.png"];
                        stars =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"star2.png"] 
                                                      selectedSprite:[CCSprite spriteWithSpriteFrameName:@"star2.png"]];
                       break;
                        
                    case 3:
//                        stars =[CCMenuItemImage itemWithNormalImage:@"star3.png" selectedImage:@"star3.png"];
                        stars =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"star3.png"] 
                                                      selectedSprite:[CCSprite spriteWithSpriteFrameName:@"star3.png"]];
                        break;                     
                        
                    default:
                        break;
                }
  
    // This will get the image item for the mode only without stars
            if (gameMode == PlasticLock)
            {
                gameModeItemImage =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_plastic_new.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_plastic_new.png"] target:self selector:@selector(goToPlasticLock:)];
            } else if (gameMode == BronzeLock) {
                gameModeItemImage =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_bronze_new.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_bronze_new.png"] target:self selector:@selector(goToBronzeLock:)];
            } else if (gameMode == SilverLock){
                gameModeItemImage =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_silver_new.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_silver_new.png"]  target:self selector:@selector(goToSilverLock:)];
            } else {
                gameModeItemImage =[CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn_gold_new.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn_gold_new.png"] target:self selector:@selector(goToGoldLock:)];  
            }
    
    
    stars.anchorPoint=ccp(1,.5);
    stars.position=ccp(gameModeItemImage.contentSize.width - stars.contentSize.width/3, gameModeItemImage.contentSize.height);
//    gameModeItemImage.anchorPoint=ccp(1,.5);/
    finalItemImage = gameModeItemImage;
    [finalItemImage addChild:stars];    
    return finalItemImage;
       
}                                  

@end
