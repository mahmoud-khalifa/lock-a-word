//
//  GameSceneOld.m
//  Word9
//
//  Created by Log n Labs on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "GameSceneOld.h"
#import "GameConfig.h"
#import "StatisticsCollector.h"
#import "SimpleAudioEngine.h"

#import "ShareAlertView.h"
#import "BlockAlertView.h"
@interface GameSceneOld (PrivateMethods)

-(void)newGame;
-(void)drawAvailableLettersWithAnimation:(BOOL)animated;

-(void)drawBoardWithAnimation:(BOOL)animated;
-(void)refreshBoard:(id)sender;
-(void)startCountdown;
-(void)addScoreLabel;
-(void)addTimer;
-(void)addButtons;

-(void)backItemTouched:(id)sender;
-(void)addSpaceShipSprite;
-(void)removeSpritesInArray:(NSMutableArray*)spritesArray;

-(void)boardLetterTouchedAtIndex:(NSNumber*)index;

-(void)swapSpritesAtIndex1:(int)index1 andIndex2:(int)index2;
-(void)checkIsWordCorrect;
-(void)dropSelectedLetters:(id)sender;
-(void)moveLettersDownAtIndexes:(NSMutableIndexSet*)indexes;
//-(void)setLastTime;
-(void)updateScoreWithWordLength:(int)wordLength andSubmittedLettersCount:(int)submittedLetters;
-(void)gameOver;
-(void)addAliensAnimationWithLettersArray:(NSArray*)letters;
-(void)addBonusWithAnimation:(ccTime)delta;

-(void)showShareAlert;
@end
// GameScene implementation
@implementation GameSceneOld

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameSceneOld *layer = [GameSceneOld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) initWithGameMode:(GameModes)mode andMustDropAllLetters:(BOOL)must
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        NSString* modeName;
        switch (mode) {
            case GameModeHorizontal:
                modeName=kCROSS_STEP_LEADERBOARD_ID;
                break;
            case GameModeVertical:
                modeName=kCHA_CHA_LEADERBOARD_ID;
                break;
            case GameModeDropAll:
                modeName=kHUMANOID_TWIST_LEADERBOARD_ID;
                break;
            case GameModeBoth:
                modeName=kALIEN_JIG_LEADERBOARD_ID;
                break;
            default:
                break;
        }
        [[NSUserDefaults standardUserDefaults]setObject:modeName forKey:kLAST_PLAYED_GAME_MODE_KEY];
        
        levelNum=0;
        frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        
        [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
        [frameCache  addSpriteFramesWithFile:@"normal_letters.plist"];
        [frameCache  addSpriteFramesWithFile:@"red_letters.plist"];
        [frameCache  addSpriteFramesWithFile:@"small_letters.plist"];
        
       
        
		mustDropAllLetters=must;
        vowelLetter=[[NSString alloc]initWithString:@""];
        allVowelLetters=[[NSArray alloc]initWithObjects:@"a",@"e",@"o",@"i",@"u", nil];
//        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        
        gameController=[Controller sharedController];
        
        gameMode=mode;
        
        NSString* InstructionsImage=@"your_mission_bg.png";
        NSString* bgImage=@"game_bg.png";
        if (IS_IPAD()) {
            bgImage=@"game_bg_ipad.png";
              InstructionsImage=@"your_mission_bg_ipad.png";
        }
        CCSprite* bgSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:bgImage]];
        bgSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
        [self addChild:bgSprite z:-1];
        
        InstructionsSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:InstructionsImage]];
        InstructionsSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
        [self addChild: InstructionsSprite z:200];
        
        availableLettersImages=[[NSMutableArray alloc]init];
        availableLettersSprites=[[NSMutableArray alloc]init];
        
        boardLettersSprites=[[NSMutableArray alloc]init];
        collectedWord=[[NSMutableArray alloc]init];
        
        rightSprites=[[NSMutableArray alloc]init];
        rightLetters=[[NSMutableArray alloc]init];
//        droppedLettersSprites=[[NSMutableArray alloc]init];
//        droppedLettersImages=[[NSMutableArray alloc]init];
        [self addButtons];
        score=0;  
        
        
        //Removed from here, will be called after removing the instructions sprite
//        [self newGame];
//        [self addSpaceShipSprite];
    
//        lowerLettersRowIndex=0;
//        lowerLettersColIndex=0;
        

        
//        [self addScoreLabel];
        
        self.isTouchEnabled=YES;
        
//        numberOfCorrectWords=0;

        
//        [self addTimer];
        
       
        [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
        
        
//        CCSprite* wordBar=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"word_bar.png"]];
//        wordBar.position=ADJUST_XY(kWORD_BAR_X_POS, kWORD_BAR_Y_POS);
//        wordBar.anchorPoint=ccp(0.5, 0);
//        [self addChild:wordBar];
        
        isGameOver=NO;
	
//        targetLabel=[CCLabelBMFont labelWithString:@"" fntFile:@"high_score_bitmapfont.fnt"];
//       
//        targetLabel.position=ccp(screenSize.width*0.5,screenSize.height-ADJUST_DOUBLE(20));
//        targetLabel.color=ccYELLOW;
//        [self addChild:targetLabel];
    }
	return self;
}

