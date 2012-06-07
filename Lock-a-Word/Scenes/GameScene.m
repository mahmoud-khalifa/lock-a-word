//
//  GameScene.m
//  Word9
//
//  Created by Log n Labs on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "GameScene.h"
#import "GameConfig.h"
#import "StatisticsCollector.h"
#import "SimpleAudioEngine.h"

#import "ShareAlertView.h"
#import "BlockAlertView.h"
@interface GameScene (PrivateMethods)

-(void)newGame;
-(void)initializeGame;
-(void)drawBoardWithAnimation:(BOOL)animated;
-(void)drawBoardLettersWithDelay;
-(void)addButtons;
-(void)addBgImages;
-(void)backItemTouched:(id)sender;
-(void)removeSpritesInArray:(NSMutableArray*)spritesArray;
-(void)gameOver;
-(void)showShareAlert;


- (void)insertNewLetter;
- (void)addCurrentLetterToMatrix:(int)row;
- (void)addBonusLetter:(int)row;
- (void)useBonusLetter:(int)row;
-(void)boardLetterTouchedAtRow:(NSNumber*)row;
-(void)bounsLetterTouchedAtRow:(NSNumber*)row;
-(void)checkIsWordCorrect;
-(void)shiftSprite:(CCSprite*)sprite;
-(void)calculateRowStatus:(int)row;

@end
// GameScene implementation
@implementation GameScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
    }
	return self;
}

-(void)initializeGame {
    levelNum=0;
    score=0;  
    isGameOver=NO;
    gameController=[Controller sharedController];
    
    
    frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
    [frameCache  addSpriteFramesWithFile:@"normal_letters.plist"];
    [frameCache  addSpriteFramesWithFile:@"red_letters.plist"];
    [frameCache  addSpriteFramesWithFile:@"small_letters.plist"];
    
    newLetters = [[NSMutableArray alloc] init];
    bonusLetters = [[NSMutableArray alloc] init];
    bonusLettersImages = [[NSMutableArray alloc] init];
    boardLetters =  [[NSMutableArray alloc] init];
    collectedWord=[[NSMutableArray alloc]init];
    rowsStatus = [[NSMutableArray alloc]initWithObjects:@"0", @"0", @"0", @"0", @"0", nil];
    
    boardLettersColor = ccYELLOW;
    [self addBgImages];
    [self addButtons];
    
    self.isTouchEnabled=YES;
}

- (void)addBgImages {
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    NSString* InstructionsImage=@"your_mission_bg.png";
    NSString* bgImage=@"game_bg.png";
    if (IS_IPAD()) {
        bgImage=@"game_bg_ipad.png";
        InstructionsImage=@"your_mission_bg_ipad.png";
    }
    CCSprite* bgSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:bgImage]];
    bgSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
    [self addChild:bgSprite z:-1];
    
    instructionsSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:InstructionsImage]];
    instructionsSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
    [self addChild: instructionsSprite z:200];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    
}
-(void)newGame{
    levelNum++;
    [gameController startNewGame];
    [self performSelector:@selector(drawBoardLettersWithDelay) withObject:nil afterDelay:kANIMATION_DURATION];
}
-(void)drawBoardLettersWithDelay{
    [self drawBoardWithAnimation:NO];
//    [self scheduleUpdate];
    ((CCMenu*) [self getChildByTag:GameSceneTagButtons]).isTouchEnabled=YES;
    self.isTouchEnabled=YES;
    [self insertNewLetter];
}

