# SQProgressHUD
一句话使用加载提示框

加载loading
    [SQProgressHUD showHUDToView:self.view animated:YES];

隐藏loading
    [SQProgressHUD hideHUDToView:self.view animated:YES];

修改Loading颜色
    SQProgressHUD *hud = [SQProgressHUD showHUDToView:self.view animated:YES];
    hud.lineColor = [UIColor greenColor];
