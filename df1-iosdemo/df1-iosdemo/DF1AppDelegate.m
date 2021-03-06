//
//  DF1AppDelegate.m
//  df1-iosdemo
//
//  Created by JB Kim on 3/23/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//

#import "DF1AppDelegate.h"
#import "DF1DevListController.h"
#import "Utility.h"
 
@implementation DF1AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    //Allow notifications for tap detector
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // initial root view controller under navigation view controller
    DF1DevListController *devlist = [[DF1DevListController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav   = [[UINavigationController alloc] initWithRootViewController:devlist];
    self.window.rootViewController = nav;
    // you tell the navigationViewController this current viewController is a delegate
    [nav setDelegate:(id<UINavigationControllerDelegate>)devlist];
    [[nav delegate] navigationController:nav willShowViewController:devlist animated:YES];
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults valueForKey:@"launchedBefore"]) {
        NSMutableArray *useCaseArray = [[NSMutableArray alloc] initWithArray: @[
                                  @{@"name" : @"defaults",
                                    @"DF1CfgBatteryLevel" : @1,
                                    @"DF1CfgCSVDataRecorder" : @1,
                                    @"DF1CfgDistance" : @1,
                                    @"DF1CfgFreefall" : @1,
                                    @"DF1CfgMagnitudeValues" : @1,
                                    @"DF1CfgTap" : @1,
                                    @"DF1CfgXYZPlotter" : @1,
                                    }
                                  ]];
        [defaults setObject:useCaseArray forKey:@"use_cases"];
        [defaults setObject:@"defaults" forKey:@"active_use_case"];
        [defaults setValue:@YES forKey:@"launchedBefore"];
        [defaults synchronize];
    }
    
    
    
    
    return YES;

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
