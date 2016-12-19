//
//  User.h
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *followers;
@property (strong, nonatomic) NSString *bio;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary *)dictionaryValue;

@end
