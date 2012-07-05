//
//  Controller.h
//  TextTwistGame
//
//  Created by Log n Labs on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKitHelper.h"
#import "BlockAlertView.h"
#define kBOARD_SIZE 100
typedef enum
{
    GameModeVertical=0,
    GameModeHorizontal,
    GameModeBoth,
    GameModeDropAll
    
} GameModes;



typedef enum
{
    LettersTypesNormal,
    LettersTypesPanic,
    LettersTypesSmall
} LettersTypes;


@interface Controller : NSObject <GameKitHelperProtocol>{

    NSArray* allLetters;
    
    NSMutableArray* availableLetters;
    NSMutableArray* removedLetters;
    
    NSMutableArray* randomBoardLetters;
    NSMutableArray* randomBoardLettersImages;
    
    NSMutableArray* allWords;
    bool isSwappingVertical;
    
    GameModes gameMode;
    
    GameKitHelper* gkHelper;
    int index;
    int bonus;
    NSMutableArray *firstColumnsNumbers;
    NSMutableArray *bonusColumnsNumbers;
}


@property GameModes gameMode;
@property  (nonatomic,readonly)   NSMutableArray* randomBoardLetters;
@property  (nonatomic,readonly)  NSMutableArray* availableLetters;

@property(nonatomic, assign)GameKitHelper* gkHelper;

+(Controller*) sharedController;


-(NSMutableArray*)getLettersImagesNames:(NSArray*)lettersArray  withLettersType:(LettersTypes)type;
//-(NSMutableArray*)getAvailableLettersImages;
//-(NSMutableArray*)generateRandomBoardImagesWithIsPanicMode:(BOOL)isPanicMode;
//-(NSArray*)swapLettersAtTouchedIndex:(int)index;

//-(void)swapTwoLettersAtIndex1:(int)index1 andIndex2:(int)index2;

//-(BOOL)checkWordWithLettersIndexes:(NSMutableArray*)places;
//-(void)dropLettersAtIndexSet:(NSIndexSet*)indexSet;

-(void)startGameWithMode:(GameModes)newGameMode;



//-(BOOL)checkSameLetters:(NSString*)word;
-(void)preloadResources;
-(void)loadResources;


#pragma mark - Lock A word
-(void)generateRandomGameLetters;
-(NSString*)getCurrentLetter;
-(NSString*)getCurrentLetterImage;
-(void)prepareNextLetter;
-(void)startNewGame;
-(int)getFirstColumnIndexOfRow:(int)row;
-(void)addCurrentLetterToMatrix:(int)row;
-(void)removeWordFromMatrix:(int)row length:(int)length;
-(int)getFirstBonusIndex;
-(void)addCurrentLetterToBonus:(int)colunm;
-(void)removeLetterFromBonus:(int)colunm;
- (BOOL)canAddBonusLetter;
- (BOOL)isCorrectWord:(NSString*)word;

#pragma mark Game Center
-(void)authenticateLocalPlayer;
-(void)showLeaderBoardWithCategory:(NSString*)category;
-(void) submitScore:(int64_t)score category:(NSString*)category;

#pragma mark internet connection
-(BOOL)connectedToWeb;
@end
