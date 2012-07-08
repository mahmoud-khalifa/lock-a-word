//
//  LevelSelectionScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "LevelSelectionScene.h"


@implementation LevelSelectionScene {
    GameMode gameMode;
}





+(id)scene {
    CCScene *scene = [CCScene node];
    
    LevelSelectionScene *layer = [LevelSelectionScene node];
    
    [scene addChild:layer];
    
    return scene;
}


-(id) initWithGameMode:(GameMode)aGameMode {
    
	if( (self=[super init] )) {
        gameMode = aGameMode;
        // Get the screen size
        CGSize size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:backgroundImage];
        
        // Incomplete waiting for logic things     
		
        
	}
	return self;
}


@end
