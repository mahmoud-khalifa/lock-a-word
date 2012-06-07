//
//  MainMenuScene.m
//  TemplateProject
//
//  Created by Log n Labs on 12/13/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "MainMenuScene.h"
#import "GameConfig.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
//#import "StatisticsCollector.h"
@interface MainMenuScene (PrivateMethods)
-(void)createMenu;
//-(void)addHighScores;
-(void)horizontalModeItemTouched:(id)sender;
-(void)verticalModeItemTouched:(id)sender;
-(void)bothItemTouched:(id)sender;
-(void)dropAllItemTouched:(id)sender;
-(void)goToGameSceneWithMode:(GameModes)mode andMustDropAllLetters:(BOOL)dropAll;

@end

// MainMenuScene implementation
@implementation MainMenuScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	
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
	
        NSString* bgImage=@"panic_setting.png";
        if (IS_IPAD()) {
            bgImage=@"panic_setting_ipad.png";
        }
        CCSprite *bgSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:bgImage]];
        bgSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
        [self addChild:bgSprite];
        [self createMenu];
        
        self.isTouchEnabled=YES;
        
//        [self addHighScores];

	}
	return self;
}


-(void)createMenu{
    
    
    CCSpriteFrameCache*frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    
    [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
    
    CCSprite* horizontal = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"horizontal.png"]];
    CCSprite* horizontal_Selected  = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"horizontal.png"]];
    horizontal_Selected.color=ccGRAY;


    
    CCMenuItemSprite* horizontalModeItem = [CCMenuItemSprite itemFromNormalSprite:horizontal selectedSprite:horizontal_Selected target:self selector:@selector(horizontalModeItemTouched:)];

  //  horizontalModeItem.position=ccp(screenSize.width*0.5, 320);
    
    CCSprite* vertical = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"vertical.png"]];
    CCSprite* vertical_Selected  = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"vertical.png"]];
    vertical_Selected.color=ccGRAY;
    
    CCMenuItemSprite* verticalModeItem = [CCMenuItemSprite itemFromNormalSprite:vertical selectedSprite:vertical_Selected target:self selector:@selector(verticalModeItemTouched:)];
    
   // verticalModeItem.position=ccp(screenSize.width*0.5, 230);
    
    CCSprite* both = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"both.png"]];
    CCSprite* both_Selected  = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"both.png"]];
    
    
    CCMenuItemSprite* bothItem = [CCMenuItemSprite itemFromNormalSprite:both selectedSprite:both_Selected target:self selector:@selector(bothItemTouched:)];
    both_Selected.color=ccGRAY;
   // bothItem.position=ccp(screenSize.width*0.5, 140);

    
    
    CCSprite* dropAll = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"drop_all.png"]];
    CCSprite* dropAll_Selected  = [CCSprite spriteWithSpriteFrame:[frameCache spriteFrameByName:@"drop_all.png"]];
    
    
    CCMenuItemSprite* dropAllItem = [CCMenuItemSprite itemFromNormalSprite:dropAll selectedSprite:dropAll_Selected target:self selector:@selector(dropAllItemTouched:)];
    dropAll_Selected.color=ccGRAY;
    // bothItem.position=ccp(screenSize.width*0.5, 140);
    
    
    //leaderboard button:
    CCSprite* leaderboard = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"gamecenter_icon.png"]];
    CCSprite* leaderboard_Selected  = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"gamecenter_icon.png"]];
    leaderboard_Selected.color=ccGRAY;
    
    CCMenuItemSprite* leaderboardItem = [CCMenuItemSprite itemFromNormalSprite:leaderboard selectedSprite:leaderboard_Selected target:self selector:@selector(leaderboardItemTouched:)];

    
    // create the menu using the items
    CCMenu* mainMenu = [CCMenu menuWithItems: horizontalModeItem,verticalModeItem,bothItem,dropAllItem,leaderboardItem,nil];
    
    
    mainMenu.position = CGPointMake(screenSize.width*0.5, screenSize.height*0.5);
    [mainMenu alignItemsVerticallyWithPadding: ADJUST_DOUBLE(35)];
   // mainMenu.anchorPoint=CGPointMake(0,0 );
    
    [self addChild:mainMenu];
    