-(void)newGame{
  //     [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"alien.mp3" loop:YES];
    levelNum++;
    if (levelNum<4) {
        targetLevelScore=score+(50*levelNum);
    }else {
        targetLevelScore=score+200;
    }
    [targetLabel setString:[NSString stringWithFormat:@"TARGET:%d",targetLevelScore]];
    swappedIndex1=-1;
    swappedIndex2=-1;
   [gameController startGameWithMode:gameMode]; 
    if ([self getChildByTag:GameSceneTagCountDownTimer]) {
        [self removeChildByTag:GameSceneTagCountDownTimer cleanup:YES];
    }
//    [countDownTimerLabel removeFromParentAndCleanup:YES];
//    score=0;        
    isPanicMode=NO;
    boardLettersColor=ccWHITE;
    
    countDownTotalTime=-1;
    myCountDownTime=-1;
    
    myTime=kTOTAL_BONUS_TIMER;
    totalTime=kTOTAL_BONUS_TIMER;
//    [self performSelector:@selector(drawAvailableLettertsWithDelay) withObject:nil afterDelay:kANIMATION_DURATION ];
    [self performSelector:@selector(drawBoardLettersWithDelay) withObject:nil afterDelay:kANIMATION_DURATION];
//    [self scheduleUpdate];
    vowelLetter=@"";
    if ([self getChildByTag:GameSceneTagVowelLetter]) {
        [ self removeChildByTag:GameSceneTagVowelLetter cleanup:YES];
    }
//    ((CCMenu*) [self getChildByTag:GameSceneTagButtons]).isTouchEnabled=YES;
//     self.isTouchEnabled=YES;
    
    
}
-(void)drawBoardLettersWithDelay{
    [self drawBoardWithAnimation:NO];
    [self scheduleUpdate];
    ((CCMenu*) [self getChildByTag:GameSceneTagButtons]).isTouchEnabled=YES;
    self.isTouchEnabled=YES;
}
-(void)drawAvailableLettertsWithDelay{
    [self drawAvailableLettersWithAnimation:YES];
}

-(void)drawAvailableLettersWithAnimation:(BOOL)animated{
    
    [self removeSpritesInArray:availableLettersSprites];
    availableLettersImages=[[gameController getAvailableLettersImages ] retain];//[[gameController getLettersImagesNames:gameController.availableLetters] retain];
    
    
    CCSprite* letterSprite;
    int i=0;
    int j=0;
    
    CGFloat xPos;
    CGFloat yPos;
    float xOffset;
   // NSLog(@"available images:%@",availableLettersImages);
    
    [frameCache  addSpriteFramesWithFile:@"small_letters.plist"];
    for (NSString* imageName in availableLettersImages) {
        letterSprite=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:imageName]];
//        float scale=kCORRECT_WORD_SCALE;
//        letterSprite.scale=scale;
        if (j==1) {
            xOffset=-(letterSprite.contentSize.width*0.6);
        }else{
            xOffset=0;
        }
        xPos= ADJUST_X( kAVAILABLE_LETTERS_X_OFFSET)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*i)+kLETTERS_SPACING*i+xOffset;
        yPos=screenSize.height-(ADJUST_Y(kAVAILABLE_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*kAVAILABLE_LETTERS_OVERLAP_RATIO*j));
        if (animated) {
            letterSprite.position=ccp(xPos, yPos-screenSize.height);
            CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:ccp(xPos, yPos)];
            [letterSprite runAction:move];
            
            
        }else{
            letterSprite.position=ccp(xPos,yPos);
        }
        
        [availableLettersSprites addObject:letterSprite];
        [self addChild:letterSprite];
        
        i++;
        
        if (i%9==0) {
            j++;
            i=0;
        }
    }
}

-(void)addScoreLabel{

    scoreLabel=[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", score] fntFile:@"score_bitmapfont.fnt"];
    
    scoreLabel.anchorPoint=ccp(0, 0.5);
    scoreLabel.position=ccp(ADJUST_DOUBLE( kSCORE_LABEL_X_POS),ADJUST_Y(kSCORE_LABEL_Y_POS));
    
    scoreLabel.color=ccc3(102, 204, 255);//(93, 183, 230);
    [self addChild:scoreLabel];
    
}

-(void)addTimer{
    timerLabel=[CCLabelBMFont labelWithString:@"600" fntFile:@"score_bitmapfont.fnt"];

    timerLabel.position=ccp(screenSize.width-ADJUST_DOUBLE(kTIMER_LABEL_X_POS), ADJUST_Y(kTIMER_LABEL_Y_POS));
    
    timerLabel.anchorPoint=CGPointMake(0.0f, 0.5f);
    timerLabel.color=ccc3(102, 204, 255);//(93, 183, 230);
    [self addChild:timerLabel ];
 

    
//    lastWordTimeLabel=[CCLabelBMFont labelWithString:@"" fntFile:@"score_bitmapfont.fnt"];
//    lastWordTimeLabel.position=CGPointMake(kLAST_TIME_LABEL_X_POS, kLAST_TIME_LABEL_Y_POS);
//    
//    lastWordTimeLabel.anchorPoint=CGPointMake(0.0f, 0.5f);
//    
//    [self addChild:lastWordTimeLabel ];

    
}
-(void)addButtons{
    [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
    
    CCMenuItemSprite* backItem=[CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"back_btn.png"]] selectedSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"back_btn.png"]] target:self selector:@selector(backItemTouched:)];
   

    backItem.position=ADJUST_XY(kBACK_BUTTON_X_POS,kBACK_BUTTON_Y_POS);
    
//    CCSprite* panicSprite=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"panic_button_normal.png"]];
//    CCSprite* panicSprite_selected=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"panic_button_pressed.png"]];
//    CCMenuItemSprite* panicItem=[CCMenuItemSprite itemFromNormalSprite:panicSprite selectedSprite:panicSprite_selected target:self selector:@selector(refreshBoard:)];
//    // CCMenu* panicButton=[CCMenu menuWithItems:panicItem, nil];
//    panicItem.position=ADJUST_XY(kPANIC_BUTTON_X_POS,kPANIC_BUTTON_Y_POS);
//   
//    
//    
//    CCMenuItemSprite* doneItem=[CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"button_down.png"]] selectedSprite:[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"button_down.png"]] target:self selector:@selector(dropSelectedLetters:)];
//    
//    // CCMenu *doneButton=[CCMenu menuWithItems:doneItem, nil];
//    doneItem.position=ADJUST_XY(kDONE_BUTTON_X_POS, kDONE_BUTTON_Y_POS);
//    doneItem.anchorPoint=ccp(0.5, 0);
    
//    buttons=[CCMenu menuWithItems:panicItem,doneItem, nil];
//    buttons.position=ccp(0, 0);
//    buttons.anchorPoint=ccp(0, 0);
//    [self addChild:buttons z:0 tag:GameSceneTagButtons];
    
    backButtons=[CCMenu menuWithItems:backItem, nil];
    backButtons.position=ccp(0, 0);
    backButtons.anchorPoint=ccp(0, 0);
    [self addChild:backButtons ];
    
