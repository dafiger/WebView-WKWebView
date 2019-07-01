//
//  WKWebJSManager.m
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/28.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import "WKWebJSManager.h"

@implementation WKWebJSManager

- (instancetype)initWithName:(NSString *)nameStr
                    delegate:(id<JSCallOCDelegate>)delegate
{
    if (self = [super init]) {
        self.nameStr = nameStr;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
{
    //通过接收JS传出消息的name进行捕捉的回调方法
    NSLog(@"WKWeb接受到JS name:%@，body:%@，frameInfo:%@", message.name, message.body, message.frameInfo);
    if ([message.name caseInsensitiveCompare:self.nameStr] == NSOrderedSame) {
        //用message.body获得JS传出的参数体
        NSDictionary *parameter = message.body;
        NSString *action = [self decodeURLWithStr:parameter[@"action"]];
        NSString *params = [self decodeURLWithStr:parameter[@"params"]];
        NSLog(@"JS调用了OC，%@ : %@", action, params);
        
        if ([self.delegate respondsToSelector:@selector(jsCallOC:params:)]) {
            [self.delegate jsCallOC:action params:params];
        }
    }
}

#pragma mark - 字符串UTF8编码和解码
- (NSString *)encodeURLWithStr:(NSString *)urlStr{
    if (urlStr.length == 0) {
        return nil;
    }
    //    NSString *urlStr_en_old = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlStr_en = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return urlStr_en;
}

- (NSString *)decodeURLWithStr:(NSString *)urlStr{
    if (urlStr.length == 0) {
        return nil;
    }
    //    NSString *urlStr_de_old = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlStr_de = [urlStr stringByRemovingPercentEncoding];
    return urlStr_de;
}
@end
