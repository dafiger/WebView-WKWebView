//
//  WKWebViewJSTool.m
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/28.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import "WKWebViewJSTool.h"

@implementation WKWebViewJSTool

- (instancetype)initWithDelegate:(id<JSCallOCDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
{
    //通过接收JS传出消息的name进行捕捉的回调方法
//    NSLog(@"WKWeb接受到JS name:%@，body:%@，frameInfo:%@", message.name, message.body, message.frameInfo);
    if ([self.delegate respondsToSelector:@selector(messageWithName:body:)]) {
        [self.delegate messageWithName:message.name body:message.body];
    }
}

@end
