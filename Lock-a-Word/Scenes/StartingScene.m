//
//  StartingScene.m
//  Word9
//
//  Created by Log n Labs on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StartingScene.h"
#import "GameConfig.h"
#import "MainMenuScene.h"
#import "SimpleAudioEngine.h"
#import "GameScene.h"

@implementation StartingScene
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StartingScene *layer = [StartingScene node];
	
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
        
        NSString* bgImage;//=@"start_screen.png";
        if (IS_IPAD()) {
            bgImage=@"Default-Portrait.png";//@"start_screen_ipad.png";
        }else {
            if( [[CCDirector sharedDirector] enableRetinaDisplay:YES] ){//retina
                bgImage=@"Default@2x.png";
            }else {
                bgImage=@"Default.png";
            }
        }
        
        CCSprite* bgSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:bgImage]];
        bgSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
        
        [self addChild: bgSprite];
        self.isTouchEnabled=YES;
        
//        CCLabelBMFont* loadingLabel=[CCLabelBMFont labelWithString:@"Loading..." fntFile:@"loading_bitmapfont.fnt"];
//        loadingLabel.position=ccp(screenSize.width*0.5,40);
//        [self addChild:loadingLabel z:1 tag:kLOADING_LABEL_TAG];
        
//        // touch to continue label
//        CCLabelBMFont* touch = [CCLabelBMFont labelWithString:@"tap screen to continue" fntFile:@"start_game_bitmapfont.fnt"];
//        touch.position = CGPointMake(screenSize.width / 2, 60);
//        [self addChild:touch z:100 tag:101];
//        
//        // did you try turning it off and on again?
//        CCBlink* blink = [CCBlink actionWithDuration:10 blinks:20];
//        CCRepeatForever* repeatBlink = [CCRepeatForever actionWithAction:blink];
//        [touch runAction:repeatBlink];
        
//        
//        
        CCSpriteFrameCache*frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        
        
        [frameCache  addSpriteFramesWithFile:@"game_texture.plist"];
        [frameCache  addSpriteFramesWithFile:@"normal_letters.plist"];
        [frameCache  addSpriteFramesWithFile:@"red_letters.plist"];
        [frameCache  addSpriteFramesWithFile:@"small_letters.plist"];
        
        
        
        // load resources
		ResourcesLoader *loader = [ResourcesLoader sharedLoader];
		NSArray *extensions = [NSArray arrayWithObjects:@"png", @"wav",@"mp3", nil];
		
		for (NSString *extension in extensions) {
			NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
			for (NSString *filename in paths) {
                filename = [[filename componentsSeparatedByString:@"/"] lastObject];
                if( [filename rangeOfString:@"-hd"].location==NSNotFound &&[filename rangeOfString:@"@2x"].location==NSNotFound){
                    //                    if (![filename isEqualToString:@"fuse-anim.png"]&&![filename isEqualToString:@"bullet_hole.png"]&& ![filename isEqualToString:@"pu.png"]) {
                    
                    [loader addResources:filename, nil];
                    //                    }
                }
				
			}
		}

		// load it async
//		[loader loadResources:self];
        
        
        [self addTapSprite];
      
    }
    
	return self;
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if ([self getChildByTag:kTAP_SCREEN_SPRITE_TAG]) {
//        [[CCDirector sharedDirector]pushScene:[MainMenuScene scene]];
        [[CCDirector sharedDirector]pushScene:(CCScene*)[[[GameScene alloc]init]autorelease]];
        [[SimpleAudioEngine sharedEngine]playEffect:@"LetterButton.mp3"];

    }
 
}


#pragma mark ResourceLoader delegate
- (void) didReachProgressMark:(CGFloat)progressPercentage
{
    
	if (progressPercentage == 1.0f) {
        
//        [self removeChildByTag:kLOADING_LABEL_TAG cleanup:YES];
        
        [self addTapSprite];
	}
    
}
-(void)addTapSprite{
    NSString * tapScreenImage=@"tap_screen.png";
    CCSprite* tapSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:tapScreenImage]];
    if (IS_IPAD()) {
        tapSprite.scaleX=768.0f/640.0f;
        
    }
    tapSprite.position=ccp(screenSize.width*0.5, ADJUST_DOUBLE(42));
    [self addChild:tapSprite z:1 tag:kTAP_SCREEN_SPRITE_TAG];

    
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
