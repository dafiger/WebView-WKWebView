//
//  ViewController.m
//  OCProjectDemo
//
//  Created by wangpf on 2019/6/3.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewTool *tool = [[WKWebViewTool alloc] initWithFrame:CGRectMake(5, 70, 365, 500)];
    [self.view addSubview:tool];
    tool.pathFileStr = @"index.html";
    
//    tool.showRequestStatus = YES;
    tool.requestStatus = ^(NSInteger status, NSString *msg) {
        NSLog(@"%ld", status);
    };
    
//    tool.showAlertStatus = YES;
    tool.showAlert = ^(UIAlertController *alertControl, NSString *tagStr){
        [self presentViewController:alertControl animated:YES completion:nil];
    };
    
    tool.showProgress = YES;
    tool.requestProgress = ^(double progress){
        NSLog(@"%f", progress);
    };
    
    tool.jsCallOC = YES;
    tool.jsCallOCStatus = ^(NSString *name, id body){
        NSLog(@"%@, %@", name, body);
    };
    
    [tool startRequest];
    
    if (tool.canOCCallJS) {
        [tool ocToJSWithStr:@"jsCallOC(\'对应oc方法名\', \'参数json1\')"];
    }
}


@end
