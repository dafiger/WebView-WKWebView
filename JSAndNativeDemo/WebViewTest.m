//
//  WebViewTest.m
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/26.
//  Copyright © 2019 dafiger. All rights reserved.
//

//    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com/search?id=1"];
//    //协议 http
//    NSLog(@"scheme:%@", [url scheme]);
//    //域名 www.baidu.com
//    NSLog(@"host:%@", [url host]);
//    //完整的url字符串(在真机上没有打印出端口 8080)
//    NSLog(@"absoluteString:%@", [url absoluteString]);
//    //相对路径 search
//    NSLog(@"relativePath: %@", [url relativePath]);
//    //端口 8080
//    NSLog(@"port :%@", [url port]);
//    //路径 search
//    NSLog(@"path: %@", [url path]);
//    //search
//    NSLog(@"pathComponents:%@", [url pathComponents]);
//    //参数 id=1
//    NSLog(@"Query:%@", [url query]);


#import "WebViewTest.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import "JSManager.h"

@interface WebViewTest ()<UIWebViewDelegate, JSCallOCDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;

//网络资源
@property (nonatomic, strong) NSURL *remoteUrl;
@property (nonatomic, strong) NSMutableURLRequest *request;
//本地资源
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *localHtmlContent;

@end

@implementation WebViewTest

- (void)viewDidLoad {
    [super viewDidLoad];
    self.remoteUrlStr = @"http://localhost:9080/index.html";
    self.localPathStr = @"index.html";
    
    self.webView.frame = CGRectMake(5, 70, 365, 500);
    [self.view addSubview:self.webView];
    [self updteRequest];
    
    UIButton *btn_oc = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_oc setTitle:@"OC调用JS" forState:UIControlStateNormal];
    btn_oc.backgroundColor = [UIColor lightGrayColor];
    [btn_oc setShowsTouchWhenHighlighted:YES];
    [btn_oc addTarget:self action:@selector(ocCallJS) forControlEvents:UIControlEventTouchUpInside];
    btn_oc.frame = CGRectMake(20, 585, 335, 40);
    [self.view addSubview:btn_oc];
    
    UIButton *btn_update = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_update setTitle:@"刷新" forState:UIControlStateNormal];
    btn_update.backgroundColor = [UIColor lightGrayColor];
    [btn_update setShowsTouchWhenHighlighted:YES];
    [btn_update addTarget:self action:@selector(updteRequest) forControlEvents:UIControlEventTouchUpInside];
    btn_update.frame = CGRectMake(20, 630, 335, 40);
    [self.view addSubview:btn_update];
}

#pragma mark - UIWebViewDelegate
#pragma mark 拦截请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[[request URL] absoluteString] stringByRemovingPercentEncoding];
    NSLog(@"拦截请求-->:%@",requestString);
    
    if ([self checkSubStr:@"JSCallObjCCommand" inStr:requestString]) {
        return NO;
    }
    
    if ([request.URL.scheme caseInsensitiveCompare:@"jsCallOC"] == NSOrderedSame) {
        NSLog(@"发现目标");
        return NO;
    }
    
    return YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"加载失败...");
    NSURLRequest *request = webView.request;
    NSLog(@"%@--%@",[request URL],[request HTTPBody]);
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"开始加载...");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"加载结束...");
    [self updateJsContext];
    NSLog(@"Title:%@",[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"]);
}

#pragma mark - 更新请求
- (void)updteRequest
{
    //加载本地内容
    [self.webView loadHTMLString:self.localHtmlContent baseURL:nil];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.localPath]];

    //加载网络内容
//    NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.remoteUrl]
//                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                         timeoutInterval:10.0];
//    [self.webView loadRequest:request];
}

#pragma mark - OC调用JS
- (void)ocCallJS
{
    //方法一
//    NSString *jsCode = [NSString stringWithFormat:@"showMsg(\'OC调用JS成功！\')"];
    NSString *jsString = [NSString stringWithFormat:@"jsCallOC(\'对应oc方法名\', \'参数json1\')"];
//    [self.webView stringByEvaluatingJavaScriptFromString:jsCode];
//    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakSelf.webView stringByEvaluatingJavaScriptFromString:jsString];
//    });
    
    //方法二
//    [self.jsContext evaluateScript:jsCode];
    [self.jsContext evaluateScript:jsString];
    
    //方法三
//    [self.jsContext[@"jsCallOC"] callWithArguments:@[@"对应oc方法名", @"参数json2"]];
}

#pragma mark - 更新jsContext
- (void)updateJsContext
{
    self.jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"异常抛出-->:%@", exception);
    };
    //方法一
    //拦截
    //方法二
    [self jsCallOC];
    //方法三
    [self jsCallOCWithDelegate];
}