//    buttons.isTouchEnabled=NO;
    backButtons.isTouchEnabled=NO;
}
-(void)backItemTouched:(id)sender{
    if(isNewHighScore){
        
        [self showShareAlert];
    }else {
        [[CCDirector sharedDirector]popScene];
        //    [StatisticsCollector logEvent:[NSString stringWithFormat:@"End Game with Back Button - Mode:%@",EventName]];
        
        NSDictionary *parameters = 
        [NSDictionary dictionaryWithObjectsAndKeys:EventName, 
         @"Game Mode", 
         nil];
        NSString* event;
        if (isGameOver) {
            event=@"End Game With Game Over";
        }else{
            event=@"End Game with Back Button";
        }
        [StatisticsCollector logEvent:event withParameters:parameters];
        
        [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];
        
        //  [StatisticsCollector logEvent:@"End Game with Back Button"];
        
        

    }
 
}
-(void)addSpaceShipSprite{
    
    [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
    
    CCSprite* spaceShip=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"space_ship.png"]];
    spaceShip.anchorPoint=ccp(0.5, 0);
    spaceShip.position=ccp(screenSize.width*0.5, screenSize.height);
    
    [self addChild:spaceShip z:-1];
    CCMoveTo* move=[CCMoveTo actionWithDuration:kANIMATION_DURATION position:ccp(screenSize.width*0.5, screenSize.height-spaceShip.contentSize.height-ADJUST_DOUBLE(25))];
    [spaceShip runAction:move];
//    CCFadeTo* fadeTo=[CCFadeTo actionWithDuration:0.3 opacity:0.5*255];
//    [spaceShip performSelector:@selector(runAction:) withObject:fadeTo afterDelay:kANIMATION_DURATION];
}
-(void)update:(ccTime)delta{
	totalTime-=delta;
    
    countDownTotalTime-=delta;
    int currentPanicTime=(int)countDownTotalTime;
    
    if (myCountDownTime>currentPanicTime &&currentPanicTime>=0) {
        myCountDownTime=currentPanicTime;
        if (myCountDownTime<=60) {
            [[CDAudioManager sharedManager]stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine]playEffect:@"countdown.mp3"];
        }
        [countDownTimerLabel setString:[NSString stringWithFormat:@"%02d:%02d",myCountDownTime/60,myCountDownTime%60]];
        if (myCountDownTime==0) {
            
            [self gameOver];
            
        }
    }
    
	int currentTime=(int)totalTime;
	if (myTime>currentTime && currentTime>=0){
		myTime=currentTime;
               
		[timerLabel setString:[NSString stringWithFormat:@"%d", myTime]];
        
    }

}

-(void)refreshBoard:(id)sender{
    if (sender!=nil) {
        //        score--;
        //        if (score<0) {
        //            score=0;
        //        }
        //        [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
        if (!isPanicMode) {
            [self startCountdown];
            isPanicMode=YES;
            boardLettersColor=ccWHITE;
             [[SimpleAudioEngine sharedEngine]playEffect:@"Siren_Noise.mp3"];
//            [[CDAudioManager sharedManager]stopBackgroundMusic];
             [[CDAudioManager sharedManager]playBackgroundMusic:@"panic_room.mp3" loop:YES];
            
        }else{
            countDownTotalTime-=20;
            if (countDownTotalTime<0) {
                countDownTotalTime=0;
                [self gameOver];
            }
            myCountDownTime=(int)countDownTotalTime;
            [countDownTimerLabel setString:[NSString stringWithFormat:@"%02d:%02d",myCountDownTime/60,myCountDownTime%60]];
            
            

        }
         
        [self drawBoardWithAnimation:NO];
//        [StatisticsCollector logEvent:[NSString stringWithFormat:@"Panic Button Pressed - Mode:%@",EventName]];
        
        NSDictionary *parameters = 
        [NSDictionary dictionaryWithObjectsAndKeys:EventName, 
         @"Game Mode", 
         nil];
        [StatisticsCollector logEvent:@"Panic Button Pressed" withParameters:parameters];
    
   //     [StatisticsCollector logEvent:@"Panic Button Pressed"];
        
    }


}
-(void)drawBoardWithAnimation:(BOOL)animated{
            
    if (!isGameOver) {
        [self removeSpritesInArray:boardLettersSprites];

//        NSMutableArray* boardLettersImages=[[gameController generateRandomBoardImagesWithIsPanicMode:isPanicMode] retain];
        CCSprite* letterSprite;
        
        
        CGFloat xPos;
        CGFloat yPos;
        
        if (isPanicMode) {
            [frameCache  addSpriteFramesWithFile:@"red_letters.plist"];
        }else {
            [frameCache  addSpriteFramesWithFile:@"normal_letters.plist"];
        }
        
        for (int j=0; j<5; j++) {
            for (int i=0; i<5; i++) {
                letterSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"grid.png"]];
                //            letterSprite=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:imageName]];
                
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
                [boardLettersSprites addObject:letterSprite];
            }
        }
        
        for (int j=0; j<5; j++) {
            letterSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"grid.png"]];
            //            letterSprite=[CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:imageName]];
            
            xPos=ADJUST_X( kBOARD_LETTERS_X_OFFSET+5)+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*5)+(kLETTERS_SPACING*5);
            yPos=screenSize.height-(ADJUST_Y(kBOARD_LETTERS_Y_OFFSET)+(kLETTERS_SPACING*j)+(letterSprite.contentSize.height*j));
            
            
            letterSprite.color=ccBLUE;
            letterSprite.position=ccp(xPos,yPos);
            
            [self addChild:letterSprite];
            
            if (animated) {
                letterSprite.scale=0.5;
                CCScaleTo* scaleTo=[CCScaleTo actionWithDuration:kANIMATION_DURATION scale:1];
                [letterSprite runAction:scaleTo];
            }
            [boardLettersSprites addObject:letterSprite];
        }
        
    }
   
}
-(void)startCountdown{
    countDownTotalTime=0.7*myTime;//24*[availableLettersSprites count];
    myCountDownTime=(int)countDownTotalTime;
    countDownTimerLabel=[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%02d:%02d",myCountDownTime/60,myCountDownTime%60] fntFile:@"score_bitmapfont.fnt"];
    countDownTimerLabel.position=ADJUST_XY(kCOUNT_DOWN_TIMER_LABEL_X_POS, kCOUNT_DOWN_TIMER_LABEL_Y_POS);
    [self addChild:countDownTimerLabel z:0 tag:GameSceneTagCountDownTimer];

}

-(void)removeSpritesInArray:(NSMutableArray*)spritesArray{

    for (CCSprite* letter in spritesArray) {
        [letter removeFromParentAndCleanup:YES];
    }
    [spritesArray removeAllObjects];
    
}

#pragma Tracking Touches
-(void) registerWithTouchDispatcher{ 
    [[CCTouchDispatcher sharedDispatcher]addTargetedDelegate:self priority:-1 swallowsTouches:YES];

}
-(BOOL) ccTouchBegan:(UITouch *)touch  withEvent:(UIEvent *)event
{
     if (!InstructionsSprite) {
//    CCLOG(@"Touch Began");
    CGPoint location = [touch locationInView:[touch view]]; 
    location = [[CCDirector sharedDirector] convertToGL:location];         
//    CGRect scoreLabelArea=CGRectMake(scoreLabel.position.x, scoreLabel.position.y-scoreLabel.contentSize.height*0.5, scoreLabel.contentSize.width+20, scoreLabel.contentSize.height+20);
//    if (CGRectContainsPoint(scoreLabelArea, location) &&score>0) {
//        score-=5;
//        [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
//        enableRandomSwap=YES;
//        
//        if (randomSprite) {
//            randomSprite.color=boardLettersColor;
//        }
//        randomSprite=(CCSprite*) [boardLettersSprites objectAtIndex:arc4random()%[boardLettersSprites count]];
//        randomSprite.color=ccGREEN;
//        
//    
//        [StatisticsCollector logEvent:@"Random Swapping used"];
//        
//    }else{
    
        CGRect letterArea;
        for (CCSprite* letterSprite in rightSprites) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)&&!mustDropAllLetters) {
                  [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];
                if (letterSprite.color.r==ccGREEN.r && letterSprite.color.g==ccGREEN.g && letterSprite.color.b==ccGREEN.b) {
                    letterSprite.color=ccWHITE;//ccORANGE;
                }else{
                    letterSprite.color=ccGREEN;
                }
            }
        }
    }
