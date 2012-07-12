//
//  Controller.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright (c) 2012 NOE. All rights reserved.
//

#import "Controller.h"
#import "GameData.h"
#import "GameDataParser.h"
#import "cocos2d.h"

static Controller *instanceOfController;


@implementation Controller {
    CCArray *allLetters;
    int currentIndex;
    int numberOfBonus;
    GameMode currentGameMode;
    int currentLevel;
    
    BOOL board[25];         // 0 -> free, 1-> busy
    BOOL lockedBoard[25];   // 0 -> unlocked, 1-> locked
}



-(void)dealloc {
    [allLetters release];
    [super dealloc];
}
-(id)init {
    if (self=[super init]) {
        // load all letters array weighted (vowels have greater weight)
        NSString *allLettersPlistPath = [[NSBundle mainBundle]  pathForResource:@"all_letters" ofType:@"plist"];
        allLetters=[[CCArray alloc]initWithNSArray:[[NSArray alloc] initWithContentsOfFile:allLettersPlistPath]];
        [self printBoard];
    }
    return self;
}
#pragma mark Singleton stuff

+(id) alloc {
	@synchronized(self) {
		NSAssert(instanceOfController == nil, @"Attempted to allocate a second instance of the singleton: Game Controller");
		instanceOfController = [[super alloc] retain];
        
		return instanceOfController;
	}
	// to avoid compiler warning
	return nil;
}

+ (Controller*) sharedController {
	@synchronized(self) {
		if (instanceOfController == nil) {
			instanceOfController = [[Controller alloc] init];
		}
        return instanceOfController;
	}
	// to avoid compiler warning
	return nil;
}



#pragma mark - Leveling
- (void)selectChapter:(int)chapter {
    GameData *gameData = [GameDataParser loadData];
    [gameData setSelectedChapter:chapter];
    [GameDataParser saveData:gameData];
    [gameData release];
    
    currentGameMode = chapter;
}



- (void)selectLevel:(int)level {
    GameData *gameData = [GameDataParser loadData];
    [gameData setSelectedLevel:level];
    [GameDataParser saveData:gameData];
    [gameData release];

    currentLevel = level;
    [self newGame];
}


#pragma mark init/preparations 
- (void)newGame {
    [self resetBoard];
    CCLOG(@"NewGame");
    switch (currentGameMode) {
        case BronzeLock:
            CCLOG(@"BronzeLock");
            board[0]=1;board[6]=1;board[12]=1;
            lockedBoard[0]=1;lockedBoard[6]=1;lockedBoard[12]=1;
            break;
            
        case SilverLock:
            CCLOG(@"SilverLock");
            board[0]=1;board[5]=1;board[10]=1;
            board[1]=1;board[6]=1;board[11]=1;
            
            lockedBoard[0]=1;lockedBoard[5]=1;lockedBoard[10]=1;
            lockedBoard[1]=1;lockedBoard[6]=1;lockedBoard[11]=1;
            break;
            
        case GoldLock:
            CCLOG(@"GoldLock");
            board[0]=1;board[5]=1;board[10]=1;
            board[4]=1;board[9]=1;board[14]=1;
            
            lockedBoard[0]=1;lockedBoard[5]=1;lockedBoard[10]=1;
            lockedBoard[4]=1;lockedBoard[9]=1;lockedBoard[14]=1;
            break;
            
        default:
            CCLOG(@"PlasticLock");
            break;
    }
    
    
    [self printBoard];
}


- (void)resetBoard {
    
    board[0]=0;board[1]=0;board[2]=0;board[3]=0;board[4]=0;
    board[5]=0;board[6]=0;board[7]=0;board[8]=0;board[9]=0;
    board[10]=0;board[11]=0;board[12]=0;board[13]=0;board[14]=0;
    board[15]=0;board[16]=0;board[17]=0;board[18]=0;board[19]=0;
    board[20]=0;board[21]=0;board[22]=0;board[23]=0;board[24]=0;

    lockedBoard[0]=0;lockedBoard[1]=0;lockedBoard[2]=0;lockedBoard[3]=0;lockedBoard[4]=0;
    lockedBoard[5]=0;lockedBoard[6]=0;lockedBoard[7]=0;lockedBoard[8]=0;lockedBoard[9]=0;
    lockedBoard[10]=0;lockedBoard[11]=0;lockedBoard[12]=0;lockedBoard[13]=0;lockedBoard[14]=0;
    lockedBoard[15]=0;lockedBoard[16]=0;lockedBoard[17]=0;lockedBoard[18]=0;lockedBoard[19]=0;
    lockedBoard[20]=0;lockedBoard[21]=0;lockedBoard[22]=0;lockedBoard[23]=0;lockedBoard[24]=0;

}

#pragma mark - Testing
- (void)printBoard {
    CCLOG(@"board");
    for (int i=0; i<5; i++) {
        CCLOG(@"%d %d %d %d %d",board[i*5+0],board[i*5+1],board[i*5+2],board[i*5+3],board[i*5+4]);
    }
    CCLOG(@"lockedBoard");
    for (int i=0; i<5; i++) {
        CCLOG(@"%d %d %d %d %d",lockedBoard[i*5+0],lockedBoard[i*5+1],lockedBoard[i*5+2],lockedBoard[i*5+3],lockedBoard[i*5+4]);
    }
}


@end