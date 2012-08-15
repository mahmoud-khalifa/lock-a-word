//
//  GameConfig.h
//  Lock-a-Word
//
//  Created by Mahmoud Khalifa on 7/12/12.
//  Copyright (c) 2012 NOE. All rights reserved.
//

#ifndef Lock_a_Word_GameConfig_h
#define Lock_a_Word_GameConfig_h

#define screenSize ([[CCDirector sharedDirector]winSize])
#define backButtonRect CGRectMake(.05*screenSize.width, .895*screenSize.height,.4125*screenSize.width/2, .125*screenSize.height/2)

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif


#define kBOARD_LETTERS_X_OFFSET IS_IPAD() == YES ? 5 : 20
#define kBOARD_LETTERS_Y_OFFSET IS_IPAD() == YES ? 225 : 152
#define kLETTERS_SPACING 1

#define kFLURRY_APP_KEY @"SSGG3CDF8MX9BVQ33HYC"

/*  NORMAL DETAILS */
#define kScreenHeight       480
#define kScreenWidth        320

/* OFFSETS TO ACCOMMODATE IPAD */
#define kXoffsetiPad        64
#define kYoffsetiPad        35

#define kANIMATION_DURATION 0.1

#define ADJUST_CCP(__p__)       \
(IS_IPAD() == YES ?             \
ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + kYoffsetiPad ) : \
__p__)

#define REVERSE_CCP(__p__)      \
(IS_IPAD() == YES ?             \
ccp( ( __p__.x - kXoffsetiPad ) / 2, ( __p__.y - kYoffsetiPad ) / 2 ) : \
__p__)

#define ADJUST_XY(__x__, __y__)     \
(IS_IPAD() == YES ?                     \
ccp( ( __x__ * 2 ), ( __y__ * 2 ) + kYoffsetiPad) : \
ccp(__x__, __y__))

#define ADJUST_X(__x__)         \
(IS_IPAD() == YES ?             \
( __x__ * 2 ) + kXoffsetiPad :      \
__x__)

#define ADJUST_Y(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + kYoffsetiPad : __y__)

#define ADJUST_DOUBLE(__x__) (IS_IPAD() == YES ? ( __x__ * 2 )  : __x__)

#define KTapForTapID @"c91a3680-b956-012f-f6ff-4040d804a637"

#endif
