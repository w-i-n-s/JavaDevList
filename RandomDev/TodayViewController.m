//
//  TodayViewController.m
//  RandomDev
//
//  Created by Sergey Vinogradov on 19.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "User.h"
#import "Config.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarImageView.layer.borderWidth = 5;
    self.avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.loginButton.hidden = [userDefaults valueForKey:kUserDefaultsTokenString] ? YES : NO;
    NSDictionary *dict = [userDefaults objectForKey:kUserDefaultsRandomUser];
    
    if (self.loginButton.hidden) {
        User *user = [[User alloc] initWithDictionary:dict];
        
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
        self.nameLabel.text = user.name;
        self.emailLabel.text = user.email;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
