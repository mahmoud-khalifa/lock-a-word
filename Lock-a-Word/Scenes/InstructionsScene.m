//
//  InstructionsScene.m
//  Lock-a-Word
//
//  Created by Mohamed  Saleh on 8/4/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import "InstructionsScene.h"


//This is to define our BackButtonRect
#import "GameConfig.h"

@interface InstructionsScene()
{
   CGSize size;
   CCSprite *backButton;
}

@end

@implementation InstructionsScene

// Helper class method that creates a Scene with the MainMenuScene as the only child.
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
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        self.isTouchEnabled=YES;
		
        // Get the screen size
        size =[[CCDirector sharedDirector] winSize];
        
        // Creating an entry background image
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * InstructionbackgroundImage = [CCSprite spriteWithFile:@"instructions_bg.png"];
        InstructionbackgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:InstructionbackgroundImage];
        
	}
	return self;
}


// Implementing The Back Buttton

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];     
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    // Back button tapped
    if (CGRectContainsPoint(backButtonRect, location)) {
        [[CCDirector sharedDirector] popScene];
    }
}
- (void)onExit {
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    //    [[CDAudioManager sharedManager]stopBackgroundMusic];
    [super onExit];
}
@end
