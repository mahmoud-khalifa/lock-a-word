//
//  GameScene.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright 2012 NOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Controller.h"
#import "TapForTap.h"

@interface GameScene : CCLayer <GameKitHelperProtocol, TapForTapAdViewDelegate>

+ (id)scene;
 
@end
