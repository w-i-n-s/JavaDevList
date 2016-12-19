//
//  User.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        self.name       = dict[@"login"];
        self.avatarUrl  = dict[@"avatar_url"];
    }
    
    return self;
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"login":self.name}];
    [dict setObject:self.avatarUrl forKey:@"avatar_url"];
    if (self.email) {
        [dict setObject:self.email forKey:@"email"];
    }
    
    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@>", NSStringFromClass([self class]), self, self.name];
}

@end