-(void)addScoreLabel{
    
    scoreLabel=[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", score] fntFile:@"score_bitmapfont.fnt"];
    
    scoreLabel.anchorPoint=ccp(0, 0.5);
    scoreLabel.position=ccp(ADJUST_DOUBLE( kSCORE_LABEL_X_POS),ADJUST_Y(kSCORE_LABEL_Y_POS));
    
    scoreLabel.color=ccc3(102, 204, 255);//(93, 183, 230);
    [self addChild:scoreLabel];
    
}

-(void)addButtons{
    [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
    
    CCMenuItemSprite* backItem=[CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"back_btn.png"]] selectedSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"back_btn.png"]] target:self selector:@selector(backItemTouched:)];
    
    
    backItem.position=ADJUST_XY(kBACK_BUTTON_X_POS,kBACK_BUTTON_Y_POS);
    
    backButtons=[CCMenu menuWithItems:backItem, nil];
    backButtons.position=ccp(0, 0);
    backButtons.anchorPoint=ccp(0, 0);
    [self addChild:backButtons ];
    
    backButtons.isTouchEnabled=NO;
}
-(void)backItemTouched:(id)sender{
    [[CCDirector sharedDirector]popScene];    
    
}
-(void)update:(ccTime)delta{
	
    
}
-(void)drawBoardWithAnimation:(BOOL)animated{
    
    if (!isGameOver) {
        CCSprite* letterSprite;
        CGFloat xPos;
        CGFloat yPos;
        
        for (int j=0; j<5; j++) {
            for (int i=0; i<5; i++) {
                letterSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"grid.png"]];
                
                xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
                yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
                
                
                letterSprite.color=ccYELLOW;
                letterSprite.position=ccp(xPos,yPos);
                
                [self addChild:letterSprite];
                
                if (animated) {
                    letterSprite.scale=0.5;
                    CCScaleTo* scaleTo=[CCScaleTo actionWithDuration:kANIMATION_DURATION scale:1];
                    [letterSprite runAction:scaleTo];
                }
            }
        }
        
        xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+5)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*5);
        
        for (int j=0; j<5; j++) {
            letterSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"grid.png"]];            
            yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
            
            
            letterSprite.color=ccGREEN;
            letterSprite.position=ccp(xPos,yPos);
            
            [self addChild:letterSprite];
            
            if (animated) {
                letterSprite.scale=0.5;
                CCScaleTo* scaleTo=[CCScaleTo actionWithDuration:kANIMATION_DURATION scale:1];
                [letterSprite runAction:scaleTo];
            }
        }
        
    }
    
}
-(void)removeSpritesInArray:(NSMutableArray*)spritesArray{

    for (CCSprite* letter in spritesArray) {
        [letter removeFromParentAndCleanup:YES];
    }
    [spritesArray removeAllObjects];
    
}

#pragma mark Lock A Word

- (void)addCurrentLetterToMatrix:(int)row {
    [self removeSpritesInArray:newLetters];
    int column = [gameController getFirstColumnIndexOfRow:row];
    [gameController addCurrentLetterToMatrix:row];
    
    CCSprite* letterSprite =[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:currentLetterImage]];
    letterSprite.userData = currentLetter;
    float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*column)+(kLETTERS_SPACING*column);
    float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
    letterSprite.color=ccYELLOW;
    letterSprite.position=ccp(xPos,yPos);
    [self addChild:letterSprite z:100 tag:(row*5+column)];
    [boardLetters addObject:letterSprite];
    if (bonusLetterSelected) {
        bonusLetterSelected = NO;
    }else {
        [gameController prepareNextLetter];
    }
    [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:.5];
    
    [self calculateRowStatus:row];
}


- (void)insertNewLetter
{
    
    currentLetterImage = [gameController getCurrentLetterImage];
    currentLetter = [gameController getCurrentLetter];
    CCSprite* letterSprite;
    CGFloat xPos;
    CGFloat yPos;
    
    [newLetters removeAllObjects];
    // add the grid letters
    for (int j=0; j<5; j++) {
        int i = [gameController getFirstColumnIndexOfRow:j];
        if (i>4) {
            continue;
        }
        letterSprite =[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:currentLetterImage]];
        letterSprite.userData = currentLetter;
        xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
        
        
        letterSprite.color=ccBLUE;
        letterSprite.position=ccp(xPos,yPos);
        letterSprite.scale = .75;
        [newLetters addObject:letterSprite];
        [self addChild:letterSprite z:100 tag:j+100];
        
    }
    // add the extra column letters
    letterSprite =[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:currentLetterImage]];
    letterSprite.userData = currentLetter;
    xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+5)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*5);
    
    for (int j=0; j<5; j++) {
        letterSprite =[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:currentLetterImage]];
        letterSprite.userData = currentLetter;
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
        
        
        letterSprite.color=ccBLUE;
        letterSprite.position=ccp(xPos,yPos);
        letterSprite.scale = .75;
        [newLetters addObject:letterSprite];
        [self addChild:letterSprite z:100 tag:j+105];
        
    }

}

- (void)useBonusLetter:(int)row {
    if (bonusLetterSelected) {
        return;
    }
    bonusLetterSelected = YES;
    [self removeSpritesInArray:newLetters];
    
    CCSprite* letterSprite;
    CGFloat xPos;
    CGFloat yPos;
    
    for (int i=0; i<[bonusLetters count]; i++) {
        letterSprite = [bonusLetters objectAtIndex:i];
        if (letterSprite.tag-200 ==row) {
            currentLetterImage = [bonusLettersImages objectAtIndex:i];
            currentLetter = [[bonusLetters objectAtIndex:i] userData];
            [letterSprite removeFromParentAndCleanup:YES];
            [bonusLetters removeObjectAtIndex:i];
            [bonusLettersImages removeObjectAtIndex:i];
            [gameController removeLetterFromBonus:row];
            break;
        }
    }
       
    [newLetters removeAllObjects];
    // add the grid letters
    for (int j=0; j<5; j++) {
        int i = [gameController getFirstColumnIndexOfRow:j];
        if (i>4) {
            continue;
        }
        letterSprite =[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:currentLetterImage]];
        letterSprite.userData = currentLetter;
        xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
        yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
        
        
        letterSprite.color=ccBLUE;
        letterSprite.position=ccp(xPos,yPos);
        letterSprite.scale = .75;
        [newLetters addObject:letterSprite];
        [self addChild:letterSprite z:100 tag:j+100];
        
    }
    
}


