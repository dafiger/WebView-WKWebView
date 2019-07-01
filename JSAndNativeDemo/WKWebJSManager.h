//
//  WKWebJSManager.h
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
- (void)jsCallOC:(NSString *)action params:(NSString *)params;

@end

@interface WKWebJSManager : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<JSCallOCDelegate> delegate;
@property (nonatomic, copy) NSString *nameStr;

- (instancetype)initWithName:(NSString *)nameStr
                    delegate:(id<JSCallOCDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
