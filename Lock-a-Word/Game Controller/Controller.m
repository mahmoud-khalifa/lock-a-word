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
#import "GameConfig.h"
//#import "cocos2d.h"

#import "StatisticsCollector.h"
#import "SimpleAudioEngine.h"

#import "MKStoreManager.h"

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
    
    int testIndex;
    NSArray *testArray;
    
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

- (int)calculateLevelStars:(int)lettersCountedDown {
    int stars = 1;
    if (lettersCountedDown >= 20){
        stars=3;        
    }
    else if(lettersCountedDown >= 10) {
        stars=2;
    }
    return stars;
}

- (int)getcurrentLevelStars {
    Levels *levels = [LevelParser loadLevelsForChapter:currentGameMode];
    Level *gameLevel;
    for (gameLevel in levels.levels) {
        if (gameLevel.number == currentLevel) {
            return gameLevel.stars;
        } 
    }
    return 0;
}

- (int)getAchievementStars{
    int modStars = [self getModeStars:currentGameMode];
    if (modStars>0) {
        NSString *achievementID = @"";
        switch (currentGameMode) {
            case PlasticLock:
                achievementID = kAchievementID_WinPlasticMode;
                break;
            case BronzeLock:
                achievementID = kAchievementID_WinBronzeMode;
                break;
            case SilverLock:
                achievementID = kAchievementID_WinSilverMode;
                break;
            case GoldLock:
                achievementID = kAchievementID_WinGoldMode;
                break;
            default:
                break;
        }
        achievementID = [achievementID stringByAppendingFormat:@"_%d",modStars];
        if ([[NSUserDefaults standardUserDefaults]boolForKey:achievementID] == YES){
            return 0;
        }
        else{
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:achievementID];
            [gkHelper reportAchievementWithID:achievementID percentComplete:100.0f];
            return modStars;
        }
    }
    return 0;
}

- (int)getLevelStars:(int)level{
    Levels *levels = [LevelParser loadLevelsForChapter:currentGameMode];
    Level *gameLevel;
    for (gameLevel in levels.levels) {
        if (gameLevel.number == level) {
            return gameLevel.stars;
        }
    }
    return 0;
}

- (void)updateLevelStars:(int)stars {
    Levels *levels = [LevelParser loadLevelsForChapter:currentGameMode];
    Level *gameLevel;
    for (gameLevel in levels.levels) {
        if (gameLevel.number == currentLevel && gameLevel.stars < stars) {
            gameLevel.stars = stars;
            [LevelParser saveData:levels forChapter:currentGameMode];
        } 
    }
}


#pragma mark init/preparations 

-(void)newGame{
    testIndex = 0;
    testArray = 
    [[NSArray alloc] initWithObjects: @"t", @"o", @"t", @"a", @"l", @"s", @"c", @"e", @"n", @"e", @"q", @"u", @"e", @"e", @"n", @"t", @"i", @"t", @"l", @"e", @"c", @"o", @"a", @"s", @"t", nil];
    
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
//    [[SimpleAudioEngine sharedEngine]playEffect:@"Applause.mp3"];
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
//    return YES;
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSLocale *currentLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    NSString *currentLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSRange searchRange = NSMakeRange(0, [word length]);
    
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:word range:searchRange startingAt:0 wrap:NO language: currentLanguage];
    return misspelledRange.location == NSNotFound;
}


# pragma mark - letters generations

- (void)prepareCurrentLetter {
    //get next letter to display
    currentLetter = [allLetters objectAtIndex:arc4random()%[allLetters count]];
}

