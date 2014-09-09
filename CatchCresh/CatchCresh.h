//
//  CatchCresh.h
//  CatchCresh
//
//  Created by 糊涂 on 14-8-18.
//  Copyright (c) 2014年 hutu. All rights reserved.
//  能抓到Exception

#import <Foundation/Foundation.h>

@protocol crashDelegate <NSObject>
// 程序崩溃后回调此方法,请在这里重写崩溃日志的处理,崩溃信息保存在Exception中.
- (void)catchException:(NSException*)exception;

@end

@interface CatchCresh : NSObject
// 创建监听崩溃对象,需要实现监听代理,delegate为空时,监听日志保存在lib目录的CreshLogs文件夹下
+ (void)crashCatchWithDelegate:(NSObject<crashDelegate>*)delegate;
@end