//     }
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
     if (!InstructionsSprite) {
//    CCLOG(@"Touch Moved");
    CGPoint location = [touch locationInView:[touch view]]; 
    location = [[CCDirector sharedDirector] convertToGL:location];         
    
    CGRect letterArea;
    for (CCSprite* letterSprite in boardLettersSprites) {
        letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
        if (CGRectContainsPoint(letterArea, location)) {
            if( [collectedWord count]>=2){
            if ([collectedWord objectAtIndex:[collectedWord count]-2]==letterSprite) {
                ((CCSprite*)[collectedWord lastObject]).color=boardLettersColor;
                [collectedWord removeLastObject];
            }
            }
            
            if (![collectedWord containsObject:letterSprite]) {
                  
                int indexOfLastTouchedLetter=[boardLettersSprites indexOfObject:[collectedWord lastObject]];
                int indexOfNewLetter=[boardLettersSprites indexOfObject:letterSprite];
                
                int indexesDifference=abs(indexOfNewLetter-indexOfLastTouchedLetter);
                int First2LettersDifference=-1;
                if ([collectedWord count]>1) {
                    First2LettersDifference=abs([boardLettersSprites indexOfObject:[collectedWord objectAtIndex:0]]-[boardLettersSprites indexOfObject:[collectedWord objectAtIndex:1]]);
                }
                
                if ((((indexesDifference==5)||(indexesDifference==1 &&!(indexOfNewLetter%5==4 &&indexOfLastTouchedLetter%5==0)&&!(indexOfNewLetter%5==0 &&indexOfLastTouchedLetter%5==4))||[collectedWord count]==0)&&[collectedWord count]<2)||(((indexesDifference==5 &&First2LettersDifference==5)||(indexesDifference==1&&First2LettersDifference==1 &&!(indexOfNewLetter%5==4 &&indexOfLastTouchedLetter%5==0)&&!(indexOfNewLetter%5==0 &&indexOfLastTouchedLetter%5==4)))&&[collectedWord count]>=2)) {
                    if ([collectedWord count]==0) {
                         [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];
                    }
               
//                    if (isPanicMode) {
//                        letterSprite.color=ccWHITE;
//                    }else{
                        letterSprite.color=ccRED;
//                    }
//                    letterSprite.color=ccc3(255, 255, 102);//ccc3(128, 64, 0);
                        [collectedWord addObject:letterSprite];

                }
            }
        }
    }
    
    
    isSwapping=YES;
     }

}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
//    CCLOG(@"Touch Ended");
    if (!InstructionsSprite) {
        
   
    if (!isSwapping) {
        CGPoint location = [touch locationInView:[touch view]]; 
        location = [[CCDirector sharedDirector] convertToGL:location];         
        
        CGRect letterArea;
        for (CCSprite* letterSprite in boardLettersSprites) {
            letterArea=CGRectMake(letterSprite.position.x-letterSprite.contentSize.width*0.5, letterSprite.position.y-letterSprite.contentSize.height*0.5, letterSprite.contentSize.width, letterSprite.contentSize.height);
            if (CGRectContainsPoint(letterArea, location)) {
                
                //Letter Touched:
                
               // [self performSelector:@selector(drawBoard) withObject:nil afterDelay:.2 ];
                
                int row=(letterSprite.position.x-ADJUST_X(kBOARD_LETTERS_X_OFFSET)-(letterSprite.contentSize.width*0.5))/(letterSprite.contentSize.width +kLETTERS_SPACING);
                int col=(screenSize.height-letterSprite.position.y-ADJUST_Y( kBOARD_LETTERS_Y_OFFSET))/(letterSprite.contentSize.height+kLETTERS_SPACING);
                
                int index=row+(col*5);
                
                //            CCLOG(@"index:%d",index);
                
             //   [self boardLetterTouchedAtIndex:index];
                [self performSelector:@selector(boardLetterTouchedAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:.01 ];
                break;
            }
        }

    }else{ //word collected
        [self checkIsWordCorrect];

        for (CCSprite* collectedLetter in collectedWord) {
            collectedLetter.color=boardLettersColor;
        }
        
        [collectedWord removeAllObjects];
    }
    isSwapping=NO;
    }else{
      
        [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];
        buttons.isTouchEnabled=YES;
        backButtons.isTouchEnabled=YES;
        
        [InstructionsSprite removeFromParentAndCleanup:YES];
        InstructionsSprite=nil;
        //Stop start up music
//        [[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
        if ([CDAudioManager sharedManager].backgroundMusic.isPlaying) {
            [CDAudioManager sharedManager].backgroundMusic.numberOfLoops=0;
            [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(backgroundMusicFinished)];

        }else{
        
             [[CDAudioManager sharedManager]playBackgroundMusic:@"alien.mp3" loop:YES];
        }
               
        [self newGame];
//        [self addSpaceShipSprite];

    }
}
-(void)backgroundMusicFinished{
    [[CDAudioManager sharedManager]playBackgroundMusic:@"alien.mp3" loop:YES];
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:nil selector:nil];
    
}
-(void)boardLetterTouchedAtIndex:(NSNumber*)index{
//    if (enableRandomSwap) {
//        int index1=[index intValue];
//        int index2=[boardLettersSprites indexOfObject:randomSprite];
//        
//        if (index1!=index2) {
//            [gameController swapTwoLettersAtIndex1:index1 andIndex2:index2];
//            [self swapSpritesAtIndex1:index1 andIndex2:index2];
//            randomSprite.color=((CCSprite*)[boardLettersSprites objectAtIndex:index2]).color;
//            enableRandomSwap=NO;
//        }
//        
//    }else{
//        CCLOG(@"swap");

        if (((swappedIndex1>-1 &&[(CCSprite*)[boardLettersSprites objectAtIndex:swappedIndex1 ]getActionByTag:GameSceneTagSwapAction]==nil)||swappedIndex1==-1) && ((swappedIndex2>-1 &&[(CCSprite*)[boardLettersSprites objectAtIndex:swappedIndex2 ]getActionByTag:GameSceneTagSwapAction]==nil)||swappedIndex2==-1)) {
            
//            CCLOG(@"in if statement");
        
            NSArray* swappedIndexes= [[NSArray alloc]initWithArray:[gameController swapLettersAtTouchedIndex:[index intValue]]];
            if ([swappedIndexes count]!=0) {
                int index1=[[swappedIndexes objectAtIndex:0] intValue];
                
                int index2=[[swappedIndexes objectAtIndex:1] intValue];
                
                [self swapSpritesAtIndex1:index1 andIndex2:index2];
                
                [swappedIndexes release];
                

            }
        }
        
//    }
}

