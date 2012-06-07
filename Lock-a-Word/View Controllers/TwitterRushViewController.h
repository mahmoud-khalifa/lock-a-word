//
//  TwitterRushViewController.h
//  TwitterRush

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@interface TwitterRushViewController : UIViewController <UITextViewDelegate, SA_OAuthTwitterControllerDelegate>
{ 

	IBOutlet UITextView *tweetTextField;
    
    SA_OAuthTwitterEngine *_engine;
    
    NSString* theMessage;
    bool isFirstTimeAppeared;
    
    IBOutlet UIButton* tweet;
	
}

@property(nonatomic, retain) IBOutlet UITextView *tweetTextField;
@property(nonatomic,retain) IBOutlet UIButton* tweet;
-(id)initWithMessage:(NSString*)msg;

-(IBAction)updateTwitter:(id)sender; 
-(IBAction)back:(id)sender;

@end

