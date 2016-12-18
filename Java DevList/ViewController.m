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

//Caching
//#import "NSArray+Cache.h"

#define kCacheUsersListKey @"CacheUsersListKey"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) NSMutableArray *usersList;

//Caching
//@property (strong, nonatomic) NSMutableArray *idList;

@property (weak, nonatomic) IBOutlet UIView *nonauthView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//pagination
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalItems;
@property (assign, nonatomic) BOOL canRequestNextPage;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.usersList = [NSMutableArray array];
    self.canRequestNextPage = YES;
    self.currentPage = 1;
    //Caching
    /*
    NSArray *cachedArray = [[NSArray alloc] initArrayFromCacheWithKey:kCacheUsersListKey];
    self.usersList = [NSMutableArray arrayWithArray:cachedArray];
    
    self.idList = [NSMutableArray array];
    for (NSDictionary *dict in self.usersList) {
        [self.idList addObject:[dict[@"id"] mutableCopy]];
    }
     */
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
    
    [self getNextPageOfUserList];
}

- (void)getNextPageOfUserList {
    if (!self.canRequestNextPage) {
        return;
    }
    
    if (self.totalItems && (self.currentPage*10 > self.totalItems)) {
        return;
    }
    
    self.canRequestNextPage = NO;
    
    __weak __typeof(self)weakSelf = self;
    NSString *suffix = [NSString stringWithFormat:@"search/users?q=language:javascript&per_page=10&page=%d",self.currentPage];
    [self getDataFromAPIUsingRequestSuffixString:suffix completion:^(NSDictionary *responseObject) {
        weakSelf.totalItems = [responseObject[@"total_count"] integerValue];
        weakSelf.currentPage++;
        weakSelf.canRequestNextPage = YES;
        
        [weakSelf addResultsFromList:responseObject[@"items"]];
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
    
    //Caching
    /*
    for (NSDictionary *dict in array) {
        if (![self.idList containsObject:dict[@"id"]]) {
            [self.idList addObject:[dict[@"id"] mutableCopy]];
            [self.usersList addObject:dict];
        }
    }
    
    [self.usersList storeArrayToCacheWithKey:kCacheUsersListKey];
    */
    
    [self.usersList addObjectsFromArray:array];
    [self.usersList sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"login" ascending:YES]]];
    
    [self.tableView reloadData];
    
    //!!!: You said "Bonus: order by username", but without next line I have no idea how to user can see this list
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell" forIndexPath:indexPath];
    cell.userDictionary = self.usersList[indexPath.row];
    
    if (indexPath.row >= [self.usersList count]-5) {
        [self getNextPageOfUserList];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
@end
