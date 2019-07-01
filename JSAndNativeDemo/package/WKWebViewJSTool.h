//
//  WKWebViewJSTool.h
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/28.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSCallOCDelegate <NSObject>

@required
- (void)messageWithName:(NSString *)name body:(id)body;

@end

@interface WKWebViewJSTool : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<JSCallOCDelegate> delegate;

- (instancetype)initWithDelegate:(id<JSCallOCDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