//    //leaderboard button:
//    CCSprite* leaderboard = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"gamecenter_icon.png"]];
//    CCSprite* leaderboard_Selected  = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:@"gamecenter_icon.png"]];
//    leaderboard_Selected.color=ccGRAY;
//    
//    CCMenuItemSprite* leaderboardItem = [CCMenuItemSprite itemFromNormalSprite:leaderboard selectedSprite:leaderboard_Selected target:self selector:@selector(leaderboardItemTouched:)];
//    leaderboardItem.position=ccp (screenSize.width*0.5,ADJUST_Y( 35));
//    leaderboardItem.anchorPoint=ccp (0.5,0);
//    CCMenu* leaderboardButton=[CCMenu menuWithItems:leaderboardItem, nil];
//    leaderboardButton.anchorPoint=ccp (0,0);
//    leaderboardButton.position=ccp (0,0);
//    leaderboardButton.scale=0.8;
//    [self addChild:leaderboardButton];

}


//-(void)addHighScores{
//
//    horizontalModeHighScore=[CCLabelBMFont labelWithString:@"" fntFile:@"high_score_bitmapfont.fnt"];
//    horizontalModeHighScore.anchorPoint=ccp(0, 0.5);
//    horizontalModeHighScore.position=ADJUST_XY(160, (350+43));
//    [self addChild:horizontalModeHighScore];
//    
//    verticalModeHighScore=[CCLabelBMFont labelWithString:@"" fntFile:@"high_score_bitmapfont.fnt"];
//    verticalModeHighScore.anchorPoint=ccp(0, 0.5);
//    verticalModeHighScore.position=ADJUST_XY(160, (250+43));
//    [self addChild:verticalModeHighScore];
//    
//    bothModeHighScore=[CCLabelBMFont labelWithString:@"" fntFile:@"high_score_bitmapfont.fnt"];
//    bothModeHighScore.anchorPoint=ccp(0, 0.5);
//    bothModeHighScore.position=ADJUST_XY(160, (150+43));
//    [self addChild:bothModeHighScore];
//    
//    dropAllModeHighScore=[CCLabelBMFont labelWithString:@"" fntFile:@"high_score_bitmapfont.fnt"];
//    dropAllModeHighScore.anchorPoint=ccp(0, 0.5);
//    dropAllModeHighScore.position=ADJUST_XY(160, (50+43));
//    [self addChild:dropAllModeHighScore];
//    
//    TotalScore=[CCLabelBMFont labelWithString:@"" fntFile:@"high_score_bitmapfont.fnt"];
//   
//    TotalScore.position=CGPointMake(screenSize.width*0.5, ADJUST_Y(20));
//    [self addChild:TotalScore];
//    
//}


-(void)horizontalModeItemTouched:(id)sender{
//    NSDictionary *parameters = 
//    [NSDictionary dictionaryWithObjectsAndKeys:@"Hovering Cross-Step", 
//     @"Game Mode", 
//     nil];
//    [StatisticsCollector logEvent:@"Play New Game" withParameters:parameters];
//    [StatisticsCollector logEvent:@"Hovering Cross-Step"];
    [self goToGameSceneWithMode:GameModeHorizontal andMustDropAllLetters:NO];
}


-(void)verticalModeItemTouched:(id)sender{
//    NSDictionary *parameters = 
//    [NSDictionary dictionaryWithObjectsAndKeys:@"Vertical Cha-Cha", 
//     @"Game Mode", 
//     nil];
//    [StatisticsCollector logEvent:@"Play New Game" withParameters:parameters];
//    [StatisticsCollector logEvent:@"Vertical Cha-Cha"];
    [self goToGameSceneWithMode:GameModeVertical andMustDropAllLetters:NO];
}

-(void)bothItemTouched:(id)sender{
//    NSDictionary *parameters = 
//    [NSDictionary dictionaryWithObjectsAndKeys:@"Alien Jeg", 
//     @"Game Mode", 
//     nil];
//    [StatisticsCollector logEvent:@"Play New Game" withParameters:parameters];
//    [StatisticsCollector logEvent:@"Alien Jeg"];
    [self goToGameSceneWithMode:GameModeBoth andMustDropAllLetters:NO];
}


