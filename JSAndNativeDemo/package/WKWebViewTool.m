//
//  WKWebViewTool.m
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/28.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import "WKWebViewTool.h"
#import "WKWebViewJSTool.h"

@interface WKWebViewTool()<JSCallOCDelegate>

@property (nonatomic, strong) NSURL *remoteUrl;
@property (nonatomic, copy)   NSString *localHtmlContent;

@property (nonatomic, strong) WKWebViewJSTool *jsManager;

@end

@implementation WKWebViewTool

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
    }
    self.webView.frame = self.bounds;
    [self addSubview:self.webView];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                    remoteUrl:(NSString *)remoteUrlStr
                  autoRequest:(BOOL)autoRequest
{
    self = [self initWithFrame:frame];
    self.remoteUrlStr = remoteUrlStr;
    if (autoRequest) {
        [self startRequest];
    }
    return self;
}

#pragma mark - 发起请求
- (void)startRequest
{
    if (self.remoteUrlStr.length) {
        //网络请求
        NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteUrl];
//        NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteUrl
//                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                             timeoutInterval:10.0];
        [self.webView loadRequest:request];
    }else{
        //本地请求
        if (@available(iOS 9.0, *)) {
            NSURL *localUrl = [[NSBundle mainBundle] URLForResource:self.pathFileStr withExtension:nil];
            [self.webView loadFileURL:localUrl allowingReadAccessToURL:localUrl];
        } else {
            [self.webView loadHTMLString:self.localHtmlContent baseURL:nil];
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSLog(@"请求之前...");
    NSString *requestString = [[[navigationAction.request URL] absoluteString] stringByRemovingPercentEncoding];
    NSLog(@"拦截到请求:%@",requestString);
    if ([self.delegate respondsToSelector:@selector(requestStatus:msg:)]) {
        [self.delegate requestStatus:1 msg:@"decidePolicyForNavigationAction"];
    }
    if (self.canShowRequestStatus) {
        self.requestStatus(1, @"decidePolicyForNavigationAction");
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLog(@"开始请求...");
    if ([self.delegate respondsToSelector:@selector(requestStatus:msg:)]) {
        [self.delegate requestStatus:2 msg:@"didStartProvisionalNavigation"];
    }
    if (self.canShowRequestStatus) {
        self.requestStatus(2, @"didStartProvisionalNavigation");
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    NSLog(@"收到响应...");
    if ([self.delegate respondsToSelector:@selector(requestStatus:msg:)]) {
        [self.delegate requestStatus:3 msg:@"decidePolicyForNavigationResponse"];
    }
    if (self.canShowRequestStatus) {
        self.requestStatus(3, @"decidePolicyForNavigationResponse");
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    NSLog(@"获取内容...");
    if ([self.delegate respondsToSelector:@selector(requestStatus:msg:)]) {
        [self.delegate requestStatus:4 msg:@"didCommitNavigation"];
    }
    if (self.canShowRequestStatus) {
        self.requestStatus(4, @"didCommitNavigation");
    }
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    NSLog(@"加载结束...");
    self.ocCallJS = YES;
    if ([self.delegate respondsToSelector:@selector(requestStatus:msg:)]) {
        [self.delegate requestStatus:5 msg:@"didFinishNavigation"];
    }
    if (self.canShowRequestStatus) {
        self.requestStatus(5, @"didFinishNavigation");
    }
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    NSLog(@"加载失败...");
    if ([self.delegate respondsToSelector:@selector(requestStatus:msg:)]) {
        [self.delegate requestStatus:0 msg:@"didFailProvisionalNavigation"];
    }
    if (self.canShowRequestStatus) {
        self.requestStatus(0, @"didFailProvisionalNavigation");
    }
}

#pragma mark - WKUIDelegate
#pragma mark alert(message)
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                             message:message?:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert = [UIAlertAction actionWithTitle:@"取消"
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction * _Nonnull action)
                            {
                                NSLog(@"Alert取消");
                                completionHandler();
                            }];
    [alertController addAction:alert];
    if ([self.delegate respondsToSelector:@selector(showAlert:tag:)]) {
        [self.delegate showAlert:alertController tag:@"Alert"];
    }
    if (self.canShowAlertStatus) {
        self.showAlert(alertController, @"Alert");
    }
//    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark confirm(message)
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                             message:message?:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action)
                             {
                                 NSLog(@"Confirm取消");
                                 completionHandler(NO);
                             }];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  NSLog(@"Confirm确认");
                                  completionHandler(YES);
                              }];
    [alertController addAction:cancel];
    [alertController addAction:conform];
    if ([self.delegate respondsToSelector:@selector(showAlert:tag:)]) {
        [self.delegate showAlert:alertController tag:@"Confirm"];
    }
    if (self.canShowAlertStatus) {
        self.showAlert(alertController, @"Confirm");
    }
//    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark prompt(prompt, defaultText)
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt?:@""
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];

    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  NSLog(@"Prompt确认");
                                  completionHandler(alertController.textFields[0].text?:@"");
                              }];

    [alertController addAction:conform];
    if ([self.delegate respondsToSelector:@selector(showAlert:tag:)]) {
        [self.delegate showAlert:alertController tag:@"Prompt"];
    }
    if (self.canShowAlertStatus) {
        self.showAlert(alertController, @"Prompt");
    }
//    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark 弹出窗口
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - OC调用JS
- (void)ocToJSWithStr:(NSString *)jsCode
{
    if (jsCode.length==0 || !self.canOCCallJS) {
        return;
    }
    [self.webView evaluateJavaScript:jsCode
                   completionHandler:^(id _Nullable data, NSError * _Nullable error)
     {
         NSLog(@"OC调用JS成功！");
     }];
}

#pragma mark - JS调用OC
- (void)jsToOC
{
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [self.webView configuration].userContentController = wkUController;
    //使用代理
    self.jsManager = [[WKWebViewJSTool alloc] initWithDelegate:self];
    [[self.webView configuration].userContentController addScriptMessageHandler:self.jsManager name:@"JSOCBridge"];
}
- (void)messageWithName:(NSString *)name body:(id)body
{
    if ([name caseInsensitiveCompare:@"JSOCBridge"] == NSOrderedSame ||
        [name isEqualToString:@"JSOCBridge"]) {
        if ([body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *parameter = (NSDictionary *)body;
            NSString *action = [self decodeURLWithStr:parameter[@"action"]];
            NSString *params = [self decodeURLWithStr:parameter[@"params"]];
            NSLog(@"JS调用了OC，%@ : %@", action, params);
            
            if ([self.delegate respondsToSelector:@selector(jsCallOC:body:)]) {
                [self.delegate jsCallOC:action body:params];
            }
            if (self.canJSCallOC) {
                self.jsCallOCStatus(action, params);
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(jsCallOC:body:)]) {
                [self.delegate jsCallOC:@"JSOCBridge" body:body];
            }
            if (self.canJSCallOC) {
                self.jsCallOCStatus(@"JSOCBridge", body);
            }
        }
    }
}

#pragma mark - 添加进度条
- (void)showRequestProgress
{
    NSLog(@"添加进度条KVO");
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:0
                      context:nil];
    //添加监测网页标题title的观察者
//    [self.webView addObserver:self
//                   forKeyPath:@"title"
//                      options:NSKeyValueObservingOptionNew
//                      context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
//    id oldProgress = [change objectForKey:NSKeyValueChangeOldKey];
//    id newProgress = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (object == self.webView) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
//            NSLog(@"网页加载进度:%f", self.webView.estimatedProgress);
            if ([self.delegate respondsToSelector:@selector(requestProgress:)]) {
                [self.delegate requestProgress:self.webView.estimatedProgress];
            }
            if (self.canShowProgress) {
                self.requestProgress(self.webView.estimatedProgress);
            }
