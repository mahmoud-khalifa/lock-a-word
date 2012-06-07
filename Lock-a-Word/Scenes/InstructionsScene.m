//
//  InstructionsScene.m
//  Word9
//
//  Created by Log n Labs on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "InstructionsScene.h"
#import "GameConfig.h"
#import "MainMenuScene.h"

@implementation InstructionsScene
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	InstructionsScene *layer = [InstructionsScene node];
	
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
        NSString* bgImage=@"your_mission_bg.png";
        if (IS_IPAD()) {
            bgImage=@"your_mission_bg_ipad.png";
        }
        CCSprite* bgSprite=[CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache]addImage:bgImage]];
        bgSprite.position=ccp(screenSize.width*0.5, screenSize.height*0.5);
        [self addChild: bgSprite];
        self.isTouchEnabled=YES;
        
//        // touch to continue label
//        CCLabelBMFont* touch = [CCLabelBMFont labelWithString:@"tap screen to play" fntFile:@"start_game_bitmapfont.fnt"];
//        touch.position = CGPointMake(screenSize.width / 2, 20);
//        [self addChild:touch z:100 tag:101];
//        
//        // did you try turning it off and on again?
//        CCBlink* blink = [CCBlink actionWithDuration:10 blinks:20];
//        CCRepeatForever* repeatBlink = [CCRepeatForever actionWithAction:blink];
//        [touch runAction:repeatBlink];
    }
    
	return self;
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
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{

    
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    
//    CGPoint location= [touch locationInView:[touch view]];
//    location = [[CCDirector sharedDirector] convertToGL:location]; 
//    
//    if (location.x>startTouchLocation.x+40) {
        [[CCDirector sharedDirector]pushScene:[MainMenuScene scene]];

//    }

}

-(void)onExit{
    [[CCTouchDispatcher sharedDispatcher]removeDelegate:self];
    [super onExit];
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
