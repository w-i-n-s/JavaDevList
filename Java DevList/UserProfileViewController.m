//
//  UserProfileViewController.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 19.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "UserProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "User.h"

@interface UserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

@end

@implementation UserProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef BLUE
    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:145/255.0 blue:220/255.0 alpha:1.0];
#endif
    
    self.avatarImageView.layer.borderWidth = 5;
    self.avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarUrl]];
    [self.emailButton setTitle:[NSString stringWithFormat:@"e-mail: %@",(self.user.email ? self.user.email : @"<hidden>")] forState:UIControlStateNormal];
    self.followersLabel.text = [NSString stringWithFormat:@"followers: %@", self.user.followers];
    self.bioTextView.text = self.user.bio;
}

#pragma mark - Actions

- (IBAction)backButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendEmailMessage:(id)sender {
    if (!self.user.email) {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat: @"mailto:%@?subject=You are JavaScript Dev?&body=Hello, me too)",self.user.email];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
