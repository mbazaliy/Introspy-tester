//
//  AppDelegate.m
//  TestIntrospy
//
//  Created by Max Bazaliy on 6/8/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "AppDelegate.h"
#import "CryptoTester.h"
#import "KeyChainTester.h"
#import "SchemeTester.h"
#import "FileSystemTester.h"
#import "XMLTester.h"
#import "UserPreferencesTester.h"
#import "HTTPTester.h"
#import "PasteboardTester.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CryptoTester runAllTests];
    [KeyChainTester runAllTests];
    [SchemeTester runAllTests];
    [[FileSystemTester new] runAllTests];
    [XMLTester runAllTests];
    [UserPreferencesTester runAllTests];
    [HTTPTester runAllTests];
    [PasteboardTester runAllTests];

    NSLog(@"All tests runned");
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return YES;
}


@end
