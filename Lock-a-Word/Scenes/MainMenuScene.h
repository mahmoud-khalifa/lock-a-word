//
//  MainMenuScene.h
//  TemplateProject
//
//  Created by Log n Labs on 12/13/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"


// MainMenuScene
@interface MainMenuScene : CCLayer
{
     CGPoint startTouchLocation;

//    CCLabelBMFont* horizontalModeHighScore;
//    CCLabelBMFont* verticalModeHighScore;
//    CCLabelBMFont* bothModeHighScore;
//    CCLabelBMFont* dropAllModeHighScore;
//    
//    CCLabelBMFont* TotalScore;
    
}



// returns a CCScene that contains the MainMenuScene as the only child
+(CCScene *) scene;

@end
