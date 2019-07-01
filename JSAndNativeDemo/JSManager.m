//
//  JSManager.m
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/27.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import "JSManager.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSToOCProtocol <JSExport>

JSExportAs(jsCallOC, - (void)jsToOC:(NSString *)action params:(NSString *)params);

@end

@interface JSManager ()<JSToOCProtocol>

@end

@implementation JSManager

- (instancetype)initWithDelegate:(id<JSCallOCDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)jsToOC:(NSString *)action params:(NSString *)params
{
    if ([self.delegate respondsToSelector:@selector(jsCallOC:params:)]) {
        [self.delegate jsCallOC:action params:params];
    }
}


@end
