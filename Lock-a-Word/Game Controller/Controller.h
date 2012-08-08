//
//  Controller.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright (c) 2012 NOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITextChecker.h>


#define KStreamLength 100

typedef enum
{
    PlasticLock = 1,
    BronzeLock = 2,
    SilverLock = 3,
    GoldLock = 4
}GameMode;




@interface Controller : NSObject

@property (readonly) GameMode currentGameMode;
+ (Controller*) sharedController;

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
- (BOOL)isNewLetterAvailable;


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
- (int)setLevelStars:(int)lettersCountedDown; 
@end

