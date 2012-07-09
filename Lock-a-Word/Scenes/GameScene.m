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
    CGRect backButtonRect;
    CGSize size;
}


//+(id)scene {
//    CCScene *scene = [CCScene node];
//    
//    GameScene *layer = [GameScene node];
//    
//    [scene addChild:layer];
//    
//    return scene;
//}


-(id) initWithGameMode:(GameMode)aGameMode andLevel:(int)aLevel{    
	if( (self=[super init] )) {
        //Enable Touches
        self.isTouchEnabled=YES;
        // Get Gamemode and level 
        gameMode = aGameMode;
        level = aLevel;
        // Get the screen size
        size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:backgroundImage];
        
        
        backButtonRect = CGRectMake(.05*size.width, .895*size.height,.4125*size.width/2, .125*size.height/2);
        // Incomplete waiting for logic things      
		
        
	}
	return self;
}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint(backButtonRect, location)) {
        [[CCDirector sharedDirector] popScene];
    }
}



@end
