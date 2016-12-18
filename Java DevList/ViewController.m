//
//  ViewController.m
//  Java DevList
//
//  Created by Sergey Vinogradov on 18.12.16.
//  Copyright © 2016 wins.konar@gmail.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef BLUE
    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:145/255.0 blue:220/255.0 alpha:1.0];
#endif
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