-(void)swapSpritesAtIndex1:(int)index1 andIndex2:(int)index2{
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];
//    CCLOG(@"in swapping method");
    swappedIndex1=index1;
    swappedIndex2=index2;
    CCSprite* swappedSprite1=[boardLettersSprites objectAtIndex:index1];
    CCSprite* swappedSprite2=[boardLettersSprites objectAtIndex:index2];
     
    [boardLettersSprites replaceObjectAtIndex:index1 withObject:swappedSprite2];
    [boardLettersSprites replaceObjectAtIndex:index2 withObject:swappedSprite1];

    CGPoint point1=swappedSprite2.position;
    CGPoint point2=swappedSprite1.position;
    CCMoveTo* move1=[CCMoveTo actionWithDuration:0.2 position:point1];
    move1.tag=GameSceneTagSwapAction;
    CCMoveTo* move2=[CCMoveTo actionWithDuration:0.2 position:point2];
    move2.tag=GameSceneTagSwapAction;
    [swappedSprite1 runAction:move1];
    [swappedSprite2 runAction:move2];

}

-(void)checkIsWordCorrect{  
    NSMutableArray *lettersPlaces=[[NSMutableArray alloc]init];
    for (CCSprite* letterSprite in collectedWord) {
        int row=(letterSprite.position.x-ADJUST_X( kBOARD_LETTERS_X_OFFSET)-(letterSprite.contentSize.width*0.5))/(letterSprite.contentSize.width +kLETTERS_SPACING);
        
        int col=(screenSize.height-letterSprite.position.y-ADJUST_Y(kBOARD_LETTERS_Y_OFFSET))/(letterSprite.contentSize.height+kLETTERS_SPACING);
        
        int index=row+(col*5);
        [lettersPlaces addObject:[NSNumber numberWithInt:index]];
        
    }
    if ([lettersPlaces count]>2) {
        BOOL isWordCorrect= [gameController checkWordWithLettersIndexes:lettersPlaces];
       
        if (isWordCorrect) {
            NSLog(@"correct");
            
            int rowIndex=0;
            
            [self removeSpritesInArray:rightSprites];
            [rightLetters removeAllObjects];
                       
            for (CCSprite* collectedLetter in collectedWord) {
                CCSprite* newSprite=[CCSprite spriteWithSpriteFrame:[collectedLetter displayedFrame]];
                float scale=kCORRECT_WORD_SCALE;
                newSprite.scale=scale;
//                newSprite.color=ccORANGE;
                float xPos=ADJUST_X( kCOLLECTED_WORDS_X_OFFSET)+(newSprite.contentSize.width*0.5*scale)+(newSprite.contentSize.width*rowIndex*scale)+(kCOLLECTED_WORDS_LETTERS_SPACING*rowIndex);
                //            float yPos=screenSize.height-(kCOLLECTED_WORDS_Y_OFFSET+(kCOLLECTED_WORDS_LETTERS_SPACING)+(newSprite.contentSize.height*scale));
                float yPos=ADJUST_Y( kCOLLECTED_WORDS_Y_OFFSET);
                
                newSprite.position=ccp (xPos, yPos);
                if (mustDropAllLetters) {
                    newSprite.color=ccGREEN; 
                }
                [self addChild:newSprite];
                [rightSprites addObject:newSprite];
                [rightLetters addObject:[gameController.randomBoardLetters objectAtIndex:[boardLettersSprites indexOfObject:collectedLetter]]];
              //  NSLog(@"%d",[boardLettersSprites indexOfObject:collectedLetter]);
                
                rowIndex++;
            }
//            if (![self getChildByTag:GameSceneTagDoneButton]) {
//               
//                CCMenuItemSprite* doneItem=[CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"arrow.png"]] selectedSprite:[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"arrow.png"]] target:self selector:@selector(dropSelectedLetters:)];
//                
//                CCMenu *doneButton=[CCMenu menuWithItems:doneItem, nil];
//                doneButton.position=ccp(kDONE_BUTTON_X_POS, kDONE_BUTTON_Y_POS);
//                
//                [self addChild:doneButton z:0 tag:GameSceneTagDoneButton];
//                
//            }
            //        numberOfCorrectWords++;
        }

    }
    [lettersPlaces release];
}
-(void)dropSelectedLetters:(id)sender{
    
    ccColor3B greenColor=ccGREEN;
    NSMutableIndexSet * indexSet=[[NSMutableIndexSet alloc]init];
  //  NSLog(@"right letters: %@",rightLetters);
    int rightLettersIndex=0;
    NSMutableArray* rightLettersWithoutRepeat=[[NSMutableArray alloc]init];
    for (NSString* letter in rightLetters) {
        if (![rightLettersWithoutRepeat containsObject:letter]) {
            [rightLettersWithoutRepeat addObject:letter];
        }
    } 
    
    int rightLettersCountWithoutRepeat=[rightLettersWithoutRepeat count];
    [rightLettersWithoutRepeat release];
    BOOL isLastLettersSet=rightLettersCountWithoutRepeat==[availableLettersSprites count];
    
    for (CCSprite * letter in rightSprites) {
        
       
        if (letter.color.r== greenColor.r&&letter.color.g== greenColor.g&&letter.color.b== greenColor.b) {
            int index=0;

            for (NSString * availableLetter in gameController.availableLetters){
               
                if ([availableLetter isEqualToString:[rightLetters objectAtIndex:rightLettersIndex]]) {
                    if (!mustDropAllLetters ||isLastLettersSet) {
                        [indexSet addIndex:index];
                        break;
                    }else if(mustDropAllLetters ){
                        if (![vowelLetter isEqualToString:@""]&& ![availableLetter isEqualToString:vowelLetter]) {
                            [indexSet addIndex:index];
                            break; 
                        }else if([vowelLetter isEqualToString:@""]){
                            if ([allVowelLetters containsObject:availableLetter]) {
                                vowelLetter=availableLetter;
                                
                                break;
                            }else{
                                [indexSet addIndex:index];
                                break;
                            }

                        }
                    }
                    
                }
                index++;
            }
        }
        
//        [letter removeFromParentAndCleanup:YES];
        rightLettersIndex++;
    }
//    [rightSprites removeAllObjects];
    if ( [rightSprites count]>0) {
        if([indexSet count]>=2||mustDropAllLetters){
            
            [[SimpleAudioEngine sharedEngine]playEffect:@"DownArrow.mp3"];
            
            [self updateScoreWithWordLength:[rightSprites count] andSubmittedLettersCount:[indexSet count]];
            [self removeSpritesInArray:rightSprites];
            [rightLetters removeAllObjects];
            [self moveLettersDownAtIndexes:indexSet];
            if (![vowelLetter isEqualToString:@""]&& !isLastLettersSet) {
                int index=[gameController.availableLetters indexOfObject:vowelLetter];
                CCSprite* vowelLetterSprite=((CCSprite*)[availableLettersSprites objectAtIndex:index]);
                vowelLetterSprite.color=ccRED;
                CCSprite* newSprite=[CCSprite spriteWithSpriteFrame: vowelLetterSprite.displayedFrame ];
                newSprite.position=kVOWEL_LETTER_POS;
                newSprite.color=ccRED;
                if ([self getChildByTag:GameSceneTagVowelLetter]) {
                    [ self removeChildByTag:GameSceneTagVowelLetter cleanup:YES];
                }
                [self addChild:newSprite z:0 tag:GameSceneTagVowelLetter];
            }
            
            //       [[(CCMenuItem*)sender parent] removeFromParentAndCleanup:YES];
        }else if([indexSet count]<2 ){
            
            BlockAlertView* alert=[BlockAlertView alertWithTitle:@"" message:@"You must sumbmit at least 2 letters" andLoadingviewEnabled:NO];
            [alert setCancelButtonWithTitle:@"OK" block:nil];
            [alert show];
            
        }

    }
        [indexSet release];
//    [self setLastTime];
}
//-(void)setLastTime{
//    
//    [lastWordTimeLabel setString:[NSString stringWithFormat:@"%02d: %02d", myTime/60, myTime%60]];
//    myTime=0;
//    totalTime=0;
//    [timerLabel setString:[NSString stringWithFormat:@"%02d: %02d", myTime/60, myTime%60]];
//
//}
-(void)moveLettersDownAtIndexes:(NSMutableIndexSet*)indexSet{
    
    if ([indexSet count]>0) {
        NSArray*movedSprites=[availableLettersSprites objectsAtIndexes:indexSet];
        
//        [droppedLettersSprites addObjectsFromArray:movedSprites];
//        NSLog(@"first index:%d",indexSet.firstIndex);
//        
//        NSLog(@"last index:%d",indexSet.lastIndex);
//        NSLog(@"retain count:%d",indexSet.retainCount);
//        NSLog(@"available images retain count : %d",availableLettersImages.retainCount);
//        NSLog(@"last available image:%@",[availableLettersImages lastObject]);
//        [droppedLettersImages addObjectsFromArray:[availableLettersImages objectsAtIndexes:indexSet]];
        [availableLettersSprites removeObjectsAtIndexes:indexSet];
        [availableLettersImages removeObjectsAtIndexes:indexSet];
        [gameController dropLettersAtIndexSet:(NSIndexSet*)indexSet];
        
//        CGFloat xPos;
//        CGFloat yPos;
        for (CCSprite* letterSprite in movedSprites) {
            
//            xPos=kDROPPED_LETTERS_X_OFFSET+(letterSprite.contentSize.width*0.5)+(letterSprite.contentSize.width*lowerLettersRowIndex)+(kLETTERS_SPACING*lowerLettersRowIndex);
//            yPos=screenSize.height-(kDROPPED_LETTERS_Y_OFFSET+(kLETTERS_SPACING*lowerLettersColIndex)+(letterSprite.contentSize.height*lowerLettersColIndex));
            
            CCMoveTo* move=[CCMoveTo actionWithDuration:1 position:ccp(letterSprite.position.x,0)];
            [letterSprite runAction:move];
            
            CCFadeOut* fadeOut=[CCFadeOut actionWithDuration:1];
            [letterSprite runAction:fadeOut];
//            lowerLettersRowIndex++;
//            
//            if (lowerLettersRowIndex%9==0) {
//                lowerLettersColIndex++;
//                lowerLettersRowIndex=0;
//            }
        }
        //[self performSelector:@selector(drawAvailableLetters) withObject:nil afterDelay:0.5 ];
        [self drawAvailableLettersWithAnimation:NO];
        
        if ([availableLettersSprites count]>1) {
            [self drawBoardWithAnimation:NO];
            
        }else if([availableLettersSprites count]==0 && score>=targetLevelScore){
            [self unscheduleUpdate];
            ((CCMenu*) [self getChildByTag:GameSceneTagButtons]).isTouchEnabled=NO;
            
            self.isTouchEnabled=NO;
            [self schedule:@selector( addBonusWithAnimation:) interval:0.05];
            //set new score
            int oldHighScore=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,gameMode]];
            if (score+myTime>oldHighScore) {
                [[NSUserDefaults standardUserDefaults] setInteger:score+myTime forKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,gameMode]];
                isNewHighScore=YES;
            }
            
            //        [self newGame];
            //        UIAlertView* winAlert=[[UIAlertView alloc]initWithTitle:@"You win" message:@"Play again?" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Yes", nil];
            //        [winAlert show];
            //        [winAlert release];
            NSArray* letters=[[[NSArray alloc]initWithObjects:@"g",@"o",@"o",@"d",@"g",@"a",@"m",@"e", nil] autorelease];
            [self addAliensAnimationWithLettersArray:letters];
