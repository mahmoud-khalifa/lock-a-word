//
//  GameConfig.h
//  Word9
//
//  Created by Log n Labs on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//

// 3rd generation and newer devices: Rotate using UIViewController. Rotation should be supported on iPad apps.
// TIP:
// To improve the performance, you should set this value to "kGameAutorotationNone" or "kGameAutorotationCCDirector"
#if defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR
#define GAME_AUTOROTATION kGameAutorotationUIViewController

// ARMv6 (1st and 2nd generation devices): Don't rotate. It is very expensive
#elif __arm__
#define GAME_AUTOROTATION kGameAutorotationNone


// Ignore this value on Mac
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#else
#error(unknown architecture)
#endif

#endif // __GAME_CONFIG_H

#define kTOTAL_BONUS_TIMER 601

#define screenSize ([[CCDirector sharedDirector]winSize])

#define kWIDTH_FACTOR (screenSize.width/320.0f)
#define kHEIGHT_FACTOR (screenSize.height/480.0f)

#define kAVAILABLE_LETTERS_X_OFFSET 45
#define kAVAILABLE_LETTERS_Y_OFFSET 72//60

#define kBOARD_LETTERS_X_OFFSET 5
#define kBOARD_LETTERS_Y_OFFSET 140
#define kLETTERS_SPACING 1

#define kCOLLECTED_WORDS_X_OFFSET 30
#define kCOLLECTED_WORDS_Y_OFFSET 32
#define kCOLLECTED_WORDS_LETTERS_SPACING 2

#define kDONE_BUTTON_X_POS 291
#define kDONE_BUTTON_Y_POS 0

#define kPANIC_BUTTON_X_POS 160
#define kPANIC_BUTTON_Y_POS 78

#define kSCORE_LABEL_X_POS 10
#define kSCORE_LABEL_Y_POS 458

#define kTIMER_LABEL_X_POS 65
#define kTIMER_LABEL_Y_POS 460

#define kCOUNT_DOWN_TIMER_LABEL_X_POS 289
#define kCOUNT_DOWN_TIMER_LABEL_Y_POS 78


#define kBACK_BUTTON_X_POS 40
#define kBACK_BUTTON_Y_POS 450


#define kWORD_BAR_X_POS 131
#define kWORD_BAR_Y_POS 7

#define kVOWEL_LETTER_POS ADJUST_XY(15,370)


#define kCORRECT_WORD_SCALE 0.75
#define kAVAILABLE_LETTERS_OVERLAP_RATIO 0.55

#define kANIMATION_DURATION 0.5

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif


/*  NORMAL DETAILS */
#define kScreenHeight       480
#define kScreenWidth        320

/* OFFSETS TO ACCOMMODATE IPAD */
#define kXoffsetiPad        64
#define kYoffsetiPad        32


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
ccp( ( __x__ * 2 ) + kXoffsetiPad, ( __y__ * 2 ) + kYoffsetiPad ) : \
ccp(__x__, __y__))

#define ADJUST_X(__x__)         \
(IS_IPAD() == YES ?             \
( __x__ * 2 ) + kXoffsetiPad :      \
__x__)

#define ADJUST_Y(__y__) (IS_IPAD() == YES ? ( __y__ * 2 ) + kYoffsetiPad : __y__)

#define ADJUST_DOUBLE(__x__) (IS_IPAD() == YES ? ( __x__ * 2 )  : __x__)

//#warning change the flurry app ID
//#define kFLURRY_APP_KEY @"J5J5ZZ38SLNI94I7P5S7"   //Development
#define kFLURRY_APP_KEY @"4SQN1T1Y7EJT8WPQY3A5"   //Release


#define kGAME_MODE_HORIZONTAL_EVENT @"Hovering Cross-Step"
#define kGAME_MODE_VERTICAL_EVENT @"Vertical Cha-Cha"
#define kGAME_MODE_BOTH_EVENT @"Alien Jeg"
#define kGAME_MODE_DROPALL_EVENT @"Drop All"

#define kHIGH_SCORE_KEY @"high_score"

#define kAPP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define kFACEBOOK_APP_ID @"295339607204685"
#define kFACEBOOK_APP_SECRET @"a7626a6ba99337d53b4e12bc83ca073e" //not used

#define kAPP_URL @"http://itunes.apple.com/us/app/alpha-panic/id512166754?ls=1&mt=8"

//Leaderboards ID
#define kCROSS_STEP_LEADERBOARD_ID @"cross_step_high_Score"
#define kCHA_CHA_LEADERBOARD_ID @"vertical_cha_cha_high_score"
#define kALIEN_JIG_LEADERBOARD_ID @"alien_jig_high_score"
#define kHUMANOID_TWIST_LEADERBOARD_ID @"humanoid_twist_high_score"
#define kCOMBINED_LEADERBOARD @"general_high_score"



#define kLAST_PLAYED_GAME_MODE_KEY @"last_played_game_mode"