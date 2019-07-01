//
//  WKWebViewTest.m
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/27.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import "WKWebViewTest.h"
#import <WebKit/WebKit.h>
#import "WKWebJSManager.h"

@interface WKWebViewTest ()<WKNavigationDelegate, WKUIDelegate, JSCallOCDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

//网络资源
@property (nonatomic, strong) NSURL *remoteUrl;
//本地资源
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *localHtmlContent;

@end

@implementation WKWebViewTest

- (void)viewDidLoad {
    [super viewDidLoad];
    self.remoteUrlStr = @"http://localhost:9080/index.html";
    self.localPathStr = @"index.html";
    
    self.webView.frame = CGRectMake(5, 70, 365, 500);
    [self.view addSubview:self.webView];
    [self showProgress];
    [self updteRequest];
}

#pragma mark - 更新请求
- (void)updteRequest
{
    //加载本地内容
    if (@available(iOS 9.0, *)) {
        [self.webView loadFileURL:[NSURL fileURLWithPath:self.localPath] allowingReadAccessToURL:[NSURL fileURLWithPath:self.localPath]];
    } else {
        [self.webView loadHTMLString:self.localHtmlContent baseURL:nil];
    }
    
//    [self.webView loadHTMLString:self.localHtmlContent baseURL:nil];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.localPath]];
    
    //加载网络内容
//    NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.remoteUrl]
//                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                         timeoutInterval:10.0];
//    [self.webView loadRequest:request];
}

#pragma mark - 三个是否允许加载函数
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //1、在发送请求之前，决定是否跳转。\
         decisionHandler必须调用，来决定是否跳转，\
         WKNavigationActionPolicyCancel取消跳转，\
         WKNavigationActionPolicyAllow允许跳转
    NSLog(@"发送请求之前...");
    NSString *requestString = [[[navigationAction.request URL] absoluteString] stringByRemovingPercentEncoding];
    NSLog(@"拦截请求-->:%@",requestString);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    //3、在收到服务器的响应头，根据response相关信息，决定是否跳转。\
    decisionHandler必须调用，来决定是否跳转，\
    WKNavigationResponsePolicyCancel取消跳转，\
    WKNavigationResponsePolicyAllow允许跳转
    NSLog(@"收到服务器的响应头...");
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    //接收到服务器跳转请求之后调用 (服务器端redirect)，不一定调用
//    NSLog(@"接收到服务器跳转请求...");
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    //需要响应身份验证时调用
//    NSLog(@"用户身份信息...");
//    NSURLCredential *newCred = [[NSURLCredential alloc] initWithUser:@"user123"
//                                                            password:@"123"
//                                                         persistence:NSURLCredentialPersistenceNone];
//    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential, newCred);
}

#pragma mark - 追踪加载过程函数
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //2、页面开始加载
    NSLog(@"开始加载...");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    //4、开始获取到网页内容时返回
    NSLog(@"开始获取到网页内容...");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //5、页面加载完成之后调用
    NSLog(@"加载结束...");
//    [self ocCallJS];
    [self jsCallOC];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //页面加载失败时调用
    NSLog(@"加载失败...");
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //提交发生错误时调用
//    NSLog(@"提交发生错误...");
}

#pragma mark - 三种提示框：输入、确认、警告
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    //输入框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  NSLog(@"点击了输入框OK按钮");
                                  completionHandler(alertController.textFields[0].text?:@"");
                              }];
    
    [alertController addAction:conform];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    //确认框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message?:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action)
                             {
                                 NSLog(@"点击了确认框Cancel按钮");
                                 completionHandler(NO);
                             }];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action)
                             {
                                 NSLog(@"点击了确认框OK按钮");
                                 completionHandler(YES);
                             }];
    [alertController addAction:cancel];
    [alertController addAction:conform];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    //警告框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的警告框"
                                                                             message:message?:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action)
                              {
                                  NSLog(@"点击了警告框OK按钮");
                                  completionHandler();
                              }];
    [alertController addAction:conform];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    //页面是弹出窗口
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - OC调用JS
- (void)ocCallJS
{
//    NSString *jsCode = [NSString stringWithFormat:@"showMsg(\'OC调用JS成功！\')"];
    NSString *jsCode = [NSString stringWithFormat:@"jsCallOC(\'对应oc方法名\', \'参数json1\')"];
    [self.webView evaluateJavaScript:jsCode
                   completionHandler:^(id _Nullable data, NSError * _Nullable error)
    {
        NSLog(@"OC调用JS成功！");
    }];
    
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')", @"#FFFF11"];
    [self.webView evaluateJavaScript:jsString
                   completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"改变HTML的背景色");
    }];
    
    NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", arc4random()%99 + 100];
    [self.webView evaluateJavaScript:jsFont
                   completionHandler:nil];
}

