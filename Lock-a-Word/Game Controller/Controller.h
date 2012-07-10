//
//  Controller.h
//  Lock-A-Word
//
//  Created by Mohamed  Saleh on 7/8/12.
//  Copyright (c) 2012 NOE. All rights reserved.
//

typedef enum
{
    PlasticLock,
    BronzeLock,
    SilverLock,
    GoldLock
}GameMode;
#import <Foundation/Foundation.h>

@interface Controller : NSObject


+ (void)selectChapter:(int)chapter;
+ (void)selectLevel:(int)level;

@end

