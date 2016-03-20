//
//  ViewController.m
//  CustomLoadView
//
//  Created by ysq on 16/3/7.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import "ViewController.h"
#import "SQProgressHUD.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) SQProgressHUD *load;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBtn];
}


- (void)createBtn {
    UIButton *show = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [show setTitle:@"show" forState:UIControlStateNormal];
    [show setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [show addTarget:self action:@selector(showHud) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithCustomView:show];
    self.navigationItem.leftBarButtonItem = left;
    
    UIButton *hide = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
    [hide setTitle:@"hide" forState:UIControlStateNormal];
    [hide setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [hide addTarget:self action:@selector(hideHud) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:hide];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)showHud {
    [SQProgressHUD showHUDtoView:self.view animated:YES];
}

- (void)hideHud {
    [SQProgressHUD hideHUDtoView:self.view animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
