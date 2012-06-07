//
//  Controller.m
//  TextTwistGame
//
//  Created by Log n Labs on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import <UIKit/UITextChecker.h>
#import "SimpleAudioEngine.h"

#import <SystemConfiguration/SCNetworkReachability.h>
@implementation Controller
@synthesize gameMode;
@synthesize randomBoardLetters;
@synthesize availableLetters;

@synthesize gkHelper;

static Controller *instanceOfController;

-(void)dealloc{
    
    [allLetters release];
    
    [availableLetters release];
    [removedLetters release];
    
    [randomBoardLetters release];
    
    [instanceOfController release];
    [randomBoardLettersImages release];
	instanceOfController = nil;
    
    gkHelper=nil;
    
    [super dealloc];
}
-(id)init{
    self=[super init];
    if (self) {
        NSString *allLettersPlistPath = [[NSBundle mainBundle]  pathForResource:@"all_letters" ofType:@"plist"];
        
        allLetters=[[NSArray alloc] initWithContentsOfFile:allLettersPlistPath];
        
        availableLetters=[[NSMutableArray alloc]initWithArray:allLetters];
        
        removedLetters=[[NSMutableArray alloc]init];
        randomBoardLetters=[[NSMutableArray alloc]init]; 
        randomBoardLettersImages = [[NSMutableArray alloc] init];
        isSwappingVertical=NO;
        
        [self preloadResources];
        
        //Game Center:
        gkHelper = [GameKitHelper sharedGameKitHelper];
        gkHelper.delegate = self;
    }
    return self;
}
#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfController == nil, @"Attempted to allocate a second instance of the singleton: Game Controller");
		instanceOfController = [[super alloc] retain];
        
		return instanceOfController;
	}
	// to avoid compiler warning
	return nil;
}

+(Controller*) sharedController
{
	@synchronized(self)
	{
		if (instanceOfController == nil)
		{
			[[Controller alloc] init];
		}
        return instanceOfController;
	}
	// to avoid compiler warning
	return nil;
}

-(void)startGameWithMode:(GameModes)newGameMode{
    gameMode = newGameMode;
    if ([availableLetters count]<[allLetters count]) {
        [availableLetters removeAllObjects];
        [availableLetters addObjectsFromArray:allLetters];
    }
	
    if (self.gameMode==GameModeVertical) {
        isSwappingVertical=YES;
    }else {
        isSwappingVertical=NO;
    }
}

-(NSMutableArray*)getLettersImagesNames:(NSArray*)lettersArray withLettersType:(LettersTypes)type{
    NSMutableArray* array=[[NSMutableArray alloc]initWithCapacity:[lettersArray count]];
    NSString* imageName=[[[NSString alloc]init] autorelease];
    NSString* modeString;
    switch (type) {
        case LettersTypesNormal:
            modeString=@"";
            break;
        case LettersTypesPanic:
            modeString=@"_panic";
            break;
        case LettersTypesSmall:
            modeString=@"_small";
            break;
        default:
            break;
    }
    
    for (NSString* s in lettersArray) {
        imageName=[NSString stringWithFormat:@"%@%@.png",s,modeString];
        [array addObject:imageName];
    }
    return [array autorelease];
}

-(NSMutableArray*)getAvailableLettersImages{
    return [self getLettersImagesNames:availableLetters withLettersType:LettersTypesSmall];
}

-(NSMutableArray*)generateRandomBoardImagesWithIsPanicMode:(BOOL)isPanicMode{
    [randomBoardLetters removeAllObjects];
    for (int i=0; i<kBOARD_SIZE;i++ ) {
        [randomBoardLetters addObject:[availableLetters objectAtIndex:arc4random()%[availableLetters count]]];
        
    }   
    LettersTypes type;
    if (isPanicMode) {
        type=LettersTypesPanic;
    }else{
        type=LettersTypesNormal;
    }
    return [self getLettersImagesNames:randomBoardLetters withLettersType:type];
    
}


