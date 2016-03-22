# SQProgressHUD 自定制的加载视图
===
效果展示
---
    ![image](https://github.com/Ysiqian/SQProgressHUD/blob/master/CustomLoadView/CustomLoadView/SQProgressHUD/showHUD.gif)   

加载loading <br>
---
    [SQProgressHUD showHUDToView:self.view animated:YES];
     带文本加载Loading 
    [SQProgressHUD showHUDToView:self.view message:@"正在努力加载中..." animated:YES];
隐藏loading <br>
---
        隐藏loading 
        [SQProgressHUD hideHUDToView:self.view animated:YES];
        隐藏view上的所有SQProgressHUD <br>
        [SQProgressHUD hideAllHUDsToView:self.view animated:YES];

修改Loading<br>
---
        修改loading颜色
        SQProgressHUD *hud = [SQProgressHUD showHUDToView:self.view animated:YES];
        hud.lineColor = [UIColor greenColor];
        修改线条的粗度
        hud.lineWidth = 4.0f;