//            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[CDAudioManager sharedManager]playBackgroundMusic:@"alien_vision.mp3" loop:NO];
            
            [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:nil selector:nil];
//            [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"alien_vision.mp3" loop:NO];
        }else{
            [self gameOver];
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
    
//    score=score+submittedLetters+bonus;
    score+=bonus;
    
    if(bonus>0){
    
        bonusLabel=[CCLabelBMFont labelWithString:[NSString stringWithFormat: @"+%d",bonus] fntFile:@"score_bitmapfont.fnt"];
        bonusLabel.anchorPoint=ccp(0, 0.5);
        bonusLabel.position=ccp(scoreLabel.position.x,ADJUST_Y( kPANIC_BUTTON_Y_POS));
        [self addChild:bonusLabel z:10];
        
        CCMoveTo* move=[CCMoveTo actionWithDuration:1 position:scoreLabel.position];
        CCFadeOut* fadeout=[CCFadeOut actionWithDuration:1.3];
        bonusLabel.color=ccGREEN;
        [bonusLabel runAction:move];
        [bonusLabel runAction:fadeout];        
        [self performSelector:@selector(updateScoreLabel) withObject:nil afterDelay:1.1];
    }
    
   
    
}
-(void)updateScoreLabel{
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];
    [bonusLabel removeFromParentAndCleanup:YES];
    bonusLabel=nil;
    
}
-(void)gameOver{
    
    if(score<targetLevelScore){
    
        BlockAlertView* alert=[BlockAlertView alertWithTitle:@"" message:@"Create more 4 & 5 letter words to achieve target score" andLoadingviewEnabled:NO];
        [alert addButtonWithTitle:@"OK" block:nil];
        [alert show];
    }
    isGameOver=YES;
    [[CDAudioManager sharedManager]stopBackgroundMusic];
    
    int oldHighScore=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,gameMode]];
    if (score>oldHighScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,gameMode]];
        
        
