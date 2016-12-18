//
//  ViewController.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import "UserTableViewCell.h"

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "NSArray+Cache.h"

#define kCacheUsersListKey @"CacheUsersListKey"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) NSMutableArray *usersList;

@property (weak, nonatomic) IBOutlet UIView *nonauthView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSArray *cachedArray = [[NSArray alloc] initArrayFromCacheWithKey:kCacheUsersListKey];
    self.usersList = [NSMutableArray arrayWithArray:cachedArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef BLUE
    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:145/255.0 blue:220/255.0 alpha:1.0];
#endif
    
    [self checkAuthStatus];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
#pragma mark Network

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
    __weak __typeof(self)weakSelf = self;
    NSString *suffix = [NSString stringWithFormat:@"search/users?q=language:javascript&per_page=10&page=0"];
    [self getDataFromAPIUsingRequestSuffixString:suffix completion:^(NSDictionary *responseObject) {
        [weakSelf addResultsFromList:responseObject[@"items"]];
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

    }];
}

#pragma mark Fill results

- (void)addResultsFromList:(NSArray *)array {
    //TODO: parse to model
    [self.usersList addObjectsFromArray:array];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell" forIndexPath:indexPath];
    cell.userDictionary = self.usersList[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
@end
