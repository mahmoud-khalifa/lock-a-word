//
//  TwitterRushViewController.m
//  TwitterRush

#import "TwitterRushViewController.h"
#import "SA_OAuthTwitterEngine.h"
#import "AppDelegate.h"

#import "StatisticsCollector.h"
#import "BlockAlertView.h"

/* Define the constants below with the Twitter 
   Key and Secret for your application. Create
   Twitter OAuth credentials by registering your
   application as an OAuth Client here: http://twitter.com/apps/new
 */
#define kOAuthConsumerKey				@"IZmsiyVt8a0rRItdzsQqA"
#define kOAuthConsumerSecret			@"aeWlqbAp3BVTJiRPo4f5jYIZiAARHiCO9DjX6KwW0"		

@implementation TwitterRushViewController

@synthesize tweetTextField,tweet; 

#pragma initialization
-(id)initWithMessage:(NSString*)msg{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self=[super initWithNibName:@"TwitterRushViewController_iPad" bundle:nil];
    }else{
        self=[super initWithNibName:@"TwitterRushViewController" bundle:nil];
    }
    
    if (self) {
         theMessage=[[NSString alloc]initWithString:msg];
        self.wantsFullScreenLayout=NO;
    }
   
    return self;
}
#pragma mark Custom Methods

-(IBAction)updateTwitter:(id)sender
{
	//Dismiss Keyboard
	[tweetTextField resignFirstResponder];

    if([_engine isAuthorized]){
        //Twitter Integration Code Goes Here
        [_engine sendUpdate:tweetTextField.text];
    }else{
        
        BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Error" message:@"You didn't sign in" andLoadingviewEnabled:nil];
        [alert setCancelButtonWithTitle:@"OK" block:nil];
        
//        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"You didn't sign in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
//        [alert release];
    }
    
}
-(IBAction)back:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark ViewController Lifecycle

- (void)viewDidLoad {
	tweetTextField.text=theMessage;
    
    isFirstTimeAppeared=YES;
    
    // Twitter Initialization / Login Code Goes Here
    if(!_engine){  
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
        _engine.consumerKey    = kOAuthConsumerKey;  
        _engine.consumerSecret = kOAuthConsumerSecret;  
    }  	
    
    if(![_engine isAuthorized]){  
        [tweet setEnabled:NO];
    }    
    
}
-(void)viewDidAppear:(BOOL)animated{

//    tweetTextField.text=theMessage;
    // Twitter Initialization / Login Code Goes Here
    if (isFirstTimeAppeared) {
//        if(!_engine){  
//            _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
//            _engine.consumerKey    = kOAuthConsumerKey;  
//            _engine.consumerSecret = kOAuthConsumerSecret;  
//        }  	
        
        if(![_engine isAuthorized]){  
            UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
            
            if (controller){  
                [self presentModalViewController: controller animated: YES];  
            }  
        }    

        isFirstTimeAppeared=NO;
    }
     [super viewDidAppear:animated];
}
	   
- (void)viewDidUnload {	
	[tweetTextField release];
	tweetTextField = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_engine release];
	[tweetTextField release];
    
    [theMessage release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
      
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
}

#pragma TextViewDelegate Methods
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [tweetTextField resignFirstResponder];
    return YES;
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
    
     [tweet setEnabled:YES];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	
    //collect statistics
    [StatisticsCollector logEvent:@"Post On Twitter"];
    
#ifdef DEBUG
    
    NSLog(@"Request %@ succeeded", requestIdentifier);
#endif
    
    BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Success" message:@"Your Tweet was sent successfully" andLoadingviewEnabled:NO];
    [alert setCancelButtonWithTitle:@"OK" block:nil];

//    UIAlertView* alert=[[UIAlertView alloc ]initWithTitle:@"Success" message:@"Your Tweet was sent successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
//    [alert release];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
#ifdef DEBUG
    NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
#endif
    BlockAlertView* alert=[BlockAlertView alertWithTitle:@"Failed" message:@"Failed to post your tweet, check your Internet Connection" andLoadingviewEnabled:NO];
    [alert setCancelButtonWithTitle:@"OK" block:nil];
//    UIAlertView* alert=[[UIAlertView alloc ]initWithTitle:@"Failed" message:@"Failed to post your tweet, check your Internet Connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
//    [alert release];
    
    [self dismissModalViewControllerAnimated:YES];
}


@end
