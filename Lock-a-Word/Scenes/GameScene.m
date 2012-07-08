//
//  PlasticLockScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene {
    GameMode gameMode;
    int level;
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
        CCSprite *backButton = [CCSprite alloc];
        backButton.anchorPoint= ccp(0,0);
        backButton.position = (CGPoint *)CGRectMake(0, 0,((.5375*size.width/2)-(.125*size.width/2)), ((.908*size.height/2)-(.791*size.height/2)));
       
      // Incomplete waiting for logic things      
		
        
	}
	return self;
}

// Check if Back button is clicked 
-(BOOL) ccTouchBegan:(UITouch *)touch  withEvent:(UIEvent *)event{
    
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    
    return YES;
}



@end
