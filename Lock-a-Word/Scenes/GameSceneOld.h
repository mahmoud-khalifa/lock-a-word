//
//  GameSceneOld.h
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
    GameSceneTagSpaceShip=500,
    GameSceneTagSwapAction,
    GameSceneTagVowelLetter,
    GameSceneTagButtons,
    GameSceneTagShareAlert,
    GameSceneTagCountDownTimer
	
} GameSceneTags;



@interface GameSceneOld : CCLayer
{
    
    NSMutableArray* availableLettersImages;
    NSMutableArray* availableLettersSprites;
    Controller* gameController;
    
    NSMutableArray* boardLettersSprites;
    
    bool isSwapping;
    NSMutableArray* collectedWord;
    
//    int numberOfCorrectWords;
    
    NSMutableArray* rightSprites;
    NSMutableArray* rightLetters;

    
    
    NSMutableArray* droppedLettersSprites;
    NSMutableArray* droppedLettersImages;
    
    int lowerLettersRowIndex;
    int lowerLettersColIndex;
    CCLabelBMFont* scoreLabel;
    int score;
    
    CCLabelBMFont* timerLabel;
//    CCLabelBMFont* lastWordTimeLabel;
    
    float totalTime;
	int myTime;
    BOOL isPanicMode;
    
    CCLabelBMFont* countDownTimerLabel;
    float countDownTotalTime;
    int myCountDownTime;
    
    ccColor3B boardLettersColor;
    
    GameModes gameMode;
    
    BOOL enableRandomSwap;
    
    CCSprite* randomSprite;
    
    BOOL mustDropAllLetters;
    NSString* vowelLetter;
    NSArray* allVowelLetters;
    
//    CCSprite* swappedSprite1;
//    CCSprite* swappedSprite2;
    
    int swappedIndex1;
    int swappedIndex2;
    
    NSString* EventName;
    
    bool isGameOver;
    
    CCSprite* InstructionsSprite;
    
    CCMenu* buttons;
    CCMenu* backButtons;
    bool isNewHighScore;
    
    int levelNum;
    
    
    CCLabelBMFont * bonusLabel;
    
    CCSpriteFrameCache*frameCache;
    
    int targetLevelScore;
    
    CCLabelBMFont* targetLabel;
}
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(id) initWithGameMode:(GameModes)mode andMustDropAllLetters:(BOOL)must;


@end