- (void)addBonusLetter:(int)row {
    
    if (![gameController canAddBonusLetter]) {
        return;
    }
    [self removeSpritesInArray:newLetters];
    int i = 5;
    
    CCSprite* letterSprite =[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:currentLetterImage]];
    letterSprite.userData = currentLetter;
    float xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+5)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
    float yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
    letterSprite.color=ccRED;
    letterSprite.position=ccp(xPos,yPos);
    
    
    
    i = [gameController getFirstBonusIndex];
    
    [self addChild:letterSprite z:100 tag:i+200];
    [bonusLetters addObject:letterSprite];
    [bonusLettersImages addObject:currentLetterImage];
    [gameController addCurrentLetterToBonus:i];
    
    xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+30)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+(kLETTERS_SPACING*i);
    yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*5.5)+(letterSprite.contentSize.height*5.5));
    CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:ccp(xPos, yPos)];
    [letterSprite runAction:move];
    
    [gameController prepareNextLetter];
    [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:.5];
    
}
-(void)boardLetterTouchedAtRow:(NSNumber*)row{
    [self addCurrentLetterToMatrix:[row intValue]];
}
-(void)extraColumnLetterTouchedAtRow:(NSNumber*)row{
    [self addBonusLetter:[row intValue]];
}
-(void)bounsLetterTouchedAtRow:(NSNumber*)row{
    [self useBonusLetter:[row intValue]];
}


-(void)checkIsWordCorrect{ 
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

- (void)removeCorrectWord
{
    if (correctWordFound) {
        correctWordFound = NO;
        int wordLength = [collectedWord count];
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
            letterSprite = (CCSprite*)[self getChildByTag:i];
            newIndex = i-wordLength;
            newColumn = newIndex%5;
            if (letterSprite != nil) {
                xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*newColumn)+(kLETTERS_SPACING*newColumn);
                yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*row)+(letterSprite.contentSize.height*row));
                
                letterSprite.tag = newIndex;
                CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:ccp(xPos, yPos)];
                [letterSprite runAction:move];
                
            }
        }
        [gameController removeWordFromMatrix:row length:wordLength];
        [self removeSpritesInArray:newLetters];
        [self calculateRowStatus:row];
        [self performSelector:@selector(insertNewLetter) withObject:nil afterDelay:kANIMATION_DURATION];
    }
    
}

-(void)shiftSprite:(CCSprite*)sprite
{
    CCSprite* sprite2 = (CCSprite*)[self getChildByTag:sprite.tag-1];
    
    int tag = sprite.tag;
    sprite.tag = sprite2.tag;
    sprite2.tag = tag; 

    CGPoint pos = sprite.position;
    CGPoint pos2 = sprite2.position;
    
    CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:pos2];
    [sprite runAction:move];
    
    CCMoveTo* move2=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:pos];
    [sprite2 runAction:move2];
       
}

-(void)calculateRowStatus:(int)row
{
    NSString *word = @"";
    for (int i=row*5; i< (row+1)*5; i++) {
        CCSprite* sprite = (CCSprite*)[self getChildByTag:i];
        if (sprite != nil) {
            word = [word stringByAppendingString:sprite.userData];
        }
    }
    
    if ([word length] < 5) {
        [rowsStatus removeObjectAtIndex:row];
        [rowsStatus insertObject:[NSString stringWithFormat:@"%d",AvailalbeRow] atIndex:row];
    } else if ([word length] == 5) {
        [rowsStatus removeObjectAtIndex:row];
        if ([gameController isCorrectWord:word]) {
            [rowsStatus insertObject:[NSString stringWithFormat:@"%d",LockedRow] atIndex:row];
        }else {
            [rowsStatus insertObject:[NSString stringWithFormat:@"%d",CompletedRow] atIndex:row];
        }
    } 
}

