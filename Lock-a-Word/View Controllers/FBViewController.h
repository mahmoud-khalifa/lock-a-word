//
//  FBController.h
//  TextTwistGame
//
//  Created by Log n Labs on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AppDelegate.h"

@interface FBViewController : UIViewController
{
    NSString* theMsg;
    
    UITextView* theTextView;
//    AppDelegate *delegate;
}
@property(retain,nonatomic)NSString* theMsg;
@property(retain,nonatomic) IBOutlet UITextView* theTextView;

-(IBAction)Share:(id)sender;
-(IBAction)Back:(id)sender;
-(id)initWithMsg:(NSString*)msg;
@end
