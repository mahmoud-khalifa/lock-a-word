//
//  PlasticLockScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "GameScene.h"
#import "LevelSelectionScene.h"
#import "GameModesScene.h"
#import "Controller.h"
#import "GameConfig.h"
#import "SimpleAudioEngine.h"
#import "EZToastView.h"

#import "InstructionsScene.h"

#define KStartingLetterCountedDown 50

@interface GameScene() {
    BOOL isGameCompleted;
    int score;
    NSString *currentLetter;
    BOOL bonusLetterSelected;
    BOOL selectingWord;
    BOOL correctWordFound;
    ccColor3B boardLettersColor;
    int wordsCollected;
    CCLabelBMFont *wordsCollectedLabel;
    int lettersCountedDown;
    CCLabelBMFont *lettersCountedDownLabel;
    int countTimerSeconds;
    int countTimerMinutes;
    CCLabelBMFont *countTimerLabel;
    TapForTapAdView *adView;
    CCSprite *boardTrophy;
    NSString *boardTrophyName;
    
    NSMutableArray *lockedLettersInBoard;
    CCSprite *starsImage;
    NSMutableArray *lockedWords;
    int numOfStars;
    
    UIButton *infoButton;
    
    BOOL canUseSpareBox;
    CCLabelTTF *bonusLabel1;
    CCLabelTTF *bonusLabel2;
    
    int numOfSwaps;
}

@property (nonatomic, retain) NSMutableArray *newLetters;
@property (nonatomic, retain) NSMutableArray *bonusLetters;
@property (nonatomic, retain) NSMutableArray *boardLetters;
@property (nonatomic, retain) NSMutableArray *collectedWord;

- (void)newGame;
- (void)drawBoard;

- (void)insertNewLetter;
- (void)useBonusLetter:(int)row;
- (void)addCurentLetterToExtraColumnWithBonus:(BOOL)bonus;

- (void)addCurrentLetterToMatrix:(int)row;
- (void)addBonusLetter:(int)row;
- (void)checkLockedRow:(int)row;

- (void)removeCorrectWord; 
- (void)cancelRemoveCorrectWord;

- (NSString*)getBonusString;

- (void)gameCompleted;
- (void)showShareAlert;

- (void)disableTouches;
- (void)enableTouches;

- (void)countUp:(ccTime)delta; 

- (void)removeSpritesInArray:(NSMutableArray*)spritesArray;

- (BOOL)isRowLocked:(int)row;
- (BOOL)isVowel:(NSString*)letter;

@end


@implementation GameScene {
    CCSprite *backButton;
    Controller *gameController;
}

@synthesize newLetters;
@synthesize bonusLetters;
@synthesize boardLetters;
@synthesize collectedWord;


+ (id)scene {
    CCScene *scene = [CCScene node];
    
    GameScene *layer = [GameScene node];
    
    [scene addChild:layer];
    
    return scene;
}

- (id)init {    
	if(self=[super init]) {
        // get shared controller
        gameController = [Controller sharedController];
        
        //Enable Touches
        [self enableTouches];
        
        CCSpriteFrameCache*frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache  addSpriteFramesWithFile:@"menu_buttons.plist"];
        [frameCache  addSpriteFramesWithFile:@"tiles.plist"];
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:backgroundImage];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
         
        boardLettersColor = ccYELLOW;
        
        lockedWords = [[NSMutableArray alloc]init];
        
        // Here the code for the timer
        // schedule timer
        [self schedule:@selector(countUp:) interval:1.0f]; 
       
        // Check if it isn't an Ipad and it is in PlasticLock mode
        if (!IS_IPAD() && gameController.currentGameMode == PlasticLock ) {
            // This is for TapforTap
            adView = [[TapForTapAdView alloc] initWithFrame: CGRectMake(0,60, 320, 50) delegate:self];
            [[[CCDirector sharedDirector] view] addSubview:adView];
            [adView loadAds];
            //Full screen ads
//            [TapForTapInterstitial prepare];
//            [self showInterstitial:self];
        }
        
        infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        if (IS_IPAD()) {
            infoButton.frame = CGRectMake(670, 130, 55, 55);
        }else {
            infoButton.frame = CGRectMake(273, -7, 55, 55);
        }
        [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchDown];
        [[[CCDirector sharedDirector] view] addSubview:infoButton];
        
        numOfSwaps = 0;
	}
	return self;
}

- (IBAction)showInterstitial:(id)sender{
    [TapForTapInterstitial showWithRootViewController: (CCDirectorIOS*) [CCDirector sharedDirector]];
}

- (void)infoButtonAction{
    infoButton.hidden = YES;
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    [[CCDirector sharedDirector] pushScene:[InstructionsScene scene]];
    CCLOG(@"Instruction button has been pressed!!");
}

#pragma mark - initialization
- (void)newGame {
    score=0;  
    isGameCompleted=NO;
    wordsCollected = 0;
//    lettersLoaded=0;
    lettersCountedDown=KStartingLetterCountedDown;
    countTimerSeconds=0;
    countTimerMinutes=0;
    canUseSpareBox = NO;
    
    self.newLetters = [[NSMutableArray alloc] init];
    self.bonusLetters = [[NSMutableArray alloc] init];
    self.boardLetters =  [[NSMutableArray alloc] init];
    self.collectedWord = [[NSMutableArray alloc] init];
    
    [self disableTouches];
    
    //LETTERS LABEL
    lettersCountedDownLabel=[CCLabelBMFont labelWithString:@"0" fntFile:@"score.fnt"];
    if(!IS_IPAD()){
        lettersCountedDownLabel.position = ADJUST_XY(142, 434);
    } else {
        lettersCountedDownLabel.position = ADJUST_XY(172, 439);
    }
    [self addChild:lettersCountedDownLabel];
    
    //BONUS LABEL
    int stars = [gameController getcurrentLevelStars];
    if (stars > 0) {
        NSString* let = stars > 1 ? @"letters" : @"letter";
        if (IS_IPAD()) {
            bonusLabel1=[CCLabelTTF labelWithString:@"To allow spare letters," fontName:@"Marker Felt" fontSize:30];
            bonusLabel1.position = ADJUST_XY(160, 45);
            
            bonusLabel2=[CCLabelTTF labelWithString:[NSString stringWithFormat: @"put at least %d %@ in each row", stars, let] fontName:@"Marker Felt" fontSize:30];
            bonusLabel2.position = ADJUST_XY(165, 25);
        }else{
            bonusLabel1=[CCLabelTTF labelWithString:@"To allow spare letters," fontName:@"Marker Felt" fontSize:15];
            bonusLabel1.position = ADJUST_XY(130, 55);
            
            bonusLabel2=[CCLabelTTF labelWithString:[NSString stringWithFormat: @"put at least %d %@ in each row", stars, let] fontName:@"Marker Felt" fontSize:15];
            bonusLabel2.position = ADJUST_XY(135, 35);
        }
        [self addChild:bonusLabel1 z:200];
        [self addChild:bonusLabel2 z:200];
    }else{
        canUseSpareBox = YES;
    }
    
    //STARS IMAGE
    stars = [gameController calculateLevelStars:lettersCountedDown];
    numOfStars = stars;
    switch (stars) {
        case 1:
            starsImage =[[CCSprite alloc] initWithSpriteFrameName:@"star1.png"]; 
            break;
        case 2:
            starsImage =[[CCSprite alloc] initWithSpriteFrameName:@"star2.png"]; 
            break;
        case 3:
            starsImage =[[CCSprite alloc] initWithSpriteFrameName:@"star3.png"];
            break;
            
        default:
            break;
    }
    starsImage.tag = 500;
    starsImage.anchorPoint = ccp(1,.5);
    if(!IS_IPAD()){
        starsImage.position = ADJUST_XY(200, 440);
    } else {
        starsImage.position = ADJUST_XY(235, 445);
    }
    [self addChild:starsImage];
    //END OF STARS IMAGE
    
    EZToastView *toastView = [[EZToastView alloc] init];
    toastView.message = @"Playing for 3 stars";
    toastView.showDuration = 2;
    toastView.toastAlignment = EZToastViewAlignmentCenter;
    [toastView show];

    // This is for the Trophy image
    boardTrophyName = [NSString stringWithFormat:@"board_trophy_%d.png",gameController.currentGameMode];
    boardTrophy=[CCSprite spriteWithSpriteFrameName:boardTrophyName];
    // This is for positioning the trophy in Ipad version and in Iphone  
    if (!IS_IPAD()) {
        boardTrophy.position = ADJUST_XY(250, 436);
    } else {
        boardTrophy.position = ccp(.78*screenSize.width, .898*screenSize.height);
    }
    [self addChild:boardTrophy];
    [self drawBoard];
    
//    lettersLoaded++;
    if (lettersCountedDown > 0) {
        lettersCountedDown--;
    }
    [gameController logGameStart];
    [gameController prepareCurrentLetterWithRestrictions:[self getBonusString]];
    
    [self insertNewLetter];
}

-(void)countUp:(ccTime)delta {
    countTimerSeconds++;
    [countTimerLabel setString:[NSString stringWithFormat:@"%02d:%02d", countTimerMinutes, countTimerSeconds]];
    
    if (countTimerSeconds >= 59) {
        countTimerMinutes++;
        countTimerSeconds=0;
    }
}

- (void)drawBoard {
    lockedLettersInBoard = [[NSMutableArray alloc] init];
    NSArray *lockedLetters = [gameController getLockedLetters];
    if (lockedLetters == nil) { //Plastic mode
        [self enableTouches];
        return;
    }
    for (NSDictionary *dic in lockedLetters) {
        NSString *letter = [dic objectForKey:@"letter"];
        int index = [[dic objectForKey:@"index"] intValue];
        int row = index/5;
        int column = index%5;
        
        CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",letter]];
        letterSprite.userData = letter;
        
        float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*column)+(kLETTERS_SPACING*column);
        float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
        
//        letterSprite.color=ccRED;
        letterSprite.color=ccYELLOW;
        letterSprite.position=ccp(xPos,yPos);
        
        [self addChild:letterSprite z:100 tag:(row*5+column)];
        [boardLetters addObject:letterSprite];
        
        [self spinLetter:letterSprite];
        [self performSelector:@selector(changeLockedLetterColor:) withObject:letterSprite afterDelay:1];
        
        [lockedLettersInBoard addObject:letterSprite];
    }
}

- (void)spinLetter:(CCSprite*)letterSprite{
//    CCSprite* tempSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",@"a"]];
//    float xPos = letterSprite.position.x - (letterSprite.position.x / 10);
//    float yPos = letterSprite.position.y - (letterSprite.position.y / 10);
//    tempSprite.position = ccp(xPos, yPos);

    [[SimpleAudioEngine sharedEngine]playEffect:@"LetterSpin.aiff"];
    
    id oneSpin = [CCRotateBy actionWithDuration:1 angle: 360];
    id severalSpins = [CCRepeat actionWithAction:oneSpin times:1];
    [letterSprite runAction:severalSpins];
}

- (void)changeLockedLetterColor:(CCSprite*)letterSprite{
    letterSprite.color=ccRED;
    [self enableTouches];
}


#pragma mark - logic
- (void)insertNewLetter{
    if (lettersCountedDown < 0) {
        return;
    }
    
    if (lettersCountedDown < (KStartingLetterCountedDown - 18) && [gameController isGameCompleted]) {
        [self gameCompleted];
        return;
    }
    
    currentLetter = [gameController getCurrentLetter];
    [lettersCountedDownLabel setString:[NSString stringWithFormat:@"%d",lettersCountedDown]];
    
    int stars = [gameController calculateLevelStars:lettersCountedDown];
    if (stars != numOfStars) {
        [[SimpleAudioEngine sharedEngine]playEffect:@"Mhmm.mp3"];
        numOfStars = stars;
        
        EZToastView *toastView = [[EZToastView alloc] init];
        if (stars == 2) {
            toastView.message = @"Playing for 2 stars";
        }else if(stars == 1){
            toastView.message = @"Playing for 1 star";
        }
        toastView.showDuration = 2;
        toastView.toastAlignment = EZToastViewAlignmentCenter;
        [toastView show];
    }
    
    switch (stars) {
        case 1:
            starsImage =[[CCSprite alloc] initWithSpriteFrameName:@"star1.png"]; 
            break;
        case 2:
            starsImage =[[CCSprite alloc] initWithSpriteFrameName:@"star2.png"]; 
            break;
        case 3:
            starsImage =[[CCSprite alloc] initWithSpriteFrameName:@"star3.png"];
            break;
            
        default:
            break;
    }
    [self removeChildByTag:500 cleanup:YES];
    starsImage.tag = 500;
    starsImage.anchorPoint = ccp(1, 0.5);
    if(!IS_IPAD()){
        starsImage.position = ADJUST_XY(200, 440);
    } else {
        starsImage.position = ADJUST_XY(235, 445);
    }
    [self addChild:starsImage]; 
    
    if (lettersCountedDown == 10) {
        EZToastView *toastView = [[EZToastView alloc] init];
        toastView.message = @"WARNING!! \n 10 Letters to Go";
        toastView.showDuration = 2;
        toastView.toastAlignment = EZToastViewAlignmentCenter;
        [toastView show];
    }
    else if(lettersCountedDown == 5){
        EZToastView *toastView = [[EZToastView alloc] init];
        toastView.message = @"WARNING!! \n 5 Letters to Go";
        toastView.showDuration = 2;
        toastView.toastAlignment = EZToastViewAlignmentCenter;
        [toastView show];
    }
    // add the extra column letter
    [self addCurentLetterToExtraColumnWithBonus:NO];
}

- (void)useBonusLetter:(int)row{
    if (bonusLetterSelected) {
        //restore the old one to first free space
        int i = [gameController getFirstBonusIndex];
        
        CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
        letterSprite.userData = currentLetter;
//        letterSprite.color=ccRED;
        letterSprite.color=ccGREEN;
        float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
        float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
        letterSprite.position=ccp(xPos,yPos);
        
        [self addChild:letterSprite z:100 tag:i+200];
        [bonusLetters addObject:letterSprite];
        [gameController addBonusLetterAtIndex:i];
    }
    // ge the new selected one
    bonusLetterSelected = YES;
    
    CCSprite* letterSprite;
    for (int i=0; i<[bonusLetters count]; i++) {
        letterSprite = [bonusLetters objectAtIndex:i];
        if (letterSprite.tag-200 ==row) {
            currentLetter = [[bonusLetters objectAtIndex:i] userData];
            [letterSprite removeFromParentAndCleanup:YES];
            [bonusLetters removeObjectAtIndex:i];
            [gameController removeBonusLetterAtIndex:row];
            break;
        }
    }
    // add the grid extra column
    [self addCurentLetterToExtraColumnWithBonus:YES];
}

- (void)addCurentLetterToExtraColumnWithBonus:(BOOL)bonus{
    [self removeSpritesInArray:newLetters];
    
    if (!bonus) {
        if (![currentLetter isEqualToString:@"lock"]) {
            CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
            float xPos=ADJUST_X(kBOARD_LETTERS_X_OFFSET+8)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*kEXTRA_COLUMN_SPACING);
            float yPos;
            
            for (int j=0; j<5; j++) {
                yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
                letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
                letterSprite.userData = currentLetter;
                letterSprite.position=ccp(xPos,yPos);
                letterSprite.color=ccGREEN;
//                if (!canUseSpareBox) {
//                    letterSprite.color=ccRED;
//                }else{
//                    letterSprite.color=ccGREEN;
//                }
                
                if ([self canSwapLetterAtRow:j]){
                    id blink = [CCBlink actionWithDuration:1 blinks:3];
                    [letterSprite runAction:blink];
                }
                  
                [newLetters addObject:letterSprite];
                [self addChild:letterSprite z:100 tag:j+105];
                letterSprite.scale = .75;
                [letterSprite runAction:[CCScaleTo actionWithDuration:0.3 scale:1]];
            }
            //Bonus letter
            xPos=ADJUST_X(kBOARD_LETTERS_X_OFFSET+8)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*kEXTRA_COLUMN_SPACING);
            yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
            letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
            letterSprite.userData = currentLetter;
            letterSprite.position=ccp(xPos,yPos);
            
            if (!canUseSpareBox) {
                letterSprite.color=ccRED;
            }else{
                letterSprite.color=ccGREEN;
            }
            
            letterSprite.scale = .75;
            [newLetters addObject:letterSprite];
            [self addChild:letterSprite z:100 tag:5+105];
            [letterSprite runAction:[CCScaleTo actionWithDuration:0.3 scale:1]];
        }else{  //lock letter
            NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:6];
            [actions addObject:@""];
            
            CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
            
            float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+8)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*kEXTRA_COLUMN_SPACING);
            float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*0)+(letterSprite.contentSize.height*0));
            
            for (int j=0; j<5; j++) {
                yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*0)+(letterSprite.contentSize.height*0));
                letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
                letterSprite.userData = currentLetter;
                letterSprite.position=ccp(xPos,yPos);
                [newLetters addObject:letterSprite];
                [self addChild:letterSprite z:100 tag:j+105];
                
                if (j>0) {
                    yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
                    CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION/2 position:ccp(xPos, yPos)];
                    [actions addObject:move];
                }
            }
            //Sound of lock graphics
            if ([currentLetter isEqualToString:@"lock"]) {
                for (int i = 0; i < 5; i ++) {
                    [self performSelector:@selector(playKeydoor3) withObject:nil afterDelay:2.5*i*kANIMATION_DURATION];
                }
                [self performSelector:@selector(playKeydoor3) withObject:nil afterDelay:2.5*kANIMATION_DURATION];
                
                for (int i = 1; i< [actions count]; i++) {
                    for (int j=i; j<[newLetters count]; j++)  {
                        letterSprite = [newLetters objectAtIndex:j];
                        CCMoveTo* move = [[actions objectAtIndex:i] copy];
                        [letterSprite performSelector:@selector(runAction:) withObject:move afterDelay:2.5*i*kANIMATION_DURATION];
                    }
                }
            }
        }
        
    }//END IF BONUS
    else { //Bonus letter selected, so appear without falling action
        CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
        
        float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+8)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*kEXTRA_COLUMN_SPACING);
        float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*0)+(letterSprite.contentSize.height*0));
        
        for (int j=0; j<5; j++) {
            yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
            
            letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
            letterSprite.userData = currentLetter;
            letterSprite.position=ccp(xPos,yPos);
            if (!isGameCompleted) {
                letterSprite.color=ccGREEN;
            }
            
            if ([self canSwapLetterAtRow:j]){
                id blink = [CCBlink actionWithDuration:1 blinks:3];
                [letterSprite runAction:blink];
            }
            
            [newLetters addObject:letterSprite];
            [self addChild:letterSprite z:100 tag:j+105];
        }
    }
    //    [self performSelector:@selector(enableTouches) withObject:nil afterDelay:5*[actions count]*kANIMATION_DURATION ];
}

- (BOOL)canSwapLetterAtRow:(int)row{
    int column = [gameController getFirstColumnIndexOfRow:row];
//    if ( (column > 4) && (([self isVowel:currentLetter])||(numOfSwaps < 3)) && (![self isRowLocked:column]) ) {
//        return YES;
//    }
    if ( (column > 4) && (([self isVowel:currentLetter])||(numOfSwaps < 3)) ) {
        return YES;
    }
    return NO;
}

- (void)addCurrentLetterToMatrix:(int)row {
    int column = [gameController getFirstColumnIndexOfRow:row];
    
    if ( (column <= 4) || ([self canSwapLetterAtRow:row]) ) {
        if (column > 4) {
            if ([self isRowLocked:row]) {
                [self unlockRow:row];
            }
            if ( ([gameController currentGameMode] == GoldLock) && (row < 3) ) {
                column = 3;
                CCSprite* oldSprite = (CCSprite*)[self getChildByTag:(row*5+3)];
                [boardLetters removeObject:oldSprite];
                [self removeChildByTag:(row*5+3) cleanup:YES];
            }else{
                column = 4;
                CCSprite* oldSprite = (CCSprite*)[self getChildByTag:(row*5+4)];
                [boardLetters removeObject:oldSprite];
                [self removeChildByTag:(row*5+4) cleanup:YES];
            }
            if (![self isVowel:currentLetter]) {
                numOfSwaps ++;
            }
        }
        
        [self removeSpritesInArray:newLetters];
        [gameController addLetterAtIndex:row*5+column];
        
        CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
        letterSprite.userData = currentLetter;
        float xPos=ADJUST_X(kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*column);
        float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
        letterSprite.color=ccYELLOW;
        letterSprite.position=ccp(xPos,yPos);
        [self addChild:letterSprite z:100 tag:(row*5+column)];
        [boardLetters addObject:letterSprite];
        
        xPos=ADJUST_X(kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*column)+(kLETTERS_SPACING*column);
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
        float duration = kANIMATION_DURATION*(5-column);
        CCMoveTo* move=[CCMoveTo actionWithDuration:duration position:ccp(xPos, yPos)];
        [letterSprite runAction:move];
        
        if (bonusLetterSelected) {
            bonusLetterSelected = NO;
        }else {
            lettersCountedDown--;
            [gameController prepareCurrentLetterWithRestrictions:[self getBonusString]];
        }
        
        if ( ([gameController currentGameMode] != PlasticLock) && ([gameController getcurrentLevelStars] == 1) && (row == 3) && (column == 0) ) {
            [self spinLetter:letterSprite];
            [self performSelector:@selector(changeLockedLetterColor:) withObject:letterSprite afterDelay:1];
            [gameController lockLetter:3 andColumn:0];
        }else if (([gameController currentGameMode] != PlasticLock) && ([gameController getcurrentLevelStars] > 1) && (row >= 3) && (column == 0)){
            [self spinLetter:letterSprite];
            [self performSelector:@selector(changeLockedLetterColor:) withObject:letterSprite afterDelay:1];
            [gameController lockLetter:row andColumn:0];
        }
        [self checkLockedRow:row];
        if (!canUseSpareBox) {
            [self checkBonusRest];
        }
        [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:.5];
    }else{
        return;
    }
}

- (void)checkBonusRest{
    int stars = [gameController getcurrentLevelStars];
    int maxToBe = stars;
    for (int i = 0; i < 5; i ++) {
        int column = [gameController getFirstColumnIndexOfRow:i];
        if (column < maxToBe) {
            canUseSpareBox = NO;
            bonusLabel1.visible = YES;
            bonusLabel2.visible = YES;
            return;
        }
    }
    canUseSpareBox = YES;
    bonusLabel1.visible = NO;
    bonusLabel2.visible = NO;
}

- (void)addBonusLetter:(int)row {
    if (![gameController canAddBonusLetter]) {
        return;
    }
    [self removeSpritesInArray:newLetters];
    int i = 5;
    
    CCSprite* letterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png",currentLetter]];
    letterSprite.userData = currentLetter;
    float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
    float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5)); 
    letterSprite.color = ccGREEN; 
    letterSprite.position = ccp(xPos,yPos);
    
    i = [gameController getFirstBonusIndex];
    
    [self addChild:letterSprite z:100 tag:i+200];
    [bonusLetters addObject:letterSprite];
    [gameController addBonusLetterAtIndex:i];
    
    xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
    yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
    float duration = kANIMATION_DURATION*(5-i);
    CCMoveTo* move=[CCMoveTo actionWithDuration:duration position:ccp(xPos, yPos)];
    [letterSprite runAction:move];
    
//    lettersLoaded++;
    lettersCountedDown--;
    [gameController prepareCurrentLetterWithRestrictions:[self getBonusString]];
    [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:.5];
}

-(void)shiftSprite:(CCSprite*)sprite{
    [self disableTouches];
    CCSprite* sprite2 = (CCSprite*)[self getChildByTag:sprite.tag-1];
    
    int tag = sprite.tag;
    sprite.tag = sprite2.tag;
    sprite2.tag = tag; 
    
    CGPoint pos = sprite.position;
    CGPoint pos2 = sprite2.position;
    
    CCMoveTo* move=[CCMoveTo actionWithDuration:2*kANIMATION_DURATION position:pos2];
    [sprite runAction:move];
    
    CCMoveTo* move2=[CCMoveTo actionWithDuration:2*kANIMATION_DURATION position:pos];
    [sprite2 runAction:move2];
    
    int row = sprite.tag/5;
    [self checkLockedRow:row];
    [self performSelector:@selector(enableTouches) withObject:nil afterDelay:2*kANIMATION_DURATION ];
    //    [self enableTouches];
}

- (void)checkLockedRow:(int)row{
    NSString *word = @"";
    NSMutableArray *collWord = [[NSMutableArray alloc]init];
    for (int i=row*5; i < (row+1)*5; i++) {
        CCSprite* sprite = (CCSprite*)[self getChildByTag:i];
        if (sprite != nil) {
            word = [word stringByAppendingString:sprite.userData];
            [collWord addObject:sprite];
        }
    }
    
    if ([word length] == 5 && [gameController isCorrectWord:word]) {
        //check if repeated in the scene
        if (![lockedWords containsObject:word]) {
            [lockedWords addObject:word];
            [gameController lockRow:row];
            [self performSelector:@selector(lockRow:) withObject:collWord afterDelay:2*kANIMATION_DURATION];
        }else {
            BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Locking prohibited" message:@"Duplicate words not allowed" andLoadingviewEnabled:NO];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
        }
    } 
}

- (BOOL)isRowLocked:(int)row{
    NSString *word = @"";
    for (int i=row*5; i < (row+1)*5; i++) {
        CCSprite* sprite = (CCSprite*)[self getChildByTag:i];
        if (sprite != nil) {
            word = [word stringByAppendingString:sprite.userData];
        }
    }
    if ([lockedWords containsObject:word]) {
        return YES;
    }
    return NO;
}

- (void)lockRow:(NSArray*)word {
    if([gameController isGameCompleted]){
        [self gameCompleted];
    } else {
        for (CCSprite* collectedLetter in word) {
            [collectedLetter runAction:[CCScaleTo actionWithDuration:1 scale:0.75]];
            [self spinLetter:collectedLetter];
        }
        [self performSelector:@selector(reScale:) withObject:word afterDelay:1];
        [self performSelector:@selector(changeColor:) withObject:word afterDelay:2];
        [[SimpleAudioEngine sharedEngine]playEffect:@"keydoor2.mp3"];
        [self performSelector:@selector(playApplause) withObject:nil afterDelay:0.4];
    }
}

- (void)unlockRow:(int)row {
    NSString *word = @"";
    NSMutableArray *collWord = [[NSMutableArray alloc]init];
    for (int i=row*5; i < (row+1)*5; i++) {
        CCSprite* sprite = (CCSprite*)[self getChildByTag:i];
        if (sprite != nil) {
            word = [word stringByAppendingString:sprite.userData];
            [collWord addObject:sprite];
        }
    }
    
    if([gameController isGameCompleted]){
        [self gameCompleted];
    } else {
        for (CCSprite* collectedLetter in collWord) {
            if (![lockedLettersInBoard containsObject:collectedLetter]) {
                collectedLetter.color = ccYELLOW;
            }
        }
        [lockedWords removeObject:word];
        [gameController unLockRow:row];
    }
}

- (void)playApplause{
    [[SimpleAudioEngine sharedEngine]playEffect:@"Applause.mp3"];
}

- (void)playKeydoor3{
    [[SimpleAudioEngine sharedEngine]playEffect:@"keydoor3.mp3"];
}

- (void)reScale:(NSArray*)word {
    for (CCSprite* collectedLetter in word) {
        [collectedLetter runAction:[CCScaleTo actionWithDuration:1 scale:1.0]];
    }
}

- (void)changeColor:(NSArray*)word {
    if(isGameCompleted)
        return;
    for (CCSprite* collectedLetter in word) {
        collectedLetter.color=ccRED;
    }
}

- (void)checkIsWordCorrect {
    if ([collectedWord count]>2) {
        NSString *word = @"";
        for (CCSprite* letterSprite in collectedWord) {
            word = [word stringByAppendingString:[letterSprite userData]];
        }
        NSLog(@"word:%@",word);
        
        if ([gameController isCorrectWord:word]) {
            if (![lockedWords containsObject:word]) {
                NSLog(@"correct word");
                correctWordFound = YES;
                for (CCSprite* collectedLetter in collectedWord) {
                    collectedLetter.color=ccGREEN;
//                 collectedLetter.color=ccRED;
                }
                [self performSelector:@selector(removeCorrectWord) withObject:nil afterDelay:2];
                return;
            }else {
                BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Locking prohibited" message:@"Duplicate words not allowed" andLoadingviewEnabled:NO];
                [alert setCancelButtonWithTitle:@"OK" block:nil];
                [alert show];
            }
        }
    }
    for (CCSprite* collectedLetter in collectedWord) {
        collectedLetter.color = boardLettersColor; //yellow
    }
    [collectedWord removeAllObjects];
}

- (void)removeCorrectWord {
    CCLOG(@"removeCorrectWord");
    @synchronized (collectedWord) {
        CCLOG(@"removeCorrectWord->synchronized");
        if (correctWordFound && [collectedWord count] >0) {
            [[SimpleAudioEngine sharedEngine]playEffect:@"WordDeleted.mp3"];
            correctWordFound = NO;
            int wordLength = [collectedWord count];
            int firstIndex = [[collectedWord objectAtIndex:0] tag];
            int lastIndex = [[collectedWord objectAtIndex:wordLength-1] tag];
            int row = lastIndex/5;
            for (CCSprite* letter in collectedWord) {
                [boardLetters removeObject:letter];
                [letter removeFromParentAndCleanup:YES];
            }
            [collectedWord removeAllObjects];
            
            float xPos,yPos;
            CCSprite* letterSprite;
            int newIndex;
            int newColumn;
            for (int i=lastIndex+1; i/5 == row; i++) {
                if ([gameController isLockedPosition:i]) {
                    break;
                }
                letterSprite = (CCSprite*)[self getChildByTag:i];
                newIndex = i-wordLength;
                newColumn = newIndex%5;
                if (letterSprite != nil) {
                    xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*newColumn)+(kLETTERS_SPACING*newColumn);
                    yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
                    
                    letterSprite.tag = newIndex;
                    float duration = kANIMATION_DURATION*wordLength;
                    CCMoveTo* move=[CCMoveTo actionWithDuration:duration position:ccp(xPos, yPos)];
                    [letterSprite runAction:move];
                }
            }
            [gameController removeWordAtIndex:firstIndex lenght:wordLength];
            wordsCollected++;
            [wordsCollectedLabel setString:[NSString stringWithFormat:@"%d",wordsCollected]];
        }
    }
}

- (void)cancelRemoveCorrectWord {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeCorrectWord) object:nil];
    CCLOG(@"cancelRemoveCorrectWord");
//    @synchronized (collectedWord) {
        CCLOG(@"cancelRemoveCorrectWord->synchronized");
        correctWordFound = NO;
        for (CCSprite* collectedLetter in collectedWord) {
            collectedLetter.color=boardLettersColor; //yellow
        }
        [collectedWord removeAllObjects];
//    }
}

- (NSString*)getBonusString {
    NSString *bonusString = @"";
    for (CCSprite* letterSprite in bonusLetters) {
        bonusString = [bonusString stringByAppendingString:[letterSprite userData]];
    }
    return bonusString;
}


#pragma mark - Scoring

- (void)updateScoreWithWordLength:(int)wordLength {
    if (wordLength==4) {
        score+=40;
    }else if(wordLength==5){
        score+=50;
    }
}


#pragma mark - Game Completed

- (void)gameCompleted {
    if (isGameCompleted) {
        return;
    }
    
    @synchronized(boardLetters){
        isGameCompleted=YES;
        for (CCSprite* letterSprite in boardLetters) {
            letterSprite.color = ccc3(255, 255, 255); //return to original color
        }
//        [newLetters removeAllObjects];
        currentLetter = @"lock";
        [self addCurentLetterToExtraColumnWithBonus:NO];
        [self performSelector:@selector(showShareAlert) withObject:nil afterDelay:12*kANIMATION_DURATION];
//    [self performSelector:@selector(disableTouches) withObject:nil afterDelay:0.05 ];
        [self unscheduleAllSelectors];
        [gameController logGameCompleted];
    }
}


#pragma mark - ShareAlert

- (void)showShareAlert {
    //find old stars and show alert only if new stars more than old
    int currentLevelStars = [gameController getcurrentLevelStars];
    int newStars = [gameController calculateLevelStars:lettersCountedDown];
    
    if(currentLevelStars < newStars){
        [gameController updateLevelStars:newStars];
        
//        if (newStars < 3) {
//            [[SimpleAudioEngine sharedEngine]playEffect:@"Whoa_2.mp3"];
//            [[SimpleAudioEngine sharedEngine]playEffect:@"Applause.mp3"];
//        }
//        else {
            [[SimpleAudioEngine sharedEngine]playEffect:@"Fanfare.mp3"];
            [[SimpleAudioEngine sharedEngine]playEffect:@"Applause.mp3"];
//        }
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Star Ranking" message:[NSString stringWithFormat:@"Congratulations, you have gained a %d Star achievement",newStars] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        
        //Achievements
        int achievStars = [gameController getAchievementStars];
        if (achievStars > 0){
            NSString* achiev = @"";
            switch (gameController.currentGameMode) {
                case PlasticLock:
                    achiev = @"Plastic Lock Trophy";
                    break;
                case BronzeLock:
                    achiev = @"Bronze Lock Trophy";
                    break;
                case SilverLock:
                    achiev = @"Silver Lock Trophy";
                    break;
                case GoldLock:
                    achiev = @"Gold Lock Trophy";
                    break;
                default:
                    break;
            }
            
            BlockAlertView* alert=[BlockAlertView alertWithTitle:achiev message:[NSString stringWithFormat:@"Congratulations, you have rewarded %d star Trophy.", achievStars] andLoadingviewEnabled:NO];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
        }
        else{
            BlockAlertView* alert=[BlockAlertView alertWithTitle:@"New Star Ranking" message:[NSString stringWithFormat:@"Congratulations, you have gained %d stars",newStars] andLoadingviewEnabled:NO];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
        }
    }
    else {
        [[SimpleAudioEngine sharedEngine]playEffect:@"Applause.mp3"];
    }
}


