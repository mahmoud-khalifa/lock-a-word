//
//  GameScene.h
//  Word9
//
//  Created by Log n Labs on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Controller.h"

typedef enum
{
    GameSceneTagSpaceShip=100,
    GameSceneTagSwapAction,
    GameSceneTagVowelLetter,
    GameSceneTagButtons,
    GameSceneTagShareAlert,
    GameSceneTagCountDownTimer
	
} GameSceneTags;

typedef enum
{
    AvailalbeRow = 0,
    CompletedRow = 1,
    LockedRow = 2
}RowStatus;

@interface GameScene : CCLayer
{
    
    Controller* gameController;
    bool isGameOver;
    int levelNum;
    int score;
    CCSprite* instructionsSprite;
    CCMenu* backButtons;
    CCSpriteFrameCache*frameCache;
    CCLabelBMFont* scoreLabel;
    NSMutableArray *newLetters;
    NSMutableArray* boardLetters;
    NSMutableArray *bonusLetters;
    NSMutableArray *bonusLettersImages;
//    NSString *currentLetter;
    NSString *currentLetterImage;
    NSString *currentLetter;
    BOOL selectingWord;
    BOOL correctWordFound;
    BOOL bonusLetterSelected;
    NSMutableArray* collectedWord;
    ccColor3B boardLettersColor;
    
    
    NSMutableArray* rowsStatus;
}
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;



@end
