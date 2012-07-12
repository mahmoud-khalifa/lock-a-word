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



#endif
