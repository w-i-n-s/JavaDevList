//
//  UserTableViewCell.h
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface UserTableViewCell : UITableViewCell

@property (strong, nonatomic) User *user;

@end
