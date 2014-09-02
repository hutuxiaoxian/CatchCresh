//
//  CatchCresh.m
//  CatchCresh
//
//  Created by 糊涂 on 14-8-18.
//  Copyright (c) 2014年 hutu. All rights reserved.
//

#import "CatchCresh.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

@implementation CatchCresh

#define UncaughtExceptionHandlerSignalExceptionName             @"UncaughtExceptionHandlerSignalExceptionName"
#define UncaughtExceptionHandlerSignalKey                       @"UncaughtExceptionHandlerSignalKey"
#define UncaughtExceptionHandlerAddressesKey                    @"UncaughtExceptionHandlerAddressesKey"

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;


static NSDate *dateError;
static NSObject<crashDelegate> *delegate;

+ (void)crashCatchWithDeleate:(id<crashDelegate>)_delegate{
    delegate = _delegate;
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
    signal(1, crashHandler);//程序挂起
    signal(2, crashHandler);//程序中断
    signal(3, crashHandler);//退出
    signal(4, crashHandler);//非法指令
    signal(5, crashHandler);
    signal(6, crashHandler);//意外中止(因程序错误)
    signal(7, crashHandler);
    signal(8, crashHandler);//浮点数异常
    signal(9, crashHandler);//被系统杀死
    signal(10, crashHandler);//总线错误
    signal(11, crashHandler);//内存段违规
    signal(12, crashHandler);//错误的系统参数调用
    signal(13, crashHandler);//读写通道不存在
    signal(14, crashHandler);//闹钟
    signal(15, crashHandler);
    signal(16, crashHandler);
    signal(17, crashHandler);
    signal(18, crashHandler);
    signal(19, crashHandler);
    signal(20, crashHandler);
    signal(21, crashHandler);
    signal(22, crashHandler);
    signal(23, crashHandler);
    signal(24, crashHandler);
    signal(25, crashHandler);
    signal(26, crashHandler);
    signal(27, crashHandler);
    signal(28, crashHandler);
    signal(29, crashHandler);
    signal(30, crashHandler);
    signal(31, crashHandler);
}

void UncaughtExceptionHandler(NSException *exception) {
    //    NSArray *arr = [exception callStackSymbols];
    
    [CatchCresh saveFileWithError:exception];
    
    
}


void crashHandler(int signal){
    
    NSString *str ;
    switch (signal) {
        case SIGHUP:
            str = @"挂起";
            break;
        case SIGINT:
            str = @"中断";
            break;
        case SIGQUIT:
            str = @"退出";
            break;
        case SIGILL:
            str = @"非法指令";
            break;
        case SIGTRAP:
            str = @"跟踪陷阱";
            break;
        case SIGABRT:
            str = @"中止(因程序错误)";
            break;
        case SIGFPE:
            str = @"浮点异常";
            break;
        case SIGKILL:
            str = @"被系统杀死";
            break;
        case SIGBUS:
            str = @"总线错误";
            break;
        case SIGSEGV:
            str = @"段违规";
            break;
        case SIGSYS:
            str = @"错误的系统参数调用";
            break;
        case SIGPIPE:
            str = @"读写通道不存在";
            break;
        default:
            str = @"其它";
            break;
    }
//    NSLog(@"这个回调了 %i %@", signal, str);
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount <= UncaughtExceptionMaximum) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
        NSArray *callStack = [CatchCresh backtrace];
        
        [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
        
        
        NSException *exception = [NSException
                                  exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                  reason:[NSString stringWithFormat:@"错误代码:%i , %@", signal, str]
                                  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]];
        
        [[[CatchCresh alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject:exception waitUntilDone:YES];
        
    }
    
}

+ (NSArray*) backtrace {
    void * callstack[128];
    int frames = backtrace(callstack, 128);
    char ** strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [[NSMutableArray alloc] initWithCapacity:frames];
    
    for (int i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)handleException:(NSException *)exception{
    if (delegate && [delegate respondsToSelector:@selector(catchException:)]) {
        [delegate catchException:exception];
    }else{
        [CatchCresh saveFileWithError:exception];
    }
}

+ (void)saveFileWithError:(NSException*)exception{
    
    
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDictionary *userInfo = [exception userInfo];
    
    //    NSLog(@"arr %@, reason %@, name %@",arr,reason,name);
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"异常名称:"];
    [str appendString:name];
    [str appendString:@"\n\n异常原因:"];
    [str appendString:reason];
    if (userInfo) {
        [str appendString:@"\n\n用户信息:\n"];
        for (NSString*key in [userInfo allKeys]) {
            [str appendString:[NSString stringWithFormat:@"%@ = %@\n", key ,[userInfo objectForKey:key]]];
        }
    }
    
    NSString *error = [[NSString alloc] initWithString:str];
    
    
    NSArray *arrf = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [arrf objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"CreshLogs"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (!dateError) {
        dateError = [NSDate date];
    }
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSString *fname = [format stringFromDate:dateError];
    
    if (![error hasPrefix:@"\n"]) {
        error = [@"\n" stringByAppendingString:error];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fpath = [path stringByAppendingPathComponent: fname];
        if (![fm fileExistsAtPath:path]) {
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if ([fm fileExistsAtPath:fpath]) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fpath];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[error dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle synchronizeFile];
            [fileHandle closeFile];
        }else{
            [fm createFileAtPath:fpath contents:nil attributes:nil];
            NSData *data = [error dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:fpath atomically:YES];
        }
    });
}

//启动时上传文件
+ (void)updataErrorFile{
    NSArray *arrf = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [arrf objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"CreshLogs"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *err;
    NSArray *arrFile = [fm contentsOfDirectoryAtPath:path error:&err];
    if (!err) {
        //上传文件
        for (NSString*fileName in arrFile) {
            NSString *fp = [path stringByAppendingPathComponent:fileName];
            NSData *dataFile = [NSData dataWithContentsOfFile:fp];
            
        }
    }
    
}

@end
