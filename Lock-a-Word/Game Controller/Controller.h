//
//  Controller.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright (c) 2012 NOE. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kBOARD_SIZE 100

typedef enum
{
    PlasticLock = 1,
    BronzeLock = 2,
    SilverLock = 3,
    GoldLock = 4
}GameMode;




@interface Controller : NSObject


+ (Controller*) sharedController;

- (void)selectChapter:(int)chapter;
- (void)selectLevel:(int)level;


- (void)newGame;
- (void)resetBoard;


- (void)printBoard;
@end