//        [self showShareAlert];
        
//        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"" message:@"New high score achieved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
    }
    if(score>0){
        [self showShareAlert];
    }
    [self performSelector:@selector(disableTouches) withObject:nil afterDelay:0.05 ];


    
    
//    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Game Over" message:@"You Lose" delegate:self cancelButtonTitle:@"Back" otherButtonTitles: nil];
//    [alert show];
//    [alert release];
    [self unscheduleAllSelectors];
    NSArray* letters=[[[NSArray alloc]initWithObjects:@"g",@"a",@"m",@"e",@"o",@"v",@"e",@"r", nil] autorelease];
    [self addAliensAnimationWithLettersArray:letters];

    
}


-(void)disableTouches{
    self.isTouchEnabled=NO;
    ((CCMenu*)[self getChildByTag:GameSceneTagButtons]).isTouchEnabled=NO;
    
}

-(void)addAliensAnimationWithLettersArray:(NSArray*)letters{
//    CCLOG(@"board array:%@",boardLettersSprites);
//    CCLOG(@"board array count:%d",boardLettersSprites.count );
//    CCLOG(@"board array last obj:%@",[boardLettersSprites lastObject] );
//    CCLOG(@"board array last obj parent:%@",((CCSprite*)[boardLettersSprites lastObject]).parent );
    
    [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
    
    [frameCache  addSpriteFramesWithFile:@"red_letters.plist"];
    
    int index=0;
    bool willFade=NO;
    NSString*imageName=@"alien_square.png";
    NSString* defaultImage=@"alien_square.png";
    int i=0;
    for(CCSprite* letter in boardLettersSprites){
//        letter.color=ccRED;
        CCScaleTo* shrink=[CCScaleTo actionWithDuration:kANIMATION_DURATION scale:0.1];
        CCScaleTo* raise=[CCScaleTo actionWithDuration:kANIMATION_DURATION scale:1];
        
        [letter performSelector:@selector(setDisplayFrame:) withObject:[frameCache spriteFrameByName:defaultImage] afterDelay:kANIMATION_DURATION+0.05];
        switch (index) {
            case 5:
            case 6:
            case 7:
            case 8:
            case 16:
            case 17:
            case 18:
            case 19:
                imageName=[NSString stringWithFormat:@"%@_panic.png",[letters objectAtIndex:i]];
                willFade=YES;
                i++;
                break;
                
            default:
                willFade=NO;
                imageName=defaultImage;
                break;
        }
        CCSequence* sequence;
        if (willFade) {
//            CCFadeOut*fadeOut=[CCFadeOut actionWithDuration:kANIMATION_DURATION*0.5];
//            CCFadeIn*fadeIn=[CCFadeIn actionWithDuration:kANIMATION_DURATION*0.5];
            CCBlink* blink=[CCBlink actionWithDuration:2.5 blinks:5];
            sequence=[CCSequence actions:shrink,raise,blink, nil];
            [letter performSelector:@selector(setDisplayFrame:) withObject:[frameCache spriteFrameByName:imageName] afterDelay:kANIMATION_DURATION*2.25+0.05];
            

        }else{
            sequence=[CCSequence actions:shrink,raise, nil];
        }
        
        
        [letter runAction:sequence];
        
        index++;
    }
}

-(void)addBonusWithAnimation:(ccTime)delta{
    if (myTime>0) {
        score++;
        myTime--;
        [scoreLabel setString:[NSString stringWithFormat: @"%d",score]];
        [timerLabel setString:[NSString stringWithFormat: @"%d",myTime]];
    }else{
    
        [self unschedule:_cmd];
        
        [[CDAudioManager sharedManager]playBackgroundMusic:@"alien.mp3" loop:YES];
        
        [self newGame];
        
//        int oldHighScore=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,gameMode]];
        if (isNewHighScore) {
//            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,gameMode]];
    
//            [self showShareAlert];
//            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"" message:@"New high score achieved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
            
            isNewHighScore=NO;
        }
//        [self unschedule:_cmd];
    }
}


#pragma mark ShareAlert
-(void)showShareAlert{
    [self unscheduleAllSelectors];
    ShareAlertView *alertView = [[ShareAlertView alloc] initShareAlertWithGameMode:gameMode];
    alertView.isRelativeAnchorPoint = YES;
    int highScore;
    if (isNewHighScore) {
        highScore=score+myTime;
        
    }else {
        highScore=score;
       
    }
    alertView.Message=[NSString stringWithFormat:@"%d", highScore];
    NSString* leaderboardCategory;
    switch (gameMode) {
        case GameModeHorizontal:
            leaderboardCategory=kCROSS_STEP_LEADERBOARD_ID;
            break;
        case GameModeVertical:
            leaderboardCategory=kCHA_CHA_LEADERBOARD_ID;
            break;
        case GameModeBoth:
            leaderboardCategory=kALIEN_JIG_LEADERBOARD_ID;
            break;
            
        case GameModeDropAll:
            leaderboardCategory=kHUMANOID_TWIST_LEADERBOARD_ID;
            break;
        default:
            break;
    }
    [gameController submitScore:highScore category:leaderboardCategory];

    
    int totalHighScore=[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeHorizontal]]+[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeVertical]]+[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeDropAll]]+[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeBoth]];
    alertView.SubMessage=[NSString stringWithFormat:@"%d", totalHighScore ];
    
    [self addChild:alertView z:2000 tag:GameSceneTagShareAlert];
    
    
    
    isNewHighScore=NO;
    
}

