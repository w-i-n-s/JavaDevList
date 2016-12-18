//
//  UserTableViewCell.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "UserTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

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
    _userDictionary = nil;
    
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image = nil;
}

- (void)setUserDictionary:(NSDictionary *)userDictionary {
    _userDictionary = userDictionary;
    
    NSString *avatarUrsString = userDictionary[@"avatar_url"];
    if (avatarUrsString) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrsString]];
    }
    
    self.nameLabel.text = userDictionary[@"login"];
    self.dateLabel.text = nil;
}

@end
