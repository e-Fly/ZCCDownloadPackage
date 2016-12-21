//
//  ZCCDownloadPackage.h
//  ZCCDownloadPackage
//
//  Created by ZCC on 16/11/21.
//  Copyright © 2016年 ZCC公司名称. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCCDownloadPackage : NSObject
/**
 *  开始下载或继续下载
 */
- (void)startDownload;

/**
 * 暂停下载
 */
- (void)pauseDownload;

/**
 *  初始化下载
 *
 *  @param url                   下载的URL
 *  @param path                  文件路径
 *  @param name                  文件名
 *  @param downloadProgressBlock 返回进度的Block
 *  @param completionHandler     完成下载或下载失败的Block
 *
 */
- (instancetype _Nullable)initDownloadTaskWithRequest:(NSString * _Nullable)url filePath:(NSString * _Nullable)path fileName:(NSString * _Nullable)name
                                             progress:(nullable void (^)(double downloadProgress,double totalUnitCount,double completedUnitCount))downloadProgressBlock
                                    completionHandler:(nullable void (^)( NSError * _Nullable error,NSString * _Nullable filePath))completionHandler;
@end
