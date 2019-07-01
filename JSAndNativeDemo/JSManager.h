//
//  JSManager.h
//  JSAndNativeDemo
//
//  Created by wangpf on 2019/6/27.
//  Copyright © 2019 dafiger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JSCallOCDelegate <NSObject>

@required
- (void)jsCallOC:(NSString *)action params:(NSString *)params;

@end

@interface JSManager : NSObject

@property (nonatomic, weak) id<JSCallOCDelegate> delegate;

- (instancetype)initWithDelegate:(id<JSCallOCDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
