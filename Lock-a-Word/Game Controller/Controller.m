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
#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"
//#import "cocos2d.h"

#import "StatisticsCollector.h"

#import <SystemConfiguration/SystemConfiguration.h>

static Controller *instanceOfController;

@interface Controller()
@property (nonatomic,strong) NSArray *secondLetters;

@end

@implementation Controller {
    NSArray *allLetters;
    int currentIndex;
    int numberOfBonus;
//    int currentLevel;
    NSString *lockedLetter;
    NSArray *secondLetters;
    
    BOOL board[25];         // 0 -> free, 1-> busy
    BOOL lockedBoard[25];   // 0 -> unlocked, 1-> locked
    BOOL bonusRow[5];
    int numOfBonusLetters;
    int numOfGeneratedLetters;
    NSString *currentLetter;
    NSString *lastLetter;
    
    GameKitHelper* gkHelper;
    
}

@synthesize secondLetters;
@synthesize currentGameMode;
@synthesize currentLevel;
@synthesize gameStarted;
@synthesize gkHelper;

-(void)dealloc {
    [allLetters release];
    [super dealloc];
}
-(id)init {
    if (self=[super init]) {
        // load all letters array weighted (vowels have greater weight)
        NSString *allLettersPlistPath = [[NSBundle mainBundle]  pathForResource:@"all_letters" ofType:@"plist"];
        allLetters=[[NSArray alloc] initWithContentsOfFile:allLettersPlistPath];
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

#pragma mark GameCenter Methods
-(void)authenticateLocalPlayer{
    gkHelper = [GameKitHelper sharedGameKitHelper];
    if ([self connectedToWeb]) {
        if ([GKLocalPlayer localPlayer].authenticated==NO) {
            [gkHelper authenticateLocalPlayer];
        }
    }
    
}

-(BOOL)connectedToWeb {
	BOOL connected;
	const char *host = "www.google.com";
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host);
	SCNetworkReachabilityFlags flags;
	connected = SCNetworkReachabilityGetFlags(reachability, &flags);
	BOOL isConnected = connected && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
	return isConnected;
}

#pragma mark - Leveling
- (void)selectChapter:(int)chapter {
    //Chapter = mode
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
    
    Levels *levels = [LevelParser loadLevelsForChapter:currentGameMode];
    for (Level *gameLevel in levels.levels) {
        if (gameLevel.number == currentLevel) {
            lockedLetter = gameLevel.name;
            self.secondLetters = [gameLevel.data componentsSeparatedByString:@","];
        }
    }
    
    [self newGame];
}
- (int)setLevelStars:(int)lettersCountedDown 
{
    int stars = 1;
    if (lettersCountedDown >= 20){
        stars=3;        
    }
    else if(lettersCountedDown >= 10) {
        stars=2;
    }
    
    Levels *levels = [LevelParser loadLevelsForChapter:currentGameMode];
    Level *gameLevel;
    for (gameLevel in levels.levels) {
        if (gameLevel.number == currentLevel && gameLevel.stars < stars) {
            gameLevel.stars = stars;
        } 
    }
    [LevelParser saveData:levels forChapter:currentGameMode];

    return stars;
}


#pragma mark init/preparations 

-(void)newGame
    {
    [self resetBoard];
    NSLog(@"NewGame");
    
        switch (currentGameMode) 
        {
        case BronzeLock:
            NSLog(@"BronzeLock");
            board[0]=1;board[6]=1;board[12]=1;
            lockedBoard[0]=1;lockedBoard[6]=1;lockedBoard[12]=1;
            break;
            
        case SilverLock:
            NSLog(@"SilverLock");
            board[0]=1;board[5]=1;board[10]=1;
            board[1]=1;board[6]=1;board[11]=1;
            
            lockedBoard[0]=1;lockedBoard[5]=1;lockedBoard[10]=1;
            lockedBoard[1]=1;lockedBoard[6]=1;lockedBoard[11]=1;
            break;
            
        case GoldLock:
            NSLog(@"GoldLock");
            board[0]=1;board[5]=1;board[10]=1;
            board[4]=1;board[9]=1;board[14]=1;
            
            lockedBoard[0]=1;lockedBoard[5]=1;lockedBoard[10]=1;
            lockedBoard[4]=1;lockedBoard[9]=1;lockedBoard[14]=1;
            break;
            
        default:
            NSLog(@"PlasticLock");
            break;
        }
    
    lastLetter = @"";
    [self printBoard];
}

- (NSArray*)getLockedLetters {
    NSMutableArray *lockedLetters;
    if (currentGameMode == PlasticLock) {
        lockedLetters = nil;
    } else if (currentGameMode == BronzeLock) {
        lockedLetters = [[NSMutableArray alloc] initWithCapacity:3]; //only three locked letters
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"0", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"6", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"12", @"index", nil];
        [lockedLetters addObject:dic];
        
    } else if (currentGameMode == SilverLock) {
        //At index 0, 5, 10 are the same. At index 1, 6, 11 are not
        lockedLetters = [[NSMutableArray alloc] initWithCapacity:6];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"0", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"5", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"10", @"index", nil];
        [lockedLetters addObject:dic];
        
        int secondLetterscount = [secondLetters count];
        NSString *secondLetter = [secondLetters objectAtIndex:arc4random()%secondLetterscount];
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:secondLetter, @"letter", @"1", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        secondLetter = [secondLetters objectAtIndex:arc4random()%secondLetterscount];
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:secondLetter, @"letter", @"6", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        secondLetter = [secondLetters objectAtIndex:arc4random()%secondLetterscount];
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:secondLetter, @"letter", @"11", @"index", nil];
        [lockedLetters addObject:dic];
        
        
    } else if (currentGameMode == GoldLock) {
        //At index 0, 5, 10 are the same. At index 4, 9, 14 are not
        lockedLetters = [[NSMutableArray alloc] initWithCapacity:6];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"0", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"5", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:lockedLetter, @"letter", @"10", @"index", nil];
        [lockedLetters addObject:dic];
        
        int secondLetterscount = [secondLetters count];
        NSString *secondLetter = [secondLetters objectAtIndex:arc4random()%secondLetterscount];
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:secondLetter, @"letter", @"4", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        secondLetter = [secondLetters objectAtIndex:arc4random()%secondLetterscount];
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:secondLetter, @"letter", @"9", @"index", nil];
        [lockedLetters addObject:dic];
        
        
        secondLetter = [secondLetters objectAtIndex:arc4random()%secondLetterscount];
        dic = [[NSDictionary alloc] initWithObjectsAndKeys:secondLetter, @"letter", @"14", @"index", nil];
        [lockedLetters addObject:dic];
    }   
    return lockedLetters;
}


