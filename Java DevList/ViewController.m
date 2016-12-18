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
#import "UserProfileViewController.h"
#import "User.h"

#define kCacheUsersListKey @"CacheUsersListKey"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) NSMutableArray *usersList;

@property (weak, nonatomic) IBOutlet UIView *nonauthView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//pagination
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalItems;
@property (assign, nonatomic) BOOL canRequestNextPage;

@property (assign, nonatomic) NSInteger indexOfSelectedRow;
@property (strong, nonatomic) NSDateFormatter *inDateFormatter;
@property (strong, nonatomic) NSDateFormatter *outDateFormatter;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.usersList = [NSMutableArray array];
    self.canRequestNextPage = YES;
    self.currentPage = 1;
    
    self.inDateFormatter = [[NSDateFormatter alloc] init];
    [self.inDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    self.outDateFormatter = [[NSDateFormatter alloc] init];
    [self.outDateFormatter setDateFormat:@"EEE, MMM d, ''yy"];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"UserProfile"]) {
        UserProfileViewController *vc = [segue destinationViewController];
        vc.user = self.usersList[self.indexOfSelectedRow];
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

- (void)loadUserProfileWithName:(NSString *)userName {
    __weak __typeof(self)weakSelf = self;
    NSString *suffix = [NSString stringWithFormat:@"users/%@",userName];
    [self getDataFromAPIUsingRequestSuffixString:suffix completion:^(NSDictionary *responseObject) {
        NSArray *array = [weakSelf.usersList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name == %@",userName]];
        
        if (![array count]) {
            return;
        }
        
        User *user = array.firstObject;
        user.email = responseObject[@"email"];
        if ([user.email isEqual:[NSNull null]]) {
            user.email = nil;
        }
        
        user.followers = @([responseObject[@"followers"] integerValue]);
        
        NSDate *date = [weakSelf.inDateFormatter dateFromString:responseObject[@"created_at"]];
        user.created = [weakSelf.outDateFormatter stringFromDate:date];
        
        user.bio = responseObject[@"bio"];
        if (!user.bio || [user.bio isEqual:[NSNull null]]) {
            user.bio = @"";
        }
        
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.usersList indexOfObject:user] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
    User *user;
    for (NSDictionary *dict in array) {
        user = [[User alloc] initWithDictionary:dict];
        [self.usersList addObject:user];
        
        [self loadUserProfileWithName:user.name];
    }
    
    [self.usersList sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
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
    cell.user = self.usersList[indexPath.row];
    
    if (indexPath.row >= [self.usersList count]-5) {
        [self getNextPageOfUserList];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexOfSelectedRow = indexPath.row;
    
    [self performSegueWithIdentifier:@"UserProfile" sender:self];
}

@end
