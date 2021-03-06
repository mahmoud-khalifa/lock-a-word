//
//  LevelSelectionScene.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Controller.h"

@interface LevelSelectionScene : CCLayer {
    CCSprite *trophyImage;
    CCSprite *boardTrophy;
    NSString *boardTrophyName;
    
}

@property (nonatomic, assign) NSString *device;

+(id) scene;
-(id) init;


@end
