//
//  ViewController.m
//  CustomLoadView
//
//  Created by ysq on 16/3/7.
//  Copyright © 2016年 ysq. All rights reserved.
//

#import "ViewController.h"
#import "SQProgressHUD.h"

@interface ViewController ()<UIActionSheetDelegate>

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
    [SQProgressHUD hideAllHUDsToView:self.view animated:YES];
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"showHUD"
                                                                                                delegate:self
                                                                                cancelButtonTitle:@"取消"
                                                                        destructiveButtonTitle:nil
                                                                                 otherButtonTitles:@"只显示loading",
                                                                                                                    @"带文本显示Loading",
                                                                                                                    @"修改HUD颜色",
                                                                                                                    @"修改HUD粗度",
                                                                                                                    @"修改HUD颜色,粗度,带文本显示",
                                                                                                                    @"successHUD",
                                                                                                                    @"FailHUD" ,nil];
    [sheet showInView:self.view];
    sheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [SQProgressHUD showHUDToView:self.view animated:YES];
            break;
        }
        case 1: {
            [SQProgressHUD showHUDToView:self.view message:@"正在努力加载中..." animated:YES];
            break;
        }
        case 2: {
            SQProgressHUD *hud = [SQProgressHUD showHUDToView:self.view animated:YES];
            hud.lineColor = [UIColor greenColor];
            break;
        }
        case 3: {
            SQProgressHUD *hud = [SQProgressHUD showHUDToView:self.view animated:YES];
            hud.lineWidth = 4.0f;
            break;
        }
        case 4: {
            SQProgressHUD *hud = [SQProgressHUD showHUDToView:self.view message:@"Y哥正在努力帮你加载中..." animated:YES];
            hud.lineColor = [UIColor whiteColor];
            hud.lineWidth = 2.0f;
            break;
        }
        case 5: {
            SQProgressHUD *hud = [SQProgressHUD showSuccessToView:self.view];
            hud.lineColor = [UIColor whiteColor];
            hud.lineWidth = 6.0f;
            break;
        }
        case 6: {
            [SQProgressHUD showFailToView:self.view];
            break;
        }
        default:
            break;
    }
}

- (void)hideHud {
    [SQProgressHUD hideAllHUDsToView:self.view animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