- (void)prepareCurrentLetterWithRestrictions:(NSString*)restriction {
    if ([lastLetter isEqualToString:@"q"]) {
        currentLetter = @"u";
    }else{
        currentLetter = [allLetters objectAtIndex:arc4random()%[allLetters count]];
        while ( ([restriction rangeOfString:currentLetter].location != NSNotFound) || ([currentLetter isEqualToString:lastLetter]) ) {
            currentLetter = [allLetters objectAtIndex:arc4random()%[allLetters count]];
        }
    }
    lastLetter = currentLetter;
//    if (testIndex < 25) {
//        currentLetter = [testArray objectAtIndex:testIndex++];
//    }
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

- (void)unLockRow:(int)row {
    for (int i=0; i<5; i++) {
        lockedBoard[row*5+i] = 0;
    }
}

- (void)lockLetter:(int)row andColumn:(int)column{
    lockedBoard[row*5+column] = 1;
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    switch (currentGameMode) {
        case PlasticLock:
            [params setObject:@"PlasticLock" forKey:@"GameMode"];
            break;
        case BronzeLock:
            [params setObject:@"BronzeLock" forKey:@"GameMode"];
            break;
        case SilverLock:
            [params setObject:@"SilverLock" forKey:@"GameMode"];
            break;
        case GoldLock:
            [params setObject:@"GoldLock" forKey:@"GameMode"];
            break;
                
        default:
            break;
    }
    
    [StatisticsCollector logEvent:@"GamePlayed" withParameters:params timed:YES];
}

- (void)logGameEnd
{
    if (!gameStarted) {
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    switch (currentGameMode) {
        case PlasticLock:
            [params setObject:@"PlasticLock" forKey:@"GameMode"];
            break;
        case BronzeLock:
            [params setObject:@"BronzeLock" forKey:@"GameMode"];
            break;
        case SilverLock:
            [params setObject:@"SilverLock" forKey:@"GameMode"];
            break;
        case GoldLock:
            [params setObject:@"GoldLock" forKey:@"GameMode"];
            break;
            
        default:
            break;
    }
    [StatisticsCollector endTimedEvent:@"GamePlayed" withParameters:params];
    [StatisticsCollector logEvent:@"ExitGame" withParameters:params];
}

- (void)logGameCompleted
{
    gameStarted = NO;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    switch (currentGameMode) {
        case PlasticLock:
            [params setObject:@"PlasticLock" forKey:@"GameMode"];
            break;
        case BronzeLock:
            [params setObject:@"BronzeLock" forKey:@"GameMode"];
            break;
        case SilverLock:
            [params setObject:@"SilverLock" forKey:@"GameMode"];
            break;
        case GoldLock:
            [params setObject:@"GoldLock" forKey:@"GameMode"];
            break;
            
        default:
            break;
    }
    [StatisticsCollector endTimedEvent:@"GamePlayed" withParameters:params];
    [StatisticsCollector logEvent:@"CompleteLevel" withParameters:params];    
}

#pragma in-App Purchase

-(void)unlockAllGameModes{
    [self buyFeature:kUNLOCK_ALL_MODES_ID];
}

-(void)buyFeature:(NSString*)featureId{
    if ([self connectedToWeb]) {
        [[MKStoreManager sharedManager] buyFeature:featureId 
                                        onComplete:^(NSString* purchasedFeature)
         {
             CCLOG(@"Purchased: %@", purchasedFeature);
             
             [loadingView dismissWithClickedButtonIndex:-1 animated:NO];
             
             //         UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"Success" message: @"Transaction was completed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             //         [alert show];
             //         [alert release];
             
             BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Success" message:@"Transaction was completed" andLoadingviewEnabled:NO];
             [alert setCancelButtonWithTitle:@"OK" block:nil];
             [alert show];
//             [delegatoe onPurchaseFeatureCompleted:featureId];
             
             [[NSUserDefaults standardUserDefaults]setBool:YES forKey:featureId];
         }
                                       onCancelled:^
         {
             CCLOG(@"User Cancelled Transaction");
             
             [loadingView dismissWithClickedButtonIndex:-1 animated:NO];
             
             //         UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"Operation Cancelled" message:@"Transaction was cancelled" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
             //         [alert show];
             //         [alert release];
             
             BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Operation Cancelled" message:@"" andLoadingviewEnabled:NO];
             [alert setCancelButtonWithTitle:@"Close" block:nil];
             [alert show];
         }];
           
        loadingView=[BlockAlertView alertWithTitle:nil message:@"Please wait..." andLoadingviewEnabled:YES];
        [loadingView show];
    }else {
        BlockAlertView* alert=[BlockAlertView alertWithTitle:@"No Internet Connection" message:@"Please Connect to the Internet then try again" andLoadingviewEnabled:NO];
        [alert setCancelButtonWithTitle:@"OK" block:nil];
        [alert show];
    }
}

-(bool)isGameModesUnlocked
{
    return [self isFeaturePurchased:kUNLOCK_ALL_MODES_ID];
}

-(bool)isFeaturePurchased:(NSString*)featureId{
    if ([self connectedToWeb]) {
        bool isFeaturePurchasedBefore=[MKStoreManager  isFeaturePurchased:featureId];
        [[NSUserDefaults standardUserDefaults] setBool:isFeaturePurchasedBefore forKey:featureId];
        return [MKStoreManager  isFeaturePurchased:featureId];
    }else {
        return  [[NSUserDefaults standardUserDefaults]boolForKey:featureId];
    }

}


@end