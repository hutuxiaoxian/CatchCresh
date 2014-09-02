//
//  CatchCresh.h
//  CatchCresh
//
//  Created by 糊涂 on 14-8-18.
//  Copyright (c) 2014年 hutu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol crashDelegate <NSObject>

- (void)catchException:(NSException*)exception;

@end

@interface CatchCresh : NSObject

+ (void)crashCatchWithDeleate:(NSObject<crashDelegate>*)delegate;
@end
