//
//  WebViewTest.h
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/26.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewTest : UIViewController
//网络资源
@property (nonatomic, copy) NSString *remoteUrlStr;
//本地资源
@property (nonatomic, copy) NSString *localPathStr;

@end

NS_ASSUME_NONNULL_END
