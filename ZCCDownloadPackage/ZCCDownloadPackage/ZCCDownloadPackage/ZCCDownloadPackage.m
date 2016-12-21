//
//  ZCCDownloadPackage.m
//  ZCCDownloadPackage
//
//  Created by ZCC on 16/11/21.
//  Copyright © 2016年 ZCC公司名称. All rights reserved.
//


// 文件名（沙盒中的文件名）
#define ZCCFilename self.fileName

// 文件的存放路径（caches）
#define ZCCFileFullpath [self.filePath stringByAppendingPathComponent:ZCCFilename]


// 存储文件总长度的文件路径（caches）
#define ZCCTotalLengthFullpath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZCCDownloadTotalLength.plist"]

// 文件的已下载长度
#define ZCCDownloadLength [[[NSFileManager defaultManager] attributesOfItemAtPath:ZCCFileFullpath error:nil][NSFileSize] doubleValue]


#import "ZCCDownloadPackage.h"

@interface ZCCDownloadPackage ()<NSURLSessionDataDelegate>
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** session */
@property (nonatomic, strong) NSURLSession *session;
/** 写文件的流对象 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件的总长度 */
@property (nonatomic, assign) double totalLength;
/** URL*/
@property (nonatomic, copy) NSString *url;
/** filePath*/
@property (nonatomic, copy) NSString *filePath;
/** 文件名字*/
@property (nonatomic, copy) NSString *fileName;

/** 进度的Block*/
@property (nonatomic, copy) void (^downloadProgressBlock)(double progress,double totalUnitCount,double completedUnitCount);
/** 现在完成的Block*/
@property (nonatomic, copy) void (^completionHandler)(NSError * _Nullable error,NSString *filePath);
@end

@implementation ZCCDownloadPackage



- (instancetype)initDownloadTaskWithRequest:(NSString *)url filePath:(NSString *)path fileName:(NSString *)name progress:(void (^)(double, double, double))downloadProgressBlock completionHandler:(void (^)(NSError * _Nullable, NSString *))completionHandler
{
    _url = url;
    _filePath = path;
    _fileName = name;
    self.downloadProgressBlock = downloadProgressBlock;
    self.completionHandler = completionHandler;
    return self;
}

- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:ZCCFileFullpath append:YES];
    }
    return _stream;
}

- (NSURLSessionDataTask *)task
{
    if (!_task) {
        NSInteger totalLength = [[NSDictionary dictionaryWithContentsOfFile:ZCCTotalLengthFullpath][ZCCFilename] integerValue];
        if (totalLength && ZCCDownloadLength == totalLength) {
            NSLog(@"----文件已经下载过了");
            return nil;
        }
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        
        // 设置请求头
        // Range : bytes=xxx-xxx
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", ZCCDownloadLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建一个Data任务
        _task = [self.session dataTaskWithRequest:request];
    }
    return _task;
}
/**
 *  开始下载和继续下载
 */
- (void)startDownload
{
    
    NSLog(@"文件下载的全路径--%@",ZCCFileFullpath);
    // 启动任务
    [self.task resume];
}

/**
 * 暂停下载
 */
- (void)pauseDownload
{
    [self.task suspend];
}

#pragma mark - <NSURLSessionDataDelegate>
/**
 * 1.接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [self.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] doubleValue] + ZCCDownloadLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZCCTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[ZCCFilename] = @(self.totalLength);
    [dict writeToFile:ZCCTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 2.接收到服务器返回的数据（这个方法可能会被调用N次）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [self.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(1.0 * ZCCDownloadLength / self.totalLength,self.totalLength,ZCCDownloadLength);
    }

}

/**
 * 3.请求完毕（成功\失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (self.completionHandler) {
        self.completionHandler(error,ZCCFileFullpath);
    }
    if (error) {
        // 清除任务
        self.stream = nil;
        self.task = nil;
        NSLog(@"下载错误--%@",error);
    }else
    {
        // 关闭流
        [self.stream close];
        self.stream = nil;
        // 清除任务
        self.task = nil;
    }
}

@end