#pragma mark - JS调用OC
- (void)jsCallOC
{
//    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [self.webView configuration].userContentController = wkUController;
    //使用代理
    WKWebJSManager *jsManager = [[WKWebJSManager alloc] initWithName:@"JSOCBridge" delegate:self];
    [[self.webView configuration].userContentController addScriptMessageHandler:jsManager name:jsManager.nameStr];
}
- (void)jsCallOC:(NSString *)action params:(NSString *)params
{
    NSLog(@"JS调用OC成功！");
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [[self.webView configuration].userContentController addScriptMessageHandler:self name:@"JSOCBridge"];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"JSOCBridge"];
//}

#pragma mark - 进行JavaScript注入
- (void)addUserScript
{
    //1、创建网页配置对象
    WKPreferences *preference = [[WKPreferences alloc] init];
    //设置是否支持javaScript 默认是支持的
    preference.javaScriptEnabled = YES;
    //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
    preference.minimumFontSize = 0;
    //在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    [self.webView configuration].preferences = preference;
    
    //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
    //WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
    
    //2、这个类主要用来做native与JavaScript的交互管理
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    //注册一个name为jsCallOCNoParams的js方法
    [wkUController addScriptMessageHandler:self name:@"jsCallOCNoParams"];
    [wkUController addScriptMessageHandler:self name:@"jsCallOCWithParams"];
    [self.webView configuration].userContentController = wkUController;
    
    //3、以下代码适配文本大小，由UIWebView换为WKWebView后，会发现字体小了很多，这应该是WKWebView与html的兼容问题，解决办法是修改原网页，要么我们手动注入JS
    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    //用于进行JavaScript注入
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString
                                                     injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                  forMainFrameOnly:YES];
    [[self.webView configuration].userContentController addUserScript:wkUScript];
    //用完移除注册的js方法
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"jsCallOCNoParams"];
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"jsCallOCWithParams"];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
{
    //通过接收JS传出消息的name进行捕捉的回调方法
    NSLog(@"name:%@，body:%@，frameInfo:%@", message.name, message.body, message.frameInfo);
    //用message.body获得JS传出的参数体
    NSDictionary *parameter = message.body;
    //JS调用OC
    if([message.name isEqualToString:@"jsCallOCNoParams"]){
        NSLog(@"JS调用了OC，不带参数");
    }else if([message.name isEqualToString:@"jsToOcWithPrams"]){
        NSLog(@"JS调用了OC，参数：%@", parameter[@"params"]);
    }
}

#pragma mark - 添加进度条
- (void)showProgress
{
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:0
                      context:nil];
    //添加监测网页标题title的观察者
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
//    id oldName = [change objectForKey:NSKeyValueChangeOldKey];
//    NSLog(@"oldName----------%@",oldName);
//    id newName = [change objectForKey:NSKeyValueChangeNewKey];
//    NSLog(@"newName-----------%@",newName);
    
    if (object == self.webView) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
            NSLog(@"网页加载进度:%f", self.webView.estimatedProgress);
            if (self.webView.estimatedProgress >= 1.0f) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //进度条重置或隐藏
                });
            }
        }else if([keyPath isEqualToString:@"title"]) {
            NSLog(@"网页标题:%@", self.webView.title);
        }
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
    [self.webView removeObserver:self forKeyPath:@"title"];
}

#pragma mark - 懒加载
- (WKWebView *)webView{
    if (!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        //使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //背景音乐不自动播放
        config.mediaPlaybackRequiresUserAction = NO;
        if (@available(iOS 9.0, *)) {
            //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
            config.requiresUserActionForMediaPlayback = YES;
            //设置是否允许画中画技术 在特定设备上有效
            config.allowsPictureInPictureMediaPlayback = YES;
            //设置请求的User-Agent信息中应用程序名称 iOS9后可用
            //config.applicationNameForUserAgent = @"xxxApp";
        }
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
//        _webView = [WKWebView new];
        
        _webView.backgroundColor = [UIColor blackColor];
//        _webView.scrollView.bounces = NO;
//        _webView.scrollView.scrollEnabled = NO;
        _webView.layer.borderColor = [UIColor purpleColor].CGColor;
        _webView.layer.borderWidth = 1;
        
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        
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

@end
