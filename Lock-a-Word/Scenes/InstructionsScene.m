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
   UITextView * description;
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
        CCSprite * InstructionbackgroundImage = [CCSprite spriteWithFile:@"board_bg.png"];
        InstructionbackgroundImage.position =ccp(size.width/2, size.height/2);
        [self addChild:InstructionbackgroundImage];
        
        //Make a CCLabelTFF
//        CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Instructions" fontName:@"Arial" fontSize:25];
//        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"The object of this game is to create a 5 letter word in each of the 5 rows." fontName:@"Arial" fontSize:25];
//         CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"* Select the next “available” letter generated in one of the 5 rows or in the spare letter row (bottom of screen)." fontName:@"Arial" fontSize:25];
//         CCLabelTTF *label4 = [CCLabelTTF labelWithString:@"* Any spare letter can be used at any time. Select the “available” letter to position it in that same row. " fontName:@"Arial" fontSize:25];
//        CCLabelTTF *label5 = [CCLabelTTF labelWithString:@"* Select any unlocked letter to move it into place." fontName:@"Arial" fontSize:25];
//        CCLabelTTF *label6 = [CCLabelTTF labelWithString:@" * If a 5 letter word is not possible, create/ eliminate 3 & 4 letter words to clear space. * When a 3 & 4 letter word is created,SWIPE across the word and if valid it will be eliminated." fontName:@"Arial" fontSize:25];
        
        
//        text= [[UITextView alloc] initWithFrame:CGRectMake(0,backButtonRect.size.height, 320, 480)];
//        text.text=@"Instructions\nThe object of this game is to create a 5 letter word in each of the 5 rows.\n* Select the next“available” letter generated in one of the 5 rows or in the spare letter row (bottom of screen).\n* Any spare letter can be used at any time. Select the “available” letter to position it in that same row.\n *Select any unlocked letter to move it into place.\n * If a 5 letter word is not possible, create/ eliminate 3 & 4 letter words to clear space.\n* When a 3 & 4 letter word is created,SWIPE across the word and if valid it will be eliminated.\n* To change your selection, select any letter(in the selected word) before 2 seconds to keep it.\n* When a valid 5 letter word is assembled then it will be LOCKED in.\n*All words must be readable (left to right only).\n * In trophy/level selections (Bronze, Silver & Gold), a number of chosen letters will be locked in specific positions when the game starts.\n* To achieve STARS, complete game using the lowest number of letters.\nHAVE FUN, GO PLAY !!!";
//        text.backgroundColor= [UIColor clearColor];
//        text.font=[UIFont fontWithName:@"Arial" size:15];
//        text.textColor=[UIColor whiteColor];
//        text.textAlignment=UITextAlignmentCenter ;
//        text.editable=NO;
//        text.userInteractionEnabled=NO;
//       [[[CCDirector sharedDirector] view] addSubview:text]; 
        
        
        
//        CCMenuItemFont *label1=[CCMenuItemFont itemWithString:@"Instructions" ];
//        CCMenuItemFont *label2=[CCMenuItemFont itemWithString:@"The object of this game is to create a 5 letter word in each of the 5 rows."];
//        CCMenuItemFont *label3=[CCMenuItemFont itemWithString:@"* Select the next “available” letter generated in one of the 5 rows or in the spare letter row (bottom of screen)." ];
//        CCMenuItemFont *label4=[CCMenuItemFont itemWithString:@"* Any spare letter can be used at any time. \n Select the “available” letter to position it in that same row." ];
//        CCMenuItemFont *label5=[CCMenuItemFont itemWithString:@"* To change your selection, select any letter." ];
//        CCMenuItemFont *label6=[CCMenuItemFont itemWithString:@"* When a valid 5 letter word is assembled then it will be LOCKED in." ];
//        CCMenuItemFont *label7=[CCMenuItemFont itemWithString:@"* All words must be readable (left to right only)." ];
//        CCMenuItemFont *label8=[CCMenuItemFont itemWithString:@"* In trophy/level selections (Bronze, Silver & Gold), \n a number of chosen letters will be locked in specific positions when the game starts." ];
//        
//        
//        label1.fontSize=30;
//        label2.fontSize=10;
//        label3.fontSize=10;
//        label4.fontSize=10;
//        label5.fontSize=10;
//        label6.fontSize=10;
//        label7.fontSize=10;
//        label8.fontSize=10;
//        
//        // Adding items to the menu
//        CCMenu *Instructions = [CCMenu menuWithItems:label1,label2,label3,label4,label5,label6,label7,label8,nil];        
//        [Instructions alignItemsVerticallyWithPadding:0];
//        Instructions.position=ccp(screenSize.width/2,screenSize.height/2 - (.380 *screenSize.height/2));   
//        [self addChild:Instructions];

