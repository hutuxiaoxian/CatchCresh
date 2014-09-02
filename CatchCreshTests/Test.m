//
//  Test.m
//  CatchCresh
//
//  Created by 糊涂 on 14-9-2.
//  Copyright (c) 2014年 hutu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CatchCresh.h"

@interface Test : XCTestCase<crashDelegate>

@end

@implementation Test

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [CatchCresh crashCatchWithDeleate:self];
}

-(void)catchException:(NSException *)exception{
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDictionary *userInfo = [exception userInfo];
    
    NSLog(@"reason %@,name %@,userInfo %@",reason,name,userInfo);
}

@end
