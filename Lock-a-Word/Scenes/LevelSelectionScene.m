//
//  LevelSelectionScene.m
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "LevelSelectionScene.h"

#import "GameData.h"
#import "GameDataParser.h"

#import "Level.h"
#import "Levels.h"
#import "LevelParser.h"

#import "Chapter.h"
#import "Chapters.h"
#import "ChapterParser.h"

@implementation LevelSelectionScene {
    GameMode gameMode;
    CGRect backButtonRect;
}

@synthesize device;


//+(id)scene {
//    CCScene *scene = [CCScene node];
//    
//    LevelSelectionScene *layer = [LevelSelectionScene node];
//    
//    [scene addChild:layer];
//    
//    return scene;
//}


-(id) initWithGameMode:(GameMode)aGameMode {
    
	if( (self=[super init] )) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.device = @"iPad";
        }
        else {
            self.device = @"iPhone";
        }
        
        
        //Enable Touches
        self.isTouchEnabled=YES;
        // Get Gamemode
        gameMode = aGameMode;
        // Get the screen size
        CGSize size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        CCSprite * backgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        backgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:backgroundImage z:-4];
        
        
        backButtonRect = CGRectMake(.05*size.width, .895*size.height,.4125*size.width/2, .125*size.height/2);
        // Incomplete waiting for logic things     
		
        
        int smallFont = [CCDirector sharedDirector].winSize.height / 12; 
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
        
        
        CCMenu *levelMenu = [CCMenu menuWithItems: nil]; 
        NSMutableArray *overlay = [NSMutableArray new];
        
        Levels *selectedLevels = [LevelParser loadLevelsForChapter:gameData.selectedChapter];
        NSString *normal =   [NSString stringWithFormat:@"%@-Normal-%@.png", selectedChapterName, self.device];
        NSString *selected = [NSString stringWithFormat:@"%@-Selected-%@.png", selectedChapterName, self.device];
        
         for (Level *level in selectedLevels.levels) {
             
             CCMenuItemImage *item = [CCMenuItemImage itemFromNormalImage:normal
                                                            selectedImage:selected
                                                                   target:self 
                                                                 selector:@selector(onPlay:)];
             [item setTag:level.number]; // note the number in a tag for later usage
             
             [item setIsEnabled:level.unlocked];  // ensure locked levels are inaccessible
             [levelMenu addChild:item];
             
             if (level.stars) {
                 NSString *stars = [[NSNumber numberWithInt:level.stars] stringValue];
                 NSString *overlayImage = [NSString stringWithFormat:@"%@Star-Normal-%@.png",stars, self.device];
                 CCSprite *overlaySprite = [CCSprite spriteWithFile:overlayImage];
                 [overlaySprite setTag:level.number];
                 [overlay addObject:overlaySprite];

             }

             
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
        CCLayer *labels = [[CCLayer alloc] init];
        
        for (int i=0 ; i<[selectedLevels.levels count]; i++) {
            Level *level = [selectedLevels.levels objectAtIndex:i];
            CCMenuItem *item = [levelMenu.children objectAtIndex:i];
//        }
//        for (CCMenuItem *item in levelMenu.children) {
            
            // create a label for every level
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",level.name] 
                                                   fontName:@"Marker Felt" 
                                                   fontSize:smallFont];
            
            [label setAnchorPoint:item.anchorPoint];
            [label setPosition:item.position];
            [labels addChild:label];
            
            
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
        [labels setAnchorPoint:levelMenu.anchorPoint];
        [overlays setPosition:levelMenu.position];
        [labels setPosition:levelMenu.position];
        [self addChild:overlays];
        [self addChild:labels];
        [overlays release];
        [labels release];
        
	}
	return self;
}



-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];
    if (CGRectContainsPoint(backButtonRect, location)) {
        [[CCDirector sharedDirector] popScene];
    }
    CCLOG(@"Touches Happens !!");
}


- (void) onPlay: (CCMenuItemImage*) sender {
    
    // the selected level is determined by the tag in the menu item 
    int selectedLevel = sender.tag;
    
    // store the selected level in GameData
    GameData *gameData = [GameDataParser loadData];
    gameData.selectedLevel = selectedLevel;
    [GameDataParser saveData:gameData];
    
    // load the game scene
    //    [SceneManager goGameScene];
    
//    [[CCDirector sharedDirector] replaceScene: [GameScene scene]];
    
    
}

@end