//                              (in the selected word) before 2 seconds to keep it. 
//                              * In trophy/level selections (Bronze, Silver & Gold), a number of chosen letters will be locked in specific positions when the game starts. * To achieve STARS, complete game using the lowest number of letters.
//                              HAVE FUN, GO PLAY !!!" fontName:@"Arial" fontSize:25];
   
//        
//        NSString* content = @"Instructions\nThe object of this game is to create a 5 letter word in each of the 5 rows.\n* Select the next“available” letter generated in one of the 5 rows or in the spare letter row (bottom of screen).\n* Any spare letter can be used at any time. Select the “available” letter to position it in that same row.\n *Select any unlocked letter to move it into place.\n * If a 5 letter word is not possible, create/ eliminate 3 & 4 letter words to clear space.\n* When a 3 & 4 letter word is created,SWIPE across the word and if valid it will be eliminated.\n* To change your selection, select any letter(in the selected word) before 2 seconds to keep it.\n* When a valid 5 letter word is assembled then it will be LOCKED in.\n*All words must be readable (left to right only).\n * In trophy/level selections (Bronze, Silver & Gold), a number of chosen letters will be locked in specific positions when the game starts.\n* To achieve STARS, complete game using the lowest number of letters.\nHAVE FUN, GO PLAY !!!";
       
//        NSString* contentHTML = [NSString stringWithFormat:@"<html><head></head><body><b><font face='arial' size='2' color='black'>%@</font></b></body></html>", content];
//        
//        NSData* contentData = [NSData dataWithData: [contentHTML dataUsingEncoding: NSASCIIStringEncoding]];
//        UIWebView * myUIWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 400)];
//        [myUIWebView loadData:contentData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[ NSURL URLWithString:@"" ]];
////       
//        
//        [myUIWebView setBackgroundColor:[UIColor clearColor]];
//        [myUIWebView setOpaque:NO];
////        adView = [[TapForTapAdView alloc] initWithFrame: CGRectMake(0,60, 320, 50)];
//        [[[CCDirector sharedDirector] view] addSubview:myUIWebView]; 
//
//       
////      
        
      
        description=[[UITextView alloc] initWithFrame:CGRectMake(backButtonRect.size.height/2,backButtonRect.size.height*2,size.width-size.width/10,size.height-size.height/8)];
        description.backgroundColor = [UIColor clearColor];
        description.textColor=[UIColor whiteColor];
        
        description.text = [NSString stringWithString:@"Instructions\nThe object of this game is to create a 5 letter word in each of the 5 rows.\n* Select the next“available” letter generated in one of the 5 rows or in the spare letter row (bottom of screen).\n* Any spare letter can be used at any time. Select the “available” letter to position it in that same row.\n *Select any unlocked letter to move it into place.\n * If a 5 letter word is not possible, create/ eliminate 3 & 4 letter words to clear space.\n* When a 3 & 4 letter word is created,SWIPE across the word and if valid it will be eliminated.\n* To change your selection, select any letter(in the selected word) before 2 seconds to keep it.\n* When a valid 5 letter word is assembled then it will be LOCKED in.\n*All words must be readable (left to right only).\n * In trophy/level selections (Bronze, Silver & Gold), a number of chosen letters will be locked in specific positions when the game starts.\n* To achieve STARS, complete game using the lowest number of letters.\nHAVE FUN, GO PLAY !!!"];  
        [description setEditable:NO]; 
        description.font = [UIFont fontWithName:@"Marker Felt" size:15.0];
//        description.font = [UIFont fontWithName:@"Arial" size:15.0];
        description.showsHorizontalScrollIndicator = NO;
        description.showsVerticalScrollIndicator=NO;
        description.alwaysBounceVertical = YES;
//        description.userInteractionEnabled=NO;
         description.textAlignment=UITextAlignmentCenter ;
        [[[CCDirector sharedDirector] view]addSubview:description]; 
      
        
     
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
    description.hidden=YES;    
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    //    [[CDAudioManager sharedManager]stopBackgroundMusic];
    [super onExit];
}
@end