#pragma mark -
-(void)onEnter{
    
    EventName=[[NSString alloc]init];
    switch (gameMode) {
        case GameModeHorizontal:
            EventName=kGAME_MODE_HORIZONTAL_EVENT;
            break;
        case GameModeVertical:
            EventName=kGAME_MODE_VERTICAL_EVENT;
            break;
            
        case GameModeBoth:
            EventName=kGAME_MODE_BOTH_EVENT;
            break;
            
        case GameModeDropAll:
            EventName=kGAME_MODE_DROPALL_EVENT;
            break;
        default:
            break;
    }
//    [StatisticsCollector logEvent:EventName timed:YES];
    
    
    NSDictionary *parameters = 
    [NSDictionary dictionaryWithObjectsAndKeys:EventName, 
     @"Game Mode", 
     nil];
    [StatisticsCollector logEvent:@"Play New Game" withParameters:parameters timed:YES];
   // [StatisticsCollector logEvent:@"Play New Game" timed:YES];
    
    
   
    
    [super onEnter];
}
-(void)onExit{
    [[CCTouchDispatcher sharedDispatcher]removeDelegate:self];
//    [StatisticsCollector endTimedEvent:EventName withParameters:nil];
    
    NSDictionary *parameters = 
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:levelNum], 
     @"Game Level", 
     nil];

    [StatisticsCollector endTimedEvent:@"Play New Game" withParameters:parameters];
    
     [[CDAudioManager sharedManager]stopBackgroundMusic];
//     [[CDAudioManager sharedManager]playBackgroundMusic:@"alien_vision.mp3" loop:YES];
    [super onExit];
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    [availableLettersImages release];
    [availableLettersSprites release];
    [boardLettersSprites release];
    [collectedWord release];
    
    [rightSprites release];
    [rightLetters release];
    [vowelLetter release];
    [allVowelLetters release];
    
    [EventName release];
    
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
