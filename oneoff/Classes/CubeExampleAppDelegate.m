//
//  CubeExampleAppDelegate.m
//  CubeExample
//
//  Created by Brad Larson on 4/20/2010.
//

#import "CubeExampleAppDelegate.h"
#import "EAGLView.h"

@implementation CubeExampleAppDelegate

@synthesize window;
@synthesize glView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