- (BOOL)isGameCompleted {
    for (int i=0; i<25; i++) {
        if(!lockedBoard[i])
            return NO;
    }
    return YES;
}


- (void)resetBoard {
    
    //initialize with free labels
    board[0]=0;board[1]=0;board[2]=0;board[3]=0;board[4]=0;
    board[5]=0;board[6]=0;board[7]=0;board[8]=0;board[9]=0;
    board[10]=0;board[11]=0;board[12]=0;board[13]=0;board[14]=0;
    board[15]=0;board[16]=0;board[17]=0;board[18]=0;board[19]=0;
    board[20]=0;board[21]=0;board[22]=0;board[23]=0;board[24]=0;

    //initialize with unlocked labels
    lockedBoard[0]=0;lockedBoard[1]=0;lockedBoard[2]=0;lockedBoard[3]=0;lockedBoard[4]=0;
    lockedBoard[5]=0;lockedBoard[6]=0;lockedBoard[7]=0;lockedBoard[8]=0;lockedBoard[9]=0;
    lockedBoard[10]=0;lockedBoard[11]=0;lockedBoard[12]=0;lockedBoard[13]=0;lockedBoard[14]=0;
    lockedBoard[15]=0;lockedBoard[16]=0;lockedBoard[17]=0;lockedBoard[18]=0;lockedBoard[19]=0;
    lockedBoard[20]=0;lockedBoard[21]=0;lockedBoard[22]=0;lockedBoard[23]=0;lockedBoard[24]=0;

    //initialize with free labels
    bonusRow[0]=0;bonusRow[1]=0;bonusRow[2]=0;bonusRow[3]=0;bonusRow[4]=0;
    numOfBonusLetters = 0;
    
    //No letters generated yet
    numOfGeneratedLetters = 0;
}

#pragma mark - validation
- (BOOL)isCorrectWord:(NSString*)word {
    #warning remove next line
    return YES;
    
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSLocale *currentLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    NSString *currentLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSRange searchRange = NSMakeRange(0, [word length]);
    
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:word range:searchRange startingAt:0 wrap:NO language: currentLanguage];
    return misspelledRange.location == NSNotFound;

}

- (BOOL)isNewLetterAvailable {
    return numOfGeneratedLetters < KStreamLength ;
}


# pragma mark - letters generations

- (void)prepareCurrentLetter {
    //get next letter to display
    currentLetter = [allLetters objectAtIndex:arc4random()%[allLetters count]];
}

- (void)prepareCurrentLetterWithRestrictions:(NSString*)restriction {
    currentLetter = [allLetters objectAtIndex:arc4random()%[allLetters count]];
    while ([restriction rangeOfString:currentLetter].location != NSNotFound && ![currentLetter isEqualToString:lastLetter]) {
        currentLetter = [allLetters objectAtIndex:arc4random()%[allLetters count]];
    }
    lastLetter = currentLetter;
}
- (NSString*)getCurrentLetter {
    return currentLetter;
}
#pragma mark - locking & board management

- (BOOL)isLockedPosition:(int)index {
    return lockedBoard[index];
}

