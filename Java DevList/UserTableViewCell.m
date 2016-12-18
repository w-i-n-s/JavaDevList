//
//  UserTableViewCell.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "UserTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "User.h"

@interface UserTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation UserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImageView.layer.borderWidth = 5;
    self.avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [self.avatarImageView setShowActivityIndicatorView:YES];
    [self.avatarImageView setIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}

- (void)prepareForReuse {
    _user = nil;
    
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
}

- (void)setUser:(User *)user {
    _user = user;
    
    if (user.avatarUrl) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl]];
    }
    
    self.nameLabel.text = user.name;
    self.dateLabel.text = user.created;
}

@end
