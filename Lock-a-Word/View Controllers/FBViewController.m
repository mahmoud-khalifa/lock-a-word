//
//  FBController.m
//  TextTwistGame
//
//  Created by Log n Labs on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FBViewController.h"
#import "AppDelegate.h"

@implementation FBViewController
@synthesize theMsg,theTextView;

-(id)initWithMsg:(NSString*)msg{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self=[super initWithNibName:@"FBView_iPad" bundle:nil];
    }else{
        self=[super initWithNibName:@"FBView" bundle:nil];
    }
    if (self) {
        theMsg=msg;
//        delegate=(AppDelegate *) [[UIApplication sharedApplication] delegate];
//        delegate.facebook.sessionDelegate=self;
    }
    return self;
}
-(void)dealloc{
    [theMsg release];
    [theTextView release];
    [super dealloc];
}

#pragma IBActions
-(IBAction)Share:(id)sender{
    
    [theTextView resignFirstResponder];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate connectToFacebook:theTextView.text];
}

-(IBAction)Back:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    theTextView.text=theMsg;
    // Do any additional setup after loading the view from its nib.
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma -
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