- (void)lockRow:(int)row {
    for (int i=0; i<5; i++) {
        lockedBoard[row*5+i] = 1;
        
    }
}

- (void)addLetterAtIndex:(int)index {
    board[index] = 1;
}

- (void)removeWordAtIndex:(int)index lenght:(int)lenght {
    int i;
    for (i=0; i<lenght; i++) {
        board[index+i] = 0;
    }
    //move the remaining letters of the word to the left
    while ((index+i)%5 != 0) {
        if (lockedBoard[index+i]) {
            break;
        }
        board[index+i-lenght] = board[index+i];
        board[index+i] = 0;
        i++;
    }
}


- (int)getFirstColumnIndexOfRow:(int)row {
    for (int i=0; i<5; i++) {
        if (!board[row*5+i]) {
            return i;
        }
    }
    return 5;
}

#pragma mark - Bonus

- (void)addBonusLetterAtIndex:(int)index {
    bonusRow[index] = 1;
    numOfBonusLetters++;
}

- (void)removeBonusLetterAtIndex:(int)index {
    bonusRow[index] = 0;
    numOfBonusLetters--;
}


- (int)getFirstBonusIndex {
    for (int i=0; i<5; i++) {
        if (!bonusRow[i]) {
            return i;
        }
    }
    return 5;
}

- (BOOL)canAddBonusLetter
{
    return numOfBonusLetters < 5;
}

- (int)getModeStars:(GameMode)mode {
    //Chapter = mode
    Levels *levels = [LevelParser loadLevelsForChapter:mode];
    int stars = 3;
    for (Level *gameLevel in levels.levels) {
        if (gameLevel.stars < stars) {
            stars = gameLevel.stars;
        }
    }
    return stars;
}
#pragma mark - Testing

- (void)printBoard {
    NSLog(@"board");
    for (int i=0; i<5; i++) {
        NSLog(@"%d %d %d %d %d",board[i*5+0],board[i*5+1],board[i*5+2],board[i*5+3],board[i*5+4]);
    }
    NSLog(@"lockedBoard");
    for (int i=0; i<5; i++) {
        NSLog(@"%d %d %d %d %d",lockedBoard[i*5+0],lockedBoard[i*5+1],lockedBoard[i*5+2],lockedBoard[i*5+3],lockedBoard[i*5+4]);
    }
}

#pragma Log Flurry Events
- (void)logGameStart
{
    gameStarted = YES;
    switch (currentGameMode) {
        case PlasticLock:
            [StatisticsCollector logEvent:@"Single-player_PlasticLock_Level # 1" timed:YES];
            break;
        case BronzeLock:
            [StatisticsCollector logEvent:[NSString stringWithFormat:@"Single-player_BronzeLock_Level # %d", currentLevel] timed:YES];
            break;
        case SilverLock:
            [StatisticsCollector logEvent:[NSString stringWithFormat:@"Single-player_SilverLock_Level # %d", currentLevel] timed:YES];
            break;
        case GoldLock:
            [StatisticsCollector logEvent:[NSString stringWithFormat:@"Single-player_GoldLock_Level # %d", currentLevel] timed:YES];
            break;
                
        default:
            break;
    }
    
}

- (void)logGameEnd
{
    if (!gameStarted) {
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"Exit" forKey:@"Result"];
    
    switch (currentGameMode) {
        case PlasticLock:
            [StatisticsCollector endTimedEvent:@"Single-player_PlasticLock_Level # 1" withParameters:params];
            break;
        case BronzeLock:
            [StatisticsCollector endTimedEvent:[NSString stringWithFormat:@"Single-player_BronzeLock_Level # %d", currentLevel] withParameters:params];
            break;
        case SilverLock:
            [StatisticsCollector endTimedEvent:[NSString stringWithFormat:@"Single-player_SilverLock_Level # %d", currentLevel] withParameters:params];
            break;
        case GoldLock:
            [StatisticsCollector endTimedEvent:[NSString stringWithFormat:@"Single-player_GoldLock_Level # %d", currentLevel] withParameters:params];
            break;
                
        default:
            break;
    }
    
}

- (void)logGameCompleted
{
    gameStarted = NO;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"Completed" forKey:@"Result"];
    
    switch (currentGameMode) {
        case PlasticLock:
            [StatisticsCollector endTimedEvent:@"Single-player_PlasticLock_Level # 1" withParameters:params];
            break;
        case BronzeLock:
            [StatisticsCollector endTimedEvent:[NSString stringWithFormat:@"Single-player_BronzeLock_Level # %d", currentLevel] withParameters:params];
            break;
        case SilverLock:
            [StatisticsCollector endTimedEvent:[NSString stringWithFormat:@"Single-player_SilverLock_Level # %d", currentLevel] withParameters:params];
            break;
        case GoldLock:
            [StatisticsCollector endTimedEvent:[NSString stringWithFormat:@"Single-player_GoldLock_Level # %d", currentLevel] withParameters:params];
            break;
                
        default:
            break;
    }
    
}

@end