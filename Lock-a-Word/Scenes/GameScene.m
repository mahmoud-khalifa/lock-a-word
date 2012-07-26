//
//  PlasticLockScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "GameScene.h"
#import "LevelSelectionScene.h"
#import "Controller.h"
#import "GameConfig.h"
#import "SimpleAudioEngine.h"
#import "TapForTap.h"

@interface GameScene() {
    BOOL isGameOver;
    int score;
    NSString *currentLetter;
    BOOL bonusLetterSelected;
    BOOL selectingWord;
    BOOL correctWordFound;
    ccColor3B boardLettersColor;
    int wordsCollected;
    CCLabelBMFont *wordsCollectedLabel;
    int lettersLoaded;
    CCLabelBMFont *lettesLoadedLabel;
    int countTimerSeconds;
    int countTimerMinutes;
    CCLabelBMFont *countTimerLabel;
    TapForTapAdView *adView;
    
    
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

- (void)gameOver;
- (void)showShareAlert;

- (void)disableTouches;
- (void)enableTouches;

- (void)countUp:(ccTime)delta; 

- (void)removeSpritesInArray:(NSMutableArray*)spritesArray;

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
        self.isTouchEnabled=YES;
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:backgroundImage];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
         
        boardLettersColor = ccYELLOW;
        
        // Here the code for the timer
        // schedule timer
        [self schedule:@selector(countUp:) interval:1.0f]; 
       
        if (!IS_IPAD()) {
            // This is for TapforTap
            adView = [[TapForTapAdView alloc] initWithFrame: CGRectMake(0,60, 320, 50)];
            [[[CCDirector sharedDirector] view] addSubview:adView];       
            // You don't have to do this if you set the default app ID in your app delegate
            adView.appId = @"c91a3680-b956-012f-f6ff-4040d804a637";
            
            [adView loadAds];
        }
       
//        // trial ads
//        t = [[UITextView alloc] initWithFrame: CGRectMake(0,300, 320,50)];
//        t.backgroundColor = [UIColor blackColor];
//        t.textColor = [UIColor whiteColor];
//        t.text = @"Hello UIKit!";
//        t.editable = NO;
//        
//        [[[CCDirector sharedDirector] view] addSubview:t];
        
	}
	return self;
}





#pragma mark - initialization
- (void)newGame {
    score=0;  
    isGameOver=NO;
    wordsCollected = 0;
    lettersLoaded=0;
    countTimerSeconds=0;
    countTimerMinutes=0;
    
    
    self.newLetters = [[NSMutableArray alloc] init];
    self.bonusLetters = [[NSMutableArray alloc] init];
    self.boardLetters =  [[NSMutableArray alloc] init];
    self.collectedWord=[[NSMutableArray alloc]init];
    
    self.isTouchEnabled=YES;
    
    wordsCollectedLabel=[CCLabelBMFont labelWithString:@"0" fntFile:@"score_bitmapfont.fnt"];
    wordsCollectedLabel.position=ADJUST_XY(50, 410);
    [self addChild:wordsCollectedLabel];
    
    
    lettesLoadedLabel=[CCLabelBMFont labelWithString:@"0" fntFile:@"score_bitmapfont.fnt"];
    lettesLoadedLabel.position=ADJUST_XY(250, 410);
    [self addChild:lettesLoadedLabel];
    
    countTimerLabel=[CCLabelBMFont labelWithString:@"00:00" fntFile:@"score_bitmapfont.fnt"];
    countTimerLabel.position=ADJUST_XY(150, 410);
    [self addChild:countTimerLabel];
    
    [self drawBoard];
    lettersLoaded++;
    [gameController prepareCurrentLetterWithRestrictions:[self getBonusString]];
    [self insertNewLetter];
}



-(void)countUp:(ccTime)delta {
    
     countTimerSeconds++;
    [countTimerLabel setString:[NSString stringWithFormat:@"%02d:%02d", countTimerMinutes,countTimerSeconds]];
    
    if (countTimerSeconds >= 59) {
        countTimerMinutes++;
        countTimerSeconds=0;
    }
//    if (self.countTimer <= 0) {
//        
//        [self unschedule:@selector(countUp:)];
//    }
}

- (void)drawBoard {
    NSArray * lockedLetters = [gameController getLockedLetters];
    if (lockedLetters == nil) {
        return;
    }
    for (NSDictionary *dic in lockedLetters) {
        NSString *letter = [dic objectForKey:@"letter"];
        int index = [[dic objectForKey:@"index"] intValue];
        int row = index/5;
        int column = index%5;
        
        CCSprite* letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",letter]];
        letterSprite.userData = letter;
        
        float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*column)+(kLETTERS_SPACING*column);
        float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
        letterSprite.color=ccYELLOW;
        letterSprite.position=ccp(xPos,yPos);
        [self addChild:letterSprite z:100 tag:(row*5+column)];
        [boardLetters addObject:letterSprite];
        
        
    }
}

#pragma mark - logic

- (void)insertNewLetter
{
    
    currentLetter = [gameController getCurrentLetter];
    
    [newLetters removeAllObjects];
    
    [lettesLoadedLabel setString:[NSString stringWithFormat:@"%d",lettersLoaded]];
    // add the extra column letter
    [self addCurentLetterToExtraColumnWithBonus:YES];

}


- (void)useBonusLetter:(int)row
{
    if (bonusLetterSelected) {
        //restore the old one to first free space
        int i = [gameController getFirstBonusIndex];
        
        CCSprite* letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",currentLetter]];
        letterSprite.userData = currentLetter;
        letterSprite.color=ccRED;
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
    
    [self removeSpritesInArray:newLetters];
    [newLetters removeAllObjects];
    
    // add the grid extra column
    [self addCurentLetterToExtraColumnWithBonus:NO];
    
}


- (void)addCurentLetterToExtraColumnWithBonus:(BOOL)bonus
{
//    [self disableTouches];
    NSMutableArray *actions = [[NSMutableArray alloc] initWithCapacity:6];
    [actions addObject:@""];
    CCSprite* letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",currentLetter]];
    
    float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+5)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*5);
    float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*0)+(letterSprite.contentSize.height*0));
    
    
    for (int j=0; j<5; j++) {
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*0)+(letterSprite.contentSize.height*0));
        
        letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",currentLetter]];
        letterSprite.userData = currentLetter;
        letterSprite.position=ccp(xPos,yPos);
//        letterSprite.scale = .75;
        [newLetters addObject:letterSprite];
        [self addChild:letterSprite z:100 tag:j+105];
        
        if (j>0) {
            yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
            CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:ccp(xPos, yPos)];
            [actions addObject:move];
        }
        
    }
    
    if (bonus) {
        xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+5)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*5);
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*0)+(letterSprite.contentSize.height*0));
        
        letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",currentLetter]];
        letterSprite.userData = currentLetter;
        letterSprite.position=ccp(xPos,yPos);
//        letterSprite.scale = .75;
        [newLetters addObject:letterSprite];
        [self addChild:letterSprite z:100 tag:5+105];
        letterSprite.position=ccp(xPos,yPos);
        
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
        CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:ccp(xPos, yPos)];
        [actions addObject:move];
    }
    
    for (int i = 1; i< [actions count]; i++) {
        
        for (int j=i; j<[newLetters count]; j++)  {
            letterSprite = [newLetters objectAtIndex:j];
            CCMoveTo* move = [[actions objectAtIndex:i] copy];
            [letterSprite performSelector:@selector(runAction:) withObject:move afterDelay:4*i*kANIMATION_DURATION];
        }
    }
    
    
    //    [self performSelector:@selector(enableTouches) withObject:nil afterDelay:5*[actions count]*kANIMATION_DURATION ];
}

- (void)addCurrentLetterToMatrix:(int)row {
    int column = [gameController getFirstColumnIndexOfRow:row];
    if (column > 4) {
        return;
    }
    
    [self removeSpritesInArray:newLetters];
    [gameController addLetterAtIndex:row*5+column];
    
    CCSprite* letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",currentLetter]];
    letterSprite.userData = currentLetter;
    float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*column);
    float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
    
    
    letterSprite.color=ccYELLOW;
    letterSprite.position=ccp(xPos,yPos);
    [self addChild:letterSprite z:100 tag:(row*5+column)];
    [boardLetters addObject:letterSprite];
    
    
    xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*column)+(kLETTERS_SPACING*column);
    yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
    float duration = kANIMATION_DURATION*(5-column);
    CCMoveTo* move=[CCMoveTo actionWithDuration:duration position:ccp(xPos, yPos)];
    [letterSprite runAction:move];
    
    
    if (bonusLetterSelected) {
        bonusLetterSelected = NO;
    }else {
        lettersLoaded++;
        [gameController prepareCurrentLetterWithRestrictions:[self getBonusString]];
    }
    
    
    [self checkLockedRow:row];
    [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:.5];
    
}


- (void)addBonusLetter:(int)row {
    
    if (![gameController canAddBonusLetter]) {
        return;
    }
    [self removeSpritesInArray:newLetters];
    int i = 5;
    
    CCSprite* letterSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png",currentLetter]];
    letterSprite.userData = currentLetter;
    float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
    float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
    letterSprite.color=ccRED;
    letterSprite.position=ccp(xPos,yPos);
    
    
    
    i = [gameController getFirstBonusIndex];
    
    [self addChild:letterSprite z:100 tag:i+200];
    [bonusLetters addObject:letterSprite];
    [gameController addBonusLetterAtIndex:i];
    
    xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
    yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
    float duration = kANIMATION_DURATION*(5-i);
    CCMoveTo* move=[CCMoveTo actionWithDuration:duration position:ccp(xPos, yPos)];
    [letterSprite runAction:move];
    
    lettersLoaded++;
    [gameController prepareCurrentLetterWithRestrictions:[self getBonusString]];
    [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:.5];
    
}


-(void)shiftSprite:(CCSprite*)sprite
{
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



- (void)checkLockedRow:(int)row
{
    NSString *word = @"";
    for (int i=row*5; i< (row+1)*5; i++) {
        CCSprite* sprite = (CCSprite*)[self getChildByTag:i];
        if (sprite != nil) {
            word = [word stringByAppendingString:sprite.userData];
        }
    }
    
    if ([word length] == 5 && [gameController isCorrectWord:word]) {
        [gameController lockRow:row];
    } 
}

-(void)checkIsWordCorrect { 
    if ([collectedWord count]>2) {
        NSString *word = @"";
        for (CCSprite* letterSprite in collectedWord) {
            word = [word stringByAppendingString:[letterSprite userData]];
        }
        NSLog(@"word:%@",word);
        if ([gameController isCorrectWord:word]) {
            NSLog(@"correct word");
            correctWordFound = YES;
            for (CCSprite* collectedLetter in collectedWord) {
                collectedLetter.color=ccGREEN;
            }
            [self performSelector:@selector(removeCorrectWord) withObject:nil afterDelay:2];
            return;
        }
    }
    for (CCSprite* collectedLetter in collectedWord) {
        collectedLetter.color=boardLettersColor;
    }
    [collectedWord removeAllObjects];
}


- (void)removeCorrectWord {
    CCLOG(@"removeCorrectWord");
    @synchronized (collectedWord) {
        CCLOG(@"removeCorrectWord->synchronized");
        if (correctWordFound) {
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
//            [self removeSpritesInArray:newLetters];
//            [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:kANIMATION_DURATION];
        }
    }
    
    
}

- (void)cancelRemoveCorrectWord {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeCorrectWord) object:nil];
    CCLOG(@"cancelRemoveCorrectWord");
    @synchronized (collectedWord) {
        CCLOG(@"cancelRemoveCorrectWord->synchronized");
        
        correctWordFound = NO;
        for (CCSprite* collectedLetter in collectedWord) {
            collectedLetter.color=boardLettersColor;
        }
        [collectedWord removeAllObjects];
    }
    
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
- (void)updateScoreLabel{
//    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];    
}


#pragma mark - GameOver

- (void)gameOver {
    isGameOver=YES;
    if(score>0){
        [self showShareAlert];
    }
    [self performSelector:@selector(disableTouches) withObject:nil afterDelay:0.05 ];
    [self unscheduleAllSelectors];
}


#pragma mark - ShareAlert

- (void)showShareAlert {
    
    
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
            if (count<1) {
                letterSprite.color=ccRED;
                [collectedWord addObject:letterSprite];
            } else {
                if ([collectedWord containsObject:letterSprite]) {
                    if (count>1 && [collectedWord objectAtIndex:[collectedWord count]-2]==letterSprite) {
                        ((CCSprite*)[collectedWord lastObject]).color=boardLettersColor;
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
        [[CCDirector sharedDirector] popScene];
        return;
    }
    
    if (correctWordFound) {
        @synchronized (collectedWord) {
            CCLOG(@"ccTouchEnded->synchronized");
            CGPoint location = [touch locationInView:[touch view]]; 
            location = [[CCDirector sharedDirector] convertToGL:location];    
            CGRect letterArea;
            for (CCSprite* letterSprite in collectedWord) {
                letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
                if (CGRectContainsPoint(letterArea, location)) {
                    [self cancelRemoveCorrectWord];
                }
            }
        }
    } else if (selectingWord) { //word collected
        selectingWord = NO;
        [self checkIsWordCorrect];
        
    } else {
        
        CGRect letterArea;
        
        // select a tile at the extra column -> insert the letter at the selected row
        for (CCSprite* letterSprite in newLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                [self performSelector:@selector(extraColumnLetterTouchedAtRow:) withObject:[NSNumber numberWithInt:letterSprite.tag-105] afterDelay:.01 ];
                return;
            }
        }
        
        // select a tile at the bonus area -> use selected letter in the extra column 
        for (CCSprite* letterSprite in bonusLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
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
        [self addBonusLetter:[row intValue]];
    }
}


- (void)bounsLetterTouchedAtRow:(NSNumber*)row {
    [self useBonusLetter:[row intValue]];
}



#pragma Enable/Disable Touches
- (void)disableTouches {
    self.isTouchEnabled=NO;
//    ((CCMenu*)[self getChildByTag:GameSceneTagButtons]).isTouchEnabled=NO;
    
}

- (void)enableTouches {
    self.isTouchEnabled=YES;
//    ((CCMenu*)[self getChildByTag:GameSceneTagButtons]).isTouchEnabled=YES;
}



#pragma mark Utils

- (void)removeSpritesInArray:(NSMutableArray*)spritesArray {
    
    for (CCSprite* letter in spritesArray) {
        [letter removeFromParentAndCleanup:YES];
    }
    [spritesArray removeAllObjects];
    
}

#pragma mark - UI Events

- (void)onEnterTransitionDidFinish {
    [self newGame];
}

- (void)onEnter {
    [super onEnter];
}

- (void)onExit {
    adView.hidden=YES;
    
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
//    [[CDAudioManager sharedManager]stopBackgroundMusic];
    [super onExit];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc {
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    
    //    [droppedLettersSprites release];
    //    [droppedLettersImages release];
    
	// don't forget to call "super dealloc"
    
    
    [newLetters release];
    [bonusLetters release];
    [boardLetters release];
    [collectedWord release];
	[super dealloc];
}

@end
