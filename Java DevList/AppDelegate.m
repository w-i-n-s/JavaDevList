//
//  AppDelegate.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "AFOAuth2Manager.h"

@interface AppDelegate ()



@end

@implementation AppDelegate

#define kGitHubClientId     @"b8768c36af0fd5955a39"
#define kGitHubSecret       @"4ef0254d410860c4cb0bf3a898172f1767c922bf"
#define kGitHubRedirectUrl  @"javadevlist://githubback"

NSString *const kNotificationsAuthStateDidChange = @"NotificationsAuthStateDidChange";
NSString *const kUserDefaultsSuiteName = @"com.umwerk.javadevlist";
NSString *const kTokenString = @"GitHubToken";

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if ([url.scheme isEqualToString:@"javadevlist"]) {
        NSString *code = url.absoluteString;
        NSRange range = [code rangeOfString:@"code="];
        if (range.location != NSNotFound) {
            code = [code substringFromIndex:(range.location + range.length)];
            
            [self getTokenUsingAuthCodeString:code completion:nil];
        }
        
        return YES;
    }
    
    return NO;
}


#pragma mark - Public

- (void)checkGitHubAuth {
    if (![self authToken]) {
        NSString *urlString = [NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=user&allow_signup=false",kGitHubClientId,kGitHubRedirectUrl];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];//URLFragmentAllowedCharacterSet
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}


#pragma mark - Private

- (NSString *)authToken {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    return [userDefaults valueForKey:kTokenString];
}

- (void)getTokenUsingAuthCodeString:(NSString *)authCodeString completion:(void(^) (NSError *error)) completion{
    NSURL *baseURL = [NSURL URLWithString:@"https://github.com/login/oauth/access_token"];
    
    NSDictionary *params = @{@"client_id" : kGitHubClientId,
                             @"client_secret" : kGitHubSecret,
                             @"code" : authCodeString};

    AFOAuth2Manager *OAuth2Manager = [AFOAuth2Manager managerWithBaseURL:baseURL clientID:kGitHubClientId secret:kGitHubSecret];
    
    //__weak __typeof(self)weakSelf = self;
    [OAuth2Manager authenticateUsingOAuthWithURLString:@"https://github.com/login/oauth/access_token" parameters:params success:^(AFOAuthCredential *credential) {
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
        [userDefaults setObject:credential.accessToken forKey:kTokenString];
        [userDefaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationsAuthStateDidChange object:nil];
        
        if (completion) {
            completion(nil);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end
