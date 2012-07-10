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
    CCSprite *backButton;
    CGRect backButtonRect;
    CGSize size;
}


+(id)scene {
    CCScene *scene = [CCScene node];
    
    GameScene *layer = [GameScene node];
    
    [scene addChild:layer];
    
    return scene;
}


-(id) init {    
	if( (self=[super init] )) {
        //Enable Touches
        self.isTouchEnabled=YES;
        
        
        // Get the screen size
        size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:backgroundImage];
        
        /* 
         We have created a rectangle to be behind the back button in the background 
         */
         backButtonRect = CGRectMake(.05*size.width, .895*size.height,.4125*size.width/2, .125*size.height/2);
             
		
        
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
