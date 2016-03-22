# SQProgressHUD 自定制的加载视图
===
#加载loading <br>
---
    [SQProgressHUD showHUDToView:self.view animated:YES];<br>
带文本加载Loading <br>
    [SQProgressHUD showHUDToView:self.view message:@"正在努力加载中..." animated:YES];<br>
#隐藏loading <br>
---
隐藏loading <br>
    [SQProgressHUD hideHUDToView:self.view animated:YES];<br>
隐藏view上的所有SQProgressHUD <br>
    [SQProgressHUD hideAllHUDsToView:self.view animated:YES];<br>

#修改Loading<br>
---
修改loading颜色<br>
    SQProgressHUD *hud = [SQProgressHUD showHUDToView:self.view animated:YES];<br>
    hud.lineColor = [UIColor greenColor];<br>
    修改线条的粗度<br>
    hud.lineWidth = 4.0f;<br>
