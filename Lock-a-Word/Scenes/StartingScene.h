//
//  StartingScene.h
//  Word9
//
//  Created by Log n Labs on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ResourcesLoader.h"
#define kTAP_SCREEN_SPRITE_TAG 100
#define kLOADING_LABEL_TAG 101
@interface StartingScene : CCLayer <ResourceLoaderDelegate>{
    
}

// returns a CCScene that contains the StartingScene as the only child
+(CCScene *) scene;
-(void)addTapSprite;
@end
