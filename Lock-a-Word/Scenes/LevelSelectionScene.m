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
//        NSString *normal =   [NSString stringWithFormat:@"%@-Normal-%@.png", selectedChapterName, self.device];
//        NSString *selected = [NSString stringWithFormat:@"%@-Selected-%@.png", selectedChapterName, self.device];
        
         for (Level *level in selectedLevels.levels) {
             NSString *normal =   [NSString stringWithFormat:@"%@.png", level.name];
             NSString *selected = [NSString stringWithFormat:@"%@.png", level.name];
             
             CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:normal
                                                            selectedImage:selected
                                                                   target:self 
                                                                 selector:@selector(onPlay:)];
             item.rotation=-10;
             [item setTag:level.number]; // note the number in a tag for later usage
             
//             // This will change each level sprite color in RGB
//             switch (selectedChapter) {
//                 case 1:
//                     item.color=ccc3(228,228,228) ;
//                     break;
//                 case 2:
////                     item.color=ccc3(216,74,2) ;
//                     item.color=ccc3(227,117,61) ;
//                     break;
//                 case 3:
////                     item.color=ccc3(118,128,137) ;
//                     item.color=ccc3(160,160,160) ;
//                     break;
//                 case 4:
//                     item.color=ccc3(252,141,0) ;
//                     break;                     
//                 default:
//                     break;
//             }   

             [item setIsEnabled:level.unlocked];  // ensure locked levels are inaccessible
             [levelMenu addChild:item];
//             level.stars = arc4random()%3;
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
//        CCLayer *labels = [[CCLayer alloc] init];
        
        for (int i=0 ; i<[selectedLevels.levels count]; i++) {
//            Level *level = [selectedLevels.levels objectAtIndex:i];
            CCMenuItem *item = [levelMenu.children objectAtIndex:i];
            
//            CCLabelTTF *label = [CCLabelTTF labelWithString:[[NSString stringWithFormat:@"%@",level.name]uppercaseString]
//                                                   fontName:@"Marker Felt" 
//                                                   fontSize:smallFont];
//            
//            [label setAnchorPoint:item.anchorPoint];
//            [label setPosition:item.position];
//            [labels addChild:label];
            
            
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
//        [labels setAnchorPoint:levelMenu.anchorPoint];
        [overlays setPosition:levelMenu.position];
//        [labels setPosition:levelMenu.position];
        [self addChild:overlays];
//        [self addChild:labels];
        [overlay release];
        [overlays release];
//        [labels release];
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
        [[CCDirector sharedDirector] replaceScene:[GameModesScene scene]];
        
    }
}


- (void) onPlay: (CCMenuItemImage*) sender {
    
    // the selected level is determined by the tag in the menu item 
    int selectedLevel = sender.tag;
    
    // store the selected level in GameData
    [controller selectLevel:selectedLevel];
    
    // load the game scene
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
    
    
}

@end
