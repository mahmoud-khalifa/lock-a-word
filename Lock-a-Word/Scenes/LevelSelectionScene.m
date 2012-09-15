//
//  LevelSelectionScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "LevelSelectionScene.h"
#import "GameScene.h"
#import "GameModesScene.h"
#import "SimpleAudioEngine.h"

#import "GameConfig.h"

#import "GameData.h"
#import "GameDataParser.h"

#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"

#import "Chapter.h"
#import "Chapters.h"
#import "ChapterParser.h"

@implementation LevelSelectionScene {
    Controller *controller;
}

@synthesize device;


+(id)scene {
    CCScene *scene = [CCScene node];
    
    LevelSelectionScene *layer = [LevelSelectionScene node];
    
    [scene addChild:layer];
    
    return scene;
}


-(id) init{
    
	if( (self=[super init] )) {
        
        // get shared controller
        controller = [Controller sharedController];
        
        self.device = (IS_IPAD() == YES) ?  @"iPad" : @"iPhone";
        
        //Enable Touches
        self.isTouchEnabled=YES;
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"clean_bg.png"];
        backgroundImage.position =ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:backgroundImage z:-4];      
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
            
		       
        GameData *gameData = [GameDataParser loadData];        
        int selectedChapter = gameData.selectedChapter;
        
        
        // Read in selected chapter name (use to load custom background later):
        NSString *selectedChapterName = nil;        
        Chapters *selectedChapters = [ChapterParser loadData];
        for (Chapter *chapter in selectedChapters.chapters) {            
            if ([[NSNumber numberWithInt:chapter.number] intValue] == selectedChapter) {
                CCLOG(@"Selected Chapter is %@ (ie: number %i)", chapter.name, chapter.number);
                selectedChapterName = chapter.name;
            }
        }
        
        // This is for the Trophy image
        trophyImage = [CCSprite spriteWithSpriteFrameName:@"board_trophy.png"];
                
        boardTrophyName = [NSString stringWithFormat:@"board_trophy_%d.png", controller.currentGameMode];
        boardTrophy = [CCSprite spriteWithSpriteFrameName:boardTrophyName];
        // This is for positioning the trophy in Ipad version and in Iphone  
        if (!IS_IPAD()) {
            trophyImage.position = ADJUST_XY(250, 436);
            boardTrophy.position = ADJUST_XY(250, 426);
        } else {
            trophyImage.position = ccp(.78*screenSize.width, .898*screenSize.height);
            boardTrophy.position = ccp(.78*screenSize.width, .876*screenSize.height);
        }
        
        [self addChild:trophyImage];
        [self addChild:boardTrophy];
        
        CCMenu *levelMenu = [CCMenu menuWithItems: nil]; 
        NSMutableArray *overlay = [NSMutableArray new];
        
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        
         for (Level *level in selectedLevels.levels) {
             NSString *normal =   [NSString stringWithFormat:@"%@.png", level.name];
             
             CCMenuItemImage *item = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:normal] 
                                                            selectedSprite:[CCSprite spriteWithSpriteFrameName:normal]
                                                                   target:self 
                                                                 selector:@selector(onPlay:)];
             item.rotation=-10;
             [item setTag:level.number]; // note the number in a tag for later usage

             [item setIsEnabled:level.unlocked];  // ensure locked levels are inaccessible
             [levelMenu addChild:item];
//             if (level.stars) {
                 NSString *stars = [[NSNumber numberWithInt:level.stars] stringValue];
                 NSString *overlayImage = [NSString stringWithFormat:@"%@Star-Normal-%@.png",stars, self.device];
                 CCSprite *overlaySprite = [CCSprite spriteWithFile:overlayImage];
                 [overlaySprite setTag:level.number];
                 [overlay addObject:overlaySprite];

//             }
             
         }
        
        [levelMenu alignItemsInColumns:
         [NSNumber numberWithInt:4],
         [NSNumber numberWithInt:4],
         [NSNumber numberWithInt:4],
         [NSNumber numberWithInt:4],
         [NSNumber numberWithInt:4],
         nil]; 
        
        [self addChild:levelMenu z:-3];
        
        CCLayer *overlays = [[CCLayer alloc] init];
        
        for (int i=0 ; i<[selectedLevels.levels count]; i++) {
            CCMenuItem *item = [levelMenu.children objectAtIndex:i];
            // set position of overlay sprites
            
            for (CCSprite *overlaySprite in overlay) {
                if (overlaySprite.tag == item.tag) {
                    [overlaySprite setAnchorPoint:item.anchorPoint];
                    [overlaySprite setPosition:item.position];
                    [overlays addChild:overlaySprite];
                }
            }
        }


        // Put the overlays and labels layers on the screen at the same position as the levelMenu
        
        [overlays setAnchorPoint:levelMenu.anchorPoint];
        [overlays setPosition:levelMenu.position];
        [self addChild:overlays];
        [overlay release];
        [overlays release];
        [gameData release];
	}
	return self;
}



-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];

    // Back button tapped
    if (CGRectContainsPoint(backButtonRect, location)) {
        [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
        
        [[CCDirector sharedDirector] replaceScene:[GameModesScene scene]];
    }
}


- (void) onPlay: (CCMenuItemImage*) sender {
    
    [[SimpleAudioEngine sharedEngine]playEffect:@"Button.mp3"];
    
    [self performSelector:@selector(onPlay2:) withObject:sender afterDelay:0.6];
    
}

- (void) onPlay2: (CCMenuItemImage*) sender {
    
//    // the selected level is determined by the tag in the menu item 
//    int selectedLevel = sender.tag;
//    
//    // store the selected level in GameData
//    [controller selectLevel:selectedLevel];
//    
//    // load the game scene
//    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    
    if ([controller isGameModesUnlocked]) {
        int selectedLevel = sender.tag;
        [controller selectLevel:selectedLevel];
        [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    }else {
        BlockAlertView *alertView=[BlockAlertView alertWithTitle:@"Upgrade" message:@"Do you want to upgrade to full version?" andLoadingviewEnabled:NO];
        [alertView addButtonWithTitle:@"Upgrade" block:^{
            [controller unlockAllGameModes];
        }];
        [alertView addButtonWithTitle:@"No" block:nil];
        
        [alertView show];
    }
    
}

@end
