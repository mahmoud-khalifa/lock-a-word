//
//  MainMenuScene.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/5/12.
//  Copyright NOE 2012. All rights reserved.
//


#import <GameKit/GameKit.h>
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#import "GameModesScene.h"
#import "ResourcesLoader.h"

// MainMenuScene
@interface MainMenuScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, ResourceLoaderDelegate> {
}

// returns a CCScene that contains the MainMenuScene as the only child
+(CCScene *) scene;

@end
