//
//  ViewController.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

@interface ViewController ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (weak, nonatomic) IBOutlet UIView *nonauthView;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef BLUE
    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:145/255.0 blue:220/255.0 alpha:1.0];
#endif
    
    [self checkAuthStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAuthStatus) name:kNotificationsAuthStateDidChange object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationsAuthStateDidChange object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    for (UITouch *touch in [event allTouches]) {
        if ([touch.view isEqual:self.nonauthView]) {
            [((AppDelegate *)[UIApplication sharedApplication].delegate) checkGitHubAuth];
            break;
        }
    }
}


#pragma mark - Private

- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        [_sessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        NSString *token = [((AppDelegate *)[UIApplication sharedApplication].delegate) authToken];
        if (token) {
            [_sessionManager.requestSerializer setValue:[@"token " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
        }
    }
    
    return _sessionManager;
}

- (void)checkAuthStatus {
    _sessionManager = nil;
    
    self.nonauthView.hidden = [((AppDelegate *)[UIApplication sharedApplication].delegate) authToken] ? YES : NO;
    if (!self.nonauthView.hidden) {
        return;
    }
    
    [self getUserList];
}

- (void)getUserList {
//    NSString *urlString = [kFitbitApiPrefix stringByAppendingString:suffixString];
    
//    [[self sessionManager] GET:urlString
    NSString *suffix = [NSString stringWithFormat:@"search/users?q=language:javascript"];
    [self getDataFromAPIUsingRequestSuffixString:suffix completion:^(NSDictionary *responseObject) {
        NSLog(@"");
        /*
        {
            "avatar_url" = "https://avatars.githubusercontent.com/u/110953?v=3";
            "events_url" = "https://api.github.com/users/addyosmani/events{/privacy}";
            "followers_url" = "https://api.github.com/users/addyosmani/followers";
            "following_url" = "https://api.github.com/users/addyosmani/following{/other_user}";
            "gists_url" = "https://api.github.com/users/addyosmani/gists{/gist_id}";
            "gravatar_id" = "";
            "html_url" = "https://github.com/addyosmani";
            id = 110953;
            login = addyosmani;
            "organizations_url" = "https://api.github.com/users/addyosmani/orgs";
            "received_events_url" = "https://api.github.com/users/addyosmani/received_events";
            "repos_url" = "https://api.github.com/users/addyosmani/repos";
            score = 1;
            "site_admin" = 0;
            "starred_url" = "https://api.github.com/users/addyosmani/starred{/owner}{/repo}";
            "subscriptions_url" = "https://api.github.com/users/addyosmani/subscriptions";
            type = User;
            url = "https://api.github.com/users/addyosmani";
        }
        */
    }];
    
    
}

- (void)getDataFromAPIUsingRequestSuffixString:(NSString *)suffixString completion:(void(^) (NSDictionary *responseObject)) completion{
    
    NSString *urlString = [[@"https://api.github.com/" stringByAppendingString:suffixString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [[self sessionManager] GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
        if (completion) {
            completion(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSDictionary *dict = nil;
        if (error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]) {
            dict = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:NSJSONReadingMutableContainers error:nil];
        }
#ifdef DEBUG
        NSLog(@"error %@\n%@",error,dict);
#endif
//        if ([dict[@"errors"][0][@"errorType"] isEqualToString:@"expired_token"]) {
//            [self renewFitBitToken];
//        } else if ([dict[@"errors"][0][@"errorType"] isEqualToString:@"invalid_token"]){
//            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
//            NSString *code = [userDefaults objectForKey:kUserDefaultsFitbitCode];
//            [self cleanFitBitToken];
//            
//            if (code) {
//                [self getTokenUsingAuthCodeString:code completion:^(NSError *error) {
//                    [self getAllFitBitDataInBackgroundMode:[SharedAppDelegate appInBackgroundMode]];
//                }];
//            }
//        } else {
//            NSLog(@"Error: %@", error);
//        }
    }];
}


@end
