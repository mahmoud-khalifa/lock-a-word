//
//  Controller.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright (c) 2012 NOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITextChecker.h>
#import "GameKitHelper.h"

typedef enum
{
    PlasticLock = 1,
    BronzeLock = 2,
    SilverLock = 3,
    GoldLock = 4
}GameMode;




@interface Controller : NSObject<GameKitHelperProtocol>

@property (readonly) GameMode currentGameMode;
@property (readonly) int currentLevel;

@property (atomic) BOOL gameStarted;

@property(nonatomic, assign)GameKitHelper* gkHelper;

+ (Controller*) sharedController; //singleton pattern

- (void)authenticateLocalPlayer;
- (BOOL)connectedToWeb;
- (void)selectChapter:(int)chapter;
- (void)selectLevel:(int)level;


- (void)newGame;
- (NSArray*)getLockedLetters;
- (BOOL)isGameCompleted;
- (void)resetBoard;

- (void)prepareCurrentLetter;
- (void)prepareCurrentLetterWithRestrictions:(NSString*)restriction;
- (NSString*)getCurrentLetter;


- (BOOL)isCorrectWord:(NSString*)word;


- (BOOL)isLockedPosition:(int)index;
- (void)lockRow:(int)row;
- (void)addLetterAtIndex:(int)index;
- (void)removeWordAtIndex:(int)index lenght:(int)lenght;
- (int)getFirstColumnIndexOfRow:(int)row;


- (void)addBonusLetterAtIndex:(int)index;
- (void)removeBonusLetterAtIndex:(int)index;
- (int)getFirstBonusIndex;
- (BOOL)canAddBonusLetter;
- (int)getModeStars:(GameMode)mode;
- (void)printBoard;
- (int)updateLevelStars:(int)lettersCountedDown; 

//Flurry methods
- (void)logGameStart;
- (void)logGameEnd;
- (void)logGameCompleted;
@end