//            if (self.webView.estimatedProgress >= 1.0f) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    //进度条重置或隐藏
//                });
//            }
        }
//        if([keyPath isEqualToString:@"title"]) {
//            NSLog(@"网页标题:%@", self.webView.title);
//        }
    }else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
- (void)dealloc {
    NSLog(@"移除KVO");
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
//    [self.webView removeObserver:self forKeyPath:@"title"];
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"JSOCBridge"];
}

#pragma mark - 懒加载
- (WKWebView *)webView{
    if (!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//        //使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
//        config.allowsInlineMediaPlayback = YES;
//        //背景音乐不自动播放
//        config.mediaPlaybackRequiresUserAction = NO;
//        if (@available(iOS 9.0, *)) {
//            //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
//            config.requiresUserActionForMediaPlayback = YES;
//            //设置是否允许画中画技术 在特定设备上有效
//            config.allowsPictureInPictureMediaPlayback = YES;
//            //设置请求的User-Agent信息中应用程序名称 iOS9后可用
//            //config.applicationNameForUserAgent = @"xxxApp";
//        }
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
//        _webView = [WKWebView new];
        
        _webView.backgroundColor = [UIColor clearColor];
//        _webView.scrollView.bounces = NO;
//        _webView.scrollView.scrollEnabled = NO;
        _webView.layer.borderColor = [UIColor purpleColor].CGColor;
        _webView.layer.borderWidth = 1;
        
//        _webView.navigationDelegate = self;
//        _webView.UIDelegate = self;
        
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
//比较网络数据是否有变化，没有变化则使用缓存，否则从新请求
//        [_webView reloadFromOrigin];
//可返回的页面列表, 存储已打开过的网页, 可以跳转到某个指定历史页面
//        WKBackForwardList *backForwardList = [_webView backForwardList];
//        [_webView goToBackForwardListItem:[backForwardList backItem]];
        
//        _webView.allowsBackForwardNavigationGestures = YES;//是否允许左右划手势导航，默认不允许
//        _webView.estimatedProgress//加载进度
//        _webView.title//标题
    }
    return _webView;
}

- (NSURL *)remoteUrl{
    if (!_remoteUrl){
        if (self.remoteUrlStr.length) {
            _remoteUrl = [NSURL URLWithString:[self encodeURLWithStr:self.remoteUrlStr]];
        }else{
            _remoteUrl = [NSURL URLWithString:@""];
        }
        NSLog(@"remoteUrl请求地址:%@", [_remoteUrl absoluteString]);
    }
    return _remoteUrl;
}

- (NSString *)localHtmlContent{
    if (!_localHtmlContent){
        if (self.pathFileStr.length) {
            NSString *pathStr = [[NSBundle mainBundle] pathForResource:self.pathFileStr ofType:nil];
//            self.remoteUrl = [NSURL fileURLWithPath:pathStr];
//            self.remoteUrl = [[NSBundle mainBundle] URLForResource:self.pathFileStr withExtension:nil];
            
            _localHtmlContent = [NSString stringWithContentsOfFile:pathStr
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
        }else{
            _localHtmlContent = @"";
        }
    }
    return _localHtmlContent;
}

- (void)setShowRequestStatus:(BOOL)isShowRequestStatus{
    _showRequestStatus = isShowRequestStatus;
    if (_showRequestStatus) {
        self.webView.navigationDelegate = self;
    }
}

- (void)setShowAlertStatus:(BOOL)isShowAlertStatus{
    _showAlertStatus = isShowAlertStatus;
    if (_showAlertStatus) {
         self.webView.UIDelegate = self;
    }
}

- (void)setShowProgress:(BOOL)isShowProgress{
    _showProgress = isShowProgress;
    if (_showProgress) {
        [self showRequestProgress];
    }
}

- (void)setJsCallOC:(BOOL)isJSCallOC{
    _jsCallOC = isJSCallOC;
    if (_jsCallOC) {
        [self jsToOC];
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