#pragma mark - JS调用OC
- (void)jsCallOC
{
    //建立js函数
    self.jsContext[@"test1"] = ^ {
        NSArray *argsAry = [JSContext currentArguments];
//        NSLog(@"OC接收到JS的数据-->:%@",argsAry);
        for (id obj in argsAry) {
            NSLog(@"OC接收到JS的数据详情-->:%@", (JSValue *)obj);
        }
    };
    
    //模拟js事件
//    NSString *jsClickStr = @"test1(\'参数1\',\'参数2\','abc',123)";
//    [self.jsContext evaluateScript:jsClickStr];
}
#pragma mark JS调用OC（使用代理）
- (void)jsCallOCWithDelegate
{
    //建立js函数
    self.jsContext[@"JSOCBridge"] = [[JSManager alloc] initWithDelegate:self];
    
    //模拟js事件
//    NSString *jsClickStr = @"JSOCBridge.jsCallOC(\'对应oc方法名\', \'参数json\')";
//    [self.jsContext evaluateScript:jsClickStr];
}

#pragma mark JSCallOCDelegate
- (void)jsCallOC:(NSString *)action params:(NSString *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"jsCallOC action:%@, params:%@", action, params);
    });
}

#pragma mark - UserAgent
- (void)changeUserAgent
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"自带的UserAgent:%@", oldAgent);
    // Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Mobile/14C89
    NSString *newAgent = [oldAgent stringByAppendingString:@" MicroMessenger/6.0"];
    NSLog(@"自带增加后的UserAgent:%@", newAgent);
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

- (void)changeUserAgentForiPhoneWeb
{
    NSString *newAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_2 like Mac OS X) AppleWebKit/602.3.12 (KHTML, like Gecko) Mobile/14C89";
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

- (void)changeUserAgentForPCWeb
{
    NSString *newAgent = @"Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36";
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

#pragma mark - 懒加载
- (UIWebView *)webView{
    if (!_webView){
        _webView = [UIWebView new];
        _webView.backgroundColor = [UIColor blackColor];
//        _webView.scrollView.bounces = NO;
//        _webView.scrollView.scrollEnabled = NO;
        _webView.scalesPageToFit = YES;
        _webView.layer.borderColor = [UIColor purpleColor].CGColor;
        _webView.layer.borderWidth = 1;
        _webView.delegate = self;
//        [_webView reload];
//        if ([_webView canGoBack]) {
//            [_webView goBack];
//        }
//        if ([_webView canGoForward]) {
//            [_webView goForward];
//        }
//        if ([_webView isLoading]) {
//            [_webView stopLoading];
//        }
        //背景音乐不自动播放
        [_webView setMediaPlaybackRequiresUserAction:NO];
    }
    return _webView;
}

- (NSMutableURLRequest *)request{
    if (!_request){
        _request = [NSMutableURLRequest requestWithURL:self.remoteUrl];
        [_request setHTTPMethod:@"POST"];
        NSData *bodyData = [[self.remoteUrl query] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [_request setValue:[NSString stringWithFormat:@"%ld",bodyData.length] forHTTPHeaderField:@"Content-Length"];
        [_request setHTTPBody:bodyData];
        [_request setHTTPShouldHandleCookies:FALSE];
    }
    return _request;
}

- (NSURL *)remoteUrl{
    if (!_remoteUrl){
        //网络资源
        _remoteUrl = [NSURL URLWithString:self.remoteUrlStr];
        //本地资源
//        _remoteUrl = [NSURL fileURLWithPath:self.localPath];
//        _remoteUrl = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
//        NSLog(@"remoteUrl:%@", [_remoteUrl absoluteString]);
    }
    return _remoteUrl;
}

- (NSString *)localPath{
    if (!_localPath){
        //本地资源
        _localPath = [[NSBundle mainBundle] pathForResource:self.localPathStr ofType:nil];
//        NSLog(@"localPath:%@", _localPath);
    }
    return _localPath;
}

- (NSString *)localHtmlContent{
    if (!_localHtmlContent){
        //本地内容
        _localHtmlContent = [NSString stringWithContentsOfFile:self.localPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
        //网络内容
//        _localHtmlContent = [NSString stringWithContentsOfURL:self.remoteUrl
//                                                     encoding:NSUTF8StringEncoding
//                                                        error:nil];
//        NSLog(@"localHtmlContent:%@", _localHtmlContent);
    }
    return _localHtmlContent;
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

#pragma mark - 索引字符串
- (BOOL)checkSubStr:(NSString *)subStr inStr:(NSString *)string
{
    // 判断字符串是否包含
    NSRange range = [string rangeOfString:subStr];
    if(range.location != NSNotFound){
        return YES;
    }else{
        return NO;
    }
}

@end