#pragma mark - Touches
- (void)registerWithTouchDispatcher{ 
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch  withEvent:(UIEvent *)event {
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]]; 
    location = [[CCDirector sharedDirector] convertToGL:location];         
    
    selectingWord = YES;
    
    CGRect letterArea;
    for (CCSprite* letterSprite in boardLetters) {
        letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
        //locked row
        if ([gameController isLockedPosition:letterSprite.tag]) {
            continue;
        }
        if (CGRectContainsPoint(letterArea, location)) {
            int count = [collectedWord count];
            if (count<1) { //select letter
                letterSprite.color=ccRED;
                [collectedWord addObject:letterSprite];
            } else {
                if ([collectedWord containsObject:letterSprite]) {
                    if (count>1 && [collectedWord objectAtIndex:[collectedWord count]-2]==letterSprite) {
                        ((CCSprite*)[collectedWord lastObject]).color=boardLettersColor; //yellow
                        [collectedWord removeLastObject];
                    }
                }else {
                    int index1 = [[collectedWord objectAtIndex:count-1] tag];
                    int index2 = [letterSprite tag];
                    int row1 = index1/5;
                    int row2 = index2/5;
                    if (index2-index1 == 1 && row1==row2) {
                        letterSprite.color=ccRED;
                        [collectedWord addObject:letterSprite];
                    }
                }
            }
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    // Back button tapped
    if (CGRectContainsPoint(backButtonRect, location)) {
        [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
        
        BlockAlertView *alertView=[BlockAlertView alertWithTitle:nil message:@"Quit game?" andLoadingviewEnabled:NO];
        [alertView addButtonWithTitle:@"Yes" block:^{
            if (gameController.currentGameMode == PlasticLock) {
                [[CCDirector sharedDirector] replaceScene:[GameModesScene scene]];
            } 
            else{
                [[CCDirector sharedDirector] replaceScene:[LevelSelectionScene scene]];
            }
            [gameController logGameEnd];
        }];
        [alertView addButtonWithTitle:@"No" block:nil];
        [alertView show];
    
        return;
    }
    
    if (isGameCompleted) {
        return;
    }
    
    if (correctWordFound) { //remove previous selected word
        @synchronized (collectedWord) {
            CCLOG(@"ccTouchEnded->synchronized");
            CGPoint location = [touch locationInView:[touch view]]; 
            location = [[CCDirector sharedDirector] convertToGL:location];    
            CGRect letterArea;
            for (CCSprite* letterSprite in collectedWord) {
                letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
                
                if (CGRectContainsPoint(letterArea, location)) {
                    [self cancelRemoveCorrectWord];
                    break;
                }
            }
        }
    } else if (selectingWord) { //word collected
        selectingWord = NO;
        [self checkIsWordCorrect];
    } else { //letter pressed
        CGRect letterArea;
        // select a tile at the extra column -> insert the letter at the selected row
        for (CCSprite* letterSprite in newLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                [[SimpleAudioEngine sharedEngine]playEffect:@"lettertap.mp3"];
                [self performSelector:@selector(extraColumnLetterTouchedAtRow:) withObject:[NSNumber numberWithInt:letterSprite.tag-105] afterDelay:.01 ];
                return;
            }
        }
        
        // select a tile at the bonus area -> use selected letter in the extra column
        for (CCSprite* letterSprite in bonusLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                [[SimpleAudioEngine sharedEngine]playEffect:@"lettertap.mp3"];
                [self performSelector:@selector(bounsLetterTouchedAtRow:) withObject:[NSNumber numberWithInt:letterSprite.tag-200] afterDelay:.01 ];
                return;
            }
        }
        
        // select a tile at board -> shift selected tile with the tile before it (if both are not locked) 
        for (CCSprite* letterSprite in boardLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                int colunm = letterSprite.tag%5;
                int row = letterSprite.tag/5;
                int index = 5*row + colunm;
                if (colunm != 0) {
                    if (!([gameController isLockedPosition:index] || [gameController isLockedPosition:index-1])) {
                        [[SimpleAudioEngine sharedEngine]playEffect:@"lettertap.mp3"];
                        [self shiftSprite:letterSprite];
                    } 
                }
                return;
            }
        }
    }
}

- (void)extraColumnLetterTouchedAtRow:(NSNumber*)row {
    int rowValue = [row intValue];
    if (rowValue < 5){
        [self addCurrentLetterToMatrix:[row intValue]];
    } else {
        if (canUseSpareBox) {
            [self addBonusLetter:[row intValue]];
        }
    }
}

- (void)bounsLetterTouchedAtRow:(NSNumber*)row {
    [self useBonusLetter:[row intValue]];
}


#pragma Enable/Disable Touches
- (void)disableTouches {
    self.isTouchEnabled=NO;
}

- (void)enableTouches {
    self.isTouchEnabled=YES;
}

#pragma mark Utils

- (void)removeSpritesInArray:(NSMutableArray*)spritesArray {
    for (CCSprite* letter in spritesArray) {
        [letter removeFromParentAndCleanup:YES];
    }
    [spritesArray removeAllObjects];
}


- (BOOL)isVowel:(NSString*)letter{
    if ( ([letter isEqualToString:@"a"]) || ([letter isEqualToString:@"e"]) || ([letter isEqualToString:@"i"]) || ([letter isEqualToString:@"o"]) || ([letter isEqualToString:@"u"]) ) {
        return YES;
    }
    return NO;
}

#pragma mark - UI Events

- (void)onEnterTransitionDidFinish {
    if (lettersCountedDown==0) {
        [self newGame];
    }
}

- (void)onEnter {
    [super onEnter];
    infoButton.hidden = NO;
}

- (void)onExit {
    infoButton.hidden = YES;
    if (adView != nil) {
        [adView removeFromSuperview];
    }
    
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    [super onExit];
}

// on "dealloc" you need to release all your retained objects
- (void)dealloc {
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
	// don't forget to call "super dealloc"
    [newLetters release];
    [bonusLetters release];
    [boardLetters release];
    [collectedWord release];
	[super dealloc];
}

#pragma mark - TapForTapAdViewDelegate methods

- (UIViewController *)rootViewController{
    return (UIViewController*) [UIApplication sharedApplication].keyWindow.rootViewController; // or possibly self.navigationController
}

- (void)tapForTapAdViewDidReceiveAd:(TapForTapAdView *)adView{
    NSLog(@"ad view did receive ad");
}

- (void)tapForTapAdView:(TapForTapAdView *)adView didFailToReceiveAd:(NSString *)reason{
    NSLog(@"ad view failed to load ads: %@", reason);
}

- (void)tapForTapAdViewWasTapped:(TapForTapAdView *)adView{
    NSLog(@"ad view tapped");
}


@end