-(void)dropAllItemTouched:(id)sender{
//    NSDictionary *parameters = 
//    [NSDictionary dictionaryWithObjectsAndKeys:@"Drop All", 
//     @"Game Mode", 
//     nil];
//    [StatisticsCollector logEvent:@"Play New Game" withParameters:parameters];
//    [StatisticsCollector logEvent:@"Drop All"];
    [self goToGameSceneWithMode:GameModeDropAll andMustDropAllLetters:YES];
}

-(void)goToGameSceneWithMode:(GameModes)mode andMustDropAllLetters:(BOOL)dropAll{
    [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];
    [[CCDirector sharedDirector]pushScene:(CCScene*)[[[GameScene alloc]init]autorelease]];
}

-(void)leaderboardItemTouched:(id)sender{

    [[Controller sharedController] showLeaderBoardWithCategory:[[NSUserDefaults standardUserDefaults]objectForKey:kLAST_PLAYED_GAME_MODE_KEY]];
}
#pragma Tracking Touches
-(void) registerWithTouchDispatcher{ 
    [[CCTouchDispatcher sharedDispatcher]addTargetedDelegate:self priority:-1 swallowsTouches:YES];
    
}
-(BOOL) ccTouchBegan:(UITouch *)touch  withEvent:(UIEvent *)event
{
    
//    startTouchLocation = [touch locationInView:[touch view]]; 
//    startTouchLocation = [[CCDirector sharedDirector] convertToGL:startTouchLocation]; 
//    
//    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
    
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
//    CGPoint location= [touch locationInView:[touch view]];
//    location = [[CCDirector sharedDirector] convertToGL:location]; 
//    
//    if (location.x<startTouchLocation.x-40) {
//        [[CCDirector sharedDirector]popScene];
//        
//    }
    
}

-(void)onExit{
    [[CCTouchDispatcher sharedDispatcher]removeDelegate:self];
    [super onExit];
}

-(void)onEnter{

//    int score_horizontalMode=[[NSUserDefaults standardUserDefaults]integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeHorizontal]];
//    int score_verticalMode=[[NSUserDefaults standardUserDefaults]integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeVertical]];
//    int score_bothMode=[[NSUserDefaults standardUserDefaults]integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeBoth]];
//    int score_dropAllMode=[[NSUserDefaults standardUserDefaults]integerForKey:[NSString stringWithFormat:@"%@_%d",kHIGH_SCORE_KEY,GameModeDropAll]];
//    
//    int totalScore=score_horizontalMode+score_verticalMode+score_bothMode+score_dropAllMode;
//    
//    NSArray *nums=[NSArray arrayWithObjects:[NSNumber numberWithInt:score_horizontalMode],[NSNumber numberWithInt:score_verticalMode],[NSNumber numberWithInt:score_bothMode],[NSNumber numberWithInt:score_dropAllMode], nil];
//    
//    int maxNum=[[nums valueForKeyPath:@"@max.intValue"] intValue];
//    if (maxNum!=0) {
//        if (score_horizontalMode==maxNum) {
//            horizontalModeHighScore.color=ccGREEN;
//        }
//        if (score_verticalMode==maxNum) {
//            verticalModeHighScore.color=ccGREEN;
//        }
//        if (score_bothMode==maxNum) {
//            bothModeHighScore.color=ccGREEN;
//        }
//        if (score_dropAllMode==maxNum) {
//            dropAllModeHighScore.color=ccGREEN;
//        }
//    }
//       
//    [horizontalModeHighScore setString:[NSString stringWithFormat:@"HIGH SCORE:%d",score_horizontalMode]];
//    [verticalModeHighScore setString:[NSString stringWithFormat:@"HIGH SCORE:%d",score_verticalMode]];
//    [bothModeHighScore setString:[NSString stringWithFormat:@"HIGH SCORE:%d",score_bothMode]];
//    [dropAllModeHighScore setString:[NSString stringWithFormat:@"HIGH SCORE:%d",score_dropAllMode]];
//    [TotalScore setString:[NSString stringWithFormat:@"TOTAL SCORE:%d",totalScore]];
//    
    [super onEnter];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