#pragma mark Tracking Touches
-(void) registerWithTouchDispatcher{ 
    [[CCTouchDispatcher sharedDispatcher]addTargetedDelegate:self priority:-1 swallowsTouches:YES];
    
}
-(BOOL) ccTouchBegan:(UITouch *)touch  withEvent:(UIEvent *)event
{
    if (instructionsSprite) {
        return YES;
    }
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    if (instructionsSprite) {
        return;
    }
    selectingWord = YES;
    CGPoint location = [touch locationInView:[touch view]]; 
    location = [[CCDirector sharedDirector] convertToGL:location];         
    
    CGRect letterArea;
    for (CCSprite* letterSprite in boardLetters) {
        letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
        //locked row
        if ([[rowsStatus objectAtIndex:letterSprite.tag/5] intValue] == LockedRow) {
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
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if (instructionsSprite) {
        [instructionsSprite removeFromParentAndCleanup:YES];
        instructionsSprite=nil;
        backButtons.isTouchEnabled=YES;
        [self newGame];
    } else if (correctWordFound) {
        CGPoint location = [touch locationInView:[touch view]]; 
        location = [[CCDirector sharedDirector] convertToGL:location];    
        CGRect letterArea;
        for (CCSprite* letterSprite in collectedWord) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeCorrectWord) object:nil];
                correctWordFound = NO;
                for (CCSprite* collectedLetter in collectedWord) {
                    collectedLetter.color=boardLettersColor;
                }
                [collectedWord removeAllObjects];
            }
        }
        
    } else if (selectingWord) { //word collected
        selectingWord = NO;
        [self checkIsWordCorrect];
        
    } else {
        CGPoint location = [touch locationInView:[touch view]]; 
        location = [[CCDirector sharedDirector] convertToGL:location];         
        
        CGRect letterArea;
        for (CCSprite* letterSprite in newLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                if (letterSprite.tag < 105) {
                    [self performSelector:@selector(boardLetterTouchedAtRow:) withObject:[NSNumber numberWithInt:letterSprite.tag-100] afterDelay:.01 ];
                }else {
                    [self performSelector:@selector(extraColumnLetterTouchedAtRow:) withObject:[NSNumber numberWithInt:letterSprite.tag-105] afterDelay:.01 ];
                }
                return;
            }
        }
        
        for (CCSprite* letterSprite in bonusLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                [self performSelector:@selector(bounsLetterTouchedAtRow:) withObject:[NSNumber numberWithInt:letterSprite.tag-200] afterDelay:.01 ];
                return;
            }
        }
        
        for (CCSprite* letterSprite in boardLetters) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            //locked row
            if ([[rowsStatus objectAtIndex:letterSprite.tag/5] intValue] == CompletedRow) {
                if (CGRectContainsPoint(letterArea, location)) {
                    int colunm = letterSprite.tag%5;
                    if (colunm > 0) {
                        [self shiftSprite:letterSprite];
                        return;
                    }
                }
            }
            
        }
        
        
    }
    
}


-(void)updateScoreWithWordLength:(int)wordLength andSubmittedLettersCount:(int)submittedLetters{
    int bonus=0;
    if (wordLength==4) {
        bonus=40;
    }else if(wordLength==5){
        bonus=50;
    }
    score+=bonus;    
}
-(void)updateScoreLabel{
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];    
}

-(void)gameOver{
    isGameOver=YES;
    [[CDAudioManager sharedManager]stopBackgroundMusic];
    if(score>0){
        [self showShareAlert];
    }
    [self performSelector:@selector(disableTouches) withObject:nil afterDelay:0.05 ];
    [self unscheduleAllSelectors];
}


-(void)disableTouches{
    self.isTouchEnabled=NO;
    ((CCMenu*)[self getChildByTag:GameSceneTagButtons]).isTouchEnabled=NO;
    
}


#pragma mark ShareAlert
-(void)showShareAlert{
    
    
}

#pragma mark -

-(void)onEnterTransitionDidFinish
{
    [self initializeGame];
}

-(void)onEnter{
    [super onEnter];
}
-(void)onExit{
    [[CCTouchDispatcher sharedDispatcher]removeDelegate:self];
    
    [[CDAudioManager sharedManager]stopBackgroundMusic];
    [super onExit];
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    
    //    [droppedLettersSprites release];
    //    [droppedLettersImages release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}


#pragma mark AlertViewDelegate
//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
//    if (buttonIndex==0){
//        [[CCDirector sharedDirector]popScene];
////        [StatisticsCollector logEvent:[NSString stringWithFormat:@"End Game with Game Over - Mode:%@",EventName]];
//        
//        NSDictionary *parameters = 
//        [NSDictionary dictionaryWithObjectsAndKeys:EventName, 
//         @"Game Mode", 
//         nil];
//        [StatisticsCollector logEvent:@"End Game With Game Over" withParameters:parameters];
//       // [StatisticsCollector logEvent:@"End Game With Game Over"];
//    }else{
////        [self newGame];
//    }
//}

@end
