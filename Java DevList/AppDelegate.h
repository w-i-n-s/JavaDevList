//
//  AppDelegate.h
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)checkGitHubAuth;
- (NSString *)authToken;

@end

