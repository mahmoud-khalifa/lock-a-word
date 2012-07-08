//
//  GamePlay.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/5/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "GamePlay.h"


@implementation GamePlay



+(id) scene {
    
    CCScene *scene=[CCScene node];
    GamePlay *layer=[GamePlay node];
    [scene addChild:layer];
    return scene;
}

- (id) init {
    if ((self=[super init])) {
        
    }
    return self;
}
               

@end
