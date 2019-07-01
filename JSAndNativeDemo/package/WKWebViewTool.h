//
//  WKWebViewTool.h
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/28.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WKWebViewToolDelegate <NSObject>

@optional
//请求进度
- (void)requestStatus:(NSInteger)status msg:(NSString *)msg;
//加载进度
- (void)requestProgress:(double)progress;
//JS调用OC
- (void)jsCallOC:(NSString *)name body:(id)body;
//WKUIDelegate
- (void)showAlert:(UIAlertController *)alertControl tag:(NSString *)tagStr;

@end

@interface WKWebViewTool : UIView<WKNavigationDelegate, WKUIDelegate>//WKScriptMessageHandler>

@property (nonatomic, weak) id<WKWebViewToolDelegate> delegate;

@property (nonatomic, copy) typeof(void(^)(NSInteger status, NSString *msg))requestStatus;//请求进程状态
@property (nonatomic, copy) typeof(void(^)(double))requestProgress;//请求进度
@property (nonatomic, copy) typeof(void(^)(NSString *name, id body))jsCallOCStatus;//JS调用OC
@property (nonatomic, copy) typeof(void(^)(UIAlertController *alertControl, NSString *tagStr))showAlert;//WKUIDelegate

@property (nonatomic, copy) NSString *pathFileStr;
@property (nonatomic, copy) NSString *remoteUrlStr;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, assign, getter=canShowRequestStatus) BOOL showRequestStatus;
@property (nonatomic, assign, getter=canShowAlertStatus)   BOOL showAlertStatus;
@property (nonatomic, assign, getter=canShowProgress) BOOL showProgress;
@property (nonatomic, assign, getter=canOCCallJS)     BOOL ocCallJS;//默认YES
@property (nonatomic, assign, getter=canJSCallOC)     BOOL jsCallOC;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame
                    remoteUrl:(NSString *)remoteUrlStr
                  autoRequest:(BOOL)autoRequest;

#pragma mark - 发起请求
- (void)startRequest;

#pragma mark - OC调用JS
- (void)ocToJSWithStr:(NSString *)jsCode;

@end

NS_ASSUME_NONNULL_END
