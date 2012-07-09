//
//  PlasticLockScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "GameScene.h"
#import "LevelSelectionScene.h"


@implementation GameScene {
    GameMode gameMode;
    int level;
    CCSprite *backButton;
}


+(id)scene {
    CCScene *scene = [CCScene node];
    
    GameScene *layer = [GameScene node];
    
    [scene addChild:layer];
    
    return scene;
}


-(id) initWithGameMode:(GameMode)aGameMode andLevel:(int)aLevel{    
	if( (self=[super init] )) {
        //Enable Touches
        self.isTouchEnabled=YES;
        // Get Gamemode and level 
        gameMode = aGameMode;
        level = aLevel;
        // Get the screen size
        CGSize size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:backgroundImage];
        
        // Creating Back button with only dimensions it has no view element
        backButton = [CCSprite alloc];
        backButton.anchorPoint= ccp(0,0);
        backButton.contentSize = CGSizeMake(.4125*size.width/2, .125*size.height/2);
        backButton.position = ccp(.05, .895);
        backButton.tag=1;
       
        
        [self addChild:backButton];
      // Incomplete waiting for logic things      
		
        
	}
	return self;
}

// Check if Back button is clicked 
//- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
//    
//    CGPoint location = [touch locationInView:[touch view]];     
//    location = [[CCDirector sharedDirector] convertToGL:location];
//    if (CGRectContainsPoint(backButton.textureRect, location)) {
//        [[CCDirector sharedDirector] popScene];
//    }
//    
//}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint(backButton.boundingBox, location)) {
        [[CCDirector sharedDirector] popScene];
    }
    CCLOG(@"Touches Happens !!");
}



@end
