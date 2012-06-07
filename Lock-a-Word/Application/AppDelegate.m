//
//  AppDelegate.m
//  Word9
//
//  Created by Log n Labs on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "TestFlight.h"
//#import "InstructionsScene.h"
#import "StartingScene.h"
#import "RootViewController.h"

#import "StatisticsCollector.h"

#import "SimpleAudioEngine.h"

#import "Appirater.h"
@implementation AppDelegate

@synthesize window;


@synthesize facebook;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}


void uncaughtExceptionHandler(NSException *exception) {
    
    NSArray *backtrace = [exception callStackSymbols];
    NSString *platform = [[UIDevice currentDevice] model];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    NSString *message = [NSString stringWithFormat:@"Device: %@. OS: %@. Backtrace:\n%@",
                         platform,
                         version,
                         backtrace];
    [StatisticsCollector trackApplicationError:@"Uncaught" andMessage:message andException:exception];
    
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
  
    [TestFlight takeOff:@"e0234faf5f22dd365596d4aae0215f5f_NTc0MjYyMDEyLTAzLTExIDE0OjQyOjQ1LjMwOTgzNg"];

    //Flurry Analytics:
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//    [StatisticsCollector startSession:kFLURRY_APP_KEY];
    
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
//#else
//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
//#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window setRootViewController: viewController];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
//	[[CCDirector sharedDirector] runWithScene: [InstructionsScene scene]];
    [[CCDirector sharedDirector] runWithScene: [StartingScene scene]];
    
    gameController=[Controller sharedController];
    [gameController authenticateLocalPlayer];

    
    
//    [[SimpleAudioEngine sharedEngine]playBackgroundMusic:@"alien_vision.mp3" loop:YES];
     [[CDAudioManager sharedManager]playBackgroundMusic:@"alien_vision.mp3" loop:YES];
    
    
    //App Rater:
	[Appirater appLaunched:YES];

}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [gameController authenticateLocalPlayer];

	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"In Memory Warning");
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
    //App Rater:
	[Appirater appEnteredForeground:YES];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
    
    
    [facebook release];
}



#pragma mark facebook
- (void)connectToFacebook:(NSString *)msg {
    
	//msg IS THE STRING TO BE POSTED ONTO FACEBOOK
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:msg forKey:@"ActiveFacebookMessage"];
    [userD synchronize];
    
    facebook = [[Facebook alloc] initWithAppId:kFACEBOOK_APP_ID andDelegate:self];
    NSArray *permissions = [[NSArray arrayWithObjects: @"publish_stream", nil] retain];
    [facebook authorize:permissions];
    
    
    // Check App ID:
    // This is really a warning for the developer, this should not
    // happen in a completed app
          // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",kFACEBOOK_APP_ID];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] && 
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] && 
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
    
}

- (void)postFacebookMessage {
    
    SBJSON *jsonWriter = [[SBJSON new] autorelease];
    
    // The action links to be shown with the post in the feed
    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Get Started",@"name",kAPP_URL,@"link", nil], nil];
    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    // Dialog parameters
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    NSString *msg = [[NSString alloc] initWithFormat:@"%@",[userD objectForKey:@"ActiveFacebookMessage"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   
                                   @"Try AlphaPanic for iPhone/iPad", @"name",
                                    @"AlphaPanic for iPhone/iPad", @"caption",
                                   @"Challenge yourself", @"description",
                                   kAPP_URL, @"link",
//                                   @"http://www.rockettier.com/wp-content/uploads/2011/10/word_boom_icon.png", @"picture",
                                   actionLinksStr, @"actions",
                                   msg,@"message",
                                   nil];
    [msg release];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
	[facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    //    [self showLoggedIn];
    //    [self  apiDialogFeedUser];
    //       
    // Save authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    
    [self postFacebookMessage];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    CCLOG(@"did not login");
    
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    CCLOG(@"log out");
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    CCLOG(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.
    if ([result objectForKey:@"name"]) {
        //        // If basic information callback, set the UI objects to
        //        // display this.
        //        //nameLabel.text = [result objectForKey:@"name"];
        //        // Get the profile image
        //        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"pic"]]]];
        //        
        //        // Resize, crop the image to make sure it is square and renders
        //        // well on Retina display
        //        float ratio;
        //        float delta;
        //        float px = 100; // Double the pixels of the UIImageView (to render on Retina)
        //        CGPoint offset;
        //        CGSize size = image.size;
        //        if (size.width > size.height) {
        //            ratio = px / size.width;
        //            delta = (ratio*size.width - ratio*size.height);
        //            offset = CGPointMake(delta/2, 0);
        //        } else {
        //            ratio = px / size.height;
        //            delta = (ratio*size.height - ratio*size.width);
        //            offset = CGPointMake(0, delta/2);
        //        }
        //        CGRect clipRect = CGRectMake(-offset.x, -offset.y,
        //                                     (ratio * size.width) + delta,
        //                                     (ratio * size.height) + delta);
        //        UIGraphicsBeginImageContext(CGSizeMake(px, px));
        //        UIRectClip(clipRect);
        //        [image drawInRect:clipRect];
        //        UIImage *imgThumb =   UIGraphicsGetImageFromCurrentImageContext();
        //        [imgThumb retain];
        
        // [profilePhotoImageView setImage:imgThumb];
        //        [self apiGraphUserPermissions];
    } else {
        // Processing permissions information
        
        CCLOG(@"%@",[[result objectForKey:@"data"] objectAtIndex:0]);
        //        [self setUserPermissions:[[result objectForKey:@"data"] objectAtIndex:0]];
    }
    
    //collect statistics
    [StatisticsCollector logEvent:@"Post On Facebook"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [viewController dismissModalViewControllerAnimated:YES];
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    CCLOG(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    CCLOG(@"Err code: %d", [error code]);
    
    // Show logged out state if:
    // 1. the app is no longer authorized
    // 2. the user logged out of Facebook from m.facebook.com or the Facebook app
    // 3. the user has changed their password
    if ([error code] == 190) {
        //        [self showLoggedOut:YES];
        
        // Remove saved authorization information if it exists and it is
        // ok to clear it (logout, session invalid, app unauthorized)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ( [defaults objectForKey:@"FBAccessTokenKey"]) {
            [defaults removeObjectForKey:@"FBAccessTokenKey"];
            [defaults removeObjectForKey:@"FBExpirationDateKey"];
            [defaults synchronize];
            
            // Nil out the session variables to prevent
            // the app from thinking there is a valid session
            if (nil != [ facebook accessToken]) {
                facebook.accessToken = nil;
            }
            if (nil != [facebook expirationDate]) {
                facebook.expirationDate = nil;
            }
        }
        
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [viewController dismissModalViewControllerAnimated:YES];
}

@end