-(NSArray*)swapLettersAtTouchedIndex:(int)index{
    int index1,index2;
    
    NSArray*indexes=[[NSArray alloc]init];
    if ((int)(index/5)!=0 &&(int)(index/5)!=4 &&isSwappingVertical) { //Swap Vertical
        
        index1=index-5;
        index2=index+5;
        
        indexes=[NSArray arrayWithObjects:[NSNumber numberWithInt:index1],[NSNumber numberWithInt:index2], nil];
        
        if (gameMode==GameModeBoth ||gameMode== GameModeDropAll) {
            isSwappingVertical=!isSwappingVertical;
        }
        
    }else if(index%5!=0 && index%5!=4 && !isSwappingVertical){ //Swap Horizontal
        
        index1=index-1;
        index2=index+1;
        
        indexes=[NSArray arrayWithObjects:[NSNumber numberWithInt:index1],[NSNumber numberWithInt:index2], nil];
        if (gameMode==GameModeBoth ||gameMode== GameModeDropAll) {
            isSwappingVertical=!isSwappingVertical;
        }
    }
    
    if ([indexes count]>0) {
        
        [self swapTwoLettersAtIndex1:index1 andIndex2:index2];
    }
    
    
    return indexes ;
    
}
-(void)swapTwoLettersAtIndex1:(int)index1 andIndex2:(int)index2{
    NSString* letter1=[randomBoardLetters objectAtIndex:index1];
    NSString* letter2=[randomBoardLetters objectAtIndex:index2];
    
    [randomBoardLetters replaceObjectAtIndex:index1 withObject:letter2];
    
    [randomBoardLetters replaceObjectAtIndex:index2 withObject:letter1];
    
    
}

-(BOOL)checkWordWithLettersIndexes:(NSMutableArray*)places{
    
    NSString* word=[[NSString alloc]init];
    for (NSNumber* place in places) {
        word=[NSString stringWithFormat:@"%@%@",word,[randomBoardLetters objectAtIndex:[place intValue]]];
    }
    NSLog(@"collected Word:%@",word);
    
    bool isSameLetters=[self checkSameLetters:word];
    
    if (!isSameLetters) {
        
        UITextChecker *checker = [[UITextChecker alloc] init];
        NSLocale *currentLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
        NSString *currentLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
        NSRange searchRange = NSMakeRange(0, [word length]);
        
        NSRange misspelledRange = [checker rangeOfMisspelledWordInString:word range: searchRange startingAt:0 wrap:NO language: currentLanguage ];
        return misspelledRange.location == NSNotFound;
    }else{
        
        return NO;
    }
}


-(void)dropLettersAtIndexSet:(NSIndexSet*)indexSet{
    [removedLetters addObjectsFromArray:[availableLetters objectsAtIndexes:indexSet]];
    [availableLetters removeObjectsAtIndexes:indexSet];
}


-(BOOL)checkSameLetters:(NSString*)word{
    
    bool sameLetters=NO;
    
    NSUInteger length = [word length];
    NSMutableArray *chars=[[NSMutableArray alloc]initWithCapacity:length];
    for (int i = 0; i < length; ++i) {
        [chars addObject:[NSString stringWithFormat:@"%c",[word characterAtIndex:i]]];
    }
    for (int i=0; i<length-1; i++) {
        if ([[chars objectAtIndex:i] isEqualToString:[chars objectAtIndex:i+1]]) {
            sameLetters=YES;
        }else{
            sameLetters=NO;
            break;
        }
    }
    
    
    return sameLetters;
}

#pragma mark preload resources
-(void)preloadResources{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Task completed, update view in main thread (note: view operations should
    // be done only in the main thread)
    [self performSelectorOnMainThread:@selector(loadResources) withObject:nil waitUntilDone:NO];
    
    [pool release];
}
-(void)loadResources{
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"panic_room.mp3"];
}




#pragma mark - Lock A word
-(void)generateRandomGameLetters{
    [randomBoardLetters removeAllObjects];
    [randomBoardLettersImages removeAllObjects];
    for (int i=0; i<kBOARD_SIZE;i++ ) {
        [randomBoardLetters addObject:[allLetters objectAtIndex:arc4random()%[allLetters count]]];
    }   
    randomBoardLettersImages = [[NSMutableArray alloc] initWithArray:[self getLettersImagesNames:randomBoardLetters withLettersType:LettersTypesNormal]];
    
}

-(NSString*)getCurrentLetter
{
    if (index > kBOARD_SIZE -1) {
        return nil;
    }
    return [randomBoardLetters objectAtIndex:index];
}

-(NSString*)getCurrentLetterImage
{
    if (index > kBOARD_SIZE -1) {
        return nil;
    }
    return [randomBoardLettersImages objectAtIndex:index];
}

-(void)prepareNextLetter
{
    if (index  > kBOARD_SIZE -2) {
        return;
    }
    index++;
}
-(void)startNewGame{
    index = 0;
    bonus = 0;
    [self generateRandomGameLetters];
    firstColumnsNumbers = [[NSMutableArray alloc]initWithObjects:@"0", @"0", @"0", @"0", @"0", nil];
    bonusColumnsNumbers = [[NSMutableArray alloc]initWithObjects:@"0", @"0", @"0", @"0", @"0", nil];
}
-(int)getFirstColumnIndexOfRow:(int)row {
    return [[firstColumnsNumbers objectAtIndex:row] intValue];
}
-(void)addCurrentLetterToMatrix:(int)row {
    int colunm = [self getFirstColumnIndexOfRow:row];
    [firstColumnsNumbers removeObjectAtIndex:row];
    [firstColumnsNumbers insertObject:[NSString stringWithFormat:@"%d",colunm+1] atIndex:row];
}


-(void)removeWordFromMatrix:(int)row length:(int)length{
    int colunm = [self getFirstColumnIndexOfRow:row];
    [firstColumnsNumbers removeObjectAtIndex:row];
    [firstColumnsNumbers insertObject:[NSString stringWithFormat:@"%d",colunm-length] atIndex:row];
}
-(int)getFirstBonusIndex {
    for (int i=0; i<5; i++) {
        if (![[bonusColumnsNumbers objectAtIndex:i] intValue]) {
            return i;
        }
    }
    return 0;
}
-(void)addCurrentLetterToBonus:(int)colunm {
    [bonusColumnsNumbers removeObjectAtIndex:colunm];
    [bonusColumnsNumbers insertObject:@"1" atIndex:colunm];
    bonus++;
}

-(void)removeLetterFromBonus:(int)colunm {
    [bonusColumnsNumbers removeObjectAtIndex:colunm];
    [bonusColumnsNumbers insertObject:@"0" atIndex:colunm];
    bonus--;
}
- (BOOL)canAddBonusLetter
{
    return bonus < 5;
}
- (BOOL)isCorrectWord:(NSString*)word {
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSLocale *currentLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    NSString *currentLanguage = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSRange searchRange = NSMakeRange(0, [word length]);
    
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:word range: searchRange startingAt:0 wrap:NO language: currentLanguage ];
    return misspelledRange.location == NSNotFound;
}

#pragma mark GameCenter Methods
-(void)authenticateLocalPlayer{
    if ([GKLocalPlayer localPlayer].authenticated==NO) {
        [gkHelper authenticateLocalPlayer];
    }
    
}
-(void)showLeaderBoardWithCategory:(NSString*)category{
    
    [gkHelper showLeaderboardWithCategory:category];
}

-(void) submitScore:(int64_t)score category:(NSString*)category{
    
    [gkHelper submitScore:score category:category];
}
#pragma mark GameKitHelper delegate methods
-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
        //	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
        //	[gkHelper getLocalPlayerFriends];
		//[gkHelper resetAchievements];
	}	
}

-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
}

-(void) onMatchFound:(GKMatch*)match{
    
    //    CCLOG(@"%d",[match.playerIDs count]);
    
}

-(void) onMatchmakingViewDismissed{
    //    
    //    //allow the device to sleep
    //    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void) onMatchmakingViewError{
    
    //    //allow the device to sleep
    //    //    [gkHelper dismissModalViewController];
    //    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void) onPlayersAddedToMatch:(bool)success{
}

-(void) onReceivedMatchmakingActivity:(NSInteger)activity{
}

-(void) onPlayerConnected:(NSString*)playerID{
    
}

-(void) onPlayerDisconnected:(NSString*)playerID{
    
}

-(void) onStartMatch{
    
}

-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID{
    
    
    CCLOG (@"[RECIVED DATA] player: %@", playerID);
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", [friends description]);
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
    CCLOG(@"onPlayerInfoReceived: %@", [players description]);
}

#pragma mark internet connection 
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

@end
