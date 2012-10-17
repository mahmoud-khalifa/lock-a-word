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
#import "BlockAlertView.h"

typedef enum
{
    PlasticLock = 1,
    BronzeLock = 2,
    SilverLock = 3,
    GoldLock = 4
}GameMode;


@interface Controller : NSObject<GameKitHelperProtocol>{
    BlockAlertView *loadingView;
}

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
- (void)lockLetter:(int)row andColumn:(int)column;
- (void)addLetterAtIndex:(int)index;
- (void)removeWordAtIndex:(int)index lenght:(int)lenght;
- (int)getFirstColumnIndexOfRow:(int)row;


- (void)addBonusLetterAtIndex:(int)index;
- (void)removeBonusLetterAtIndex:(int)index;
- (int)getFirstBonusIndex;
- (BOOL)canAddBonusLetter;
- (int)getModeStars:(GameMode)mode;
- (void)printBoard;


- (int)calculateLevelStars:(int)lettersCountedDown;
- (int)getcurrentLevelStars;
- (int)getAchievementStars;
- (int)getLevelStars:(int)level;
- (void)updateLevelStars:(int)stars;

//Flurry methods
- (void)logGameStart;
- (void)logGameEnd;
- (void)logGameCompleted;

//In-App purchase methods
-(void)unlockAllGameModes;
-(void)buyFeature:(NSString*)featureId;

-(bool)isGameModesUnlocked;
-(bool)isFeaturePurchased:(NSString*)featureId; -(BOOL)connectedToWeb;

@end

