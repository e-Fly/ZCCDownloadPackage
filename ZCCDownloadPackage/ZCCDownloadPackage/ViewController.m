//
//  ViewController.m
//  ZCCDownloadPackage
//
//  Created by ZCC on 16/11/21.
//  Copyright © 2016年 ZCC公司名称. All rights reserved.
//

#import "ViewController.h"
#import "ZCCDownloadPackage.h"
#import "AFNetworking.h"
@interface ViewController ()
/** ZCCDownloadPackage*/
@property (nonatomic, strong) ZCCDownloadPackage *download;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *URL = @"URL";
    
    NSString *fileName = @"ZCC.zip";
    _download = [[ZCCDownloadPackage alloc] initDownloadTaskWithRequest:URL filePath:filePath fileName:fileName progress:^(double downloadProgress,double totalUnitCount,double completedUnitCount) {
        // totalUnitCount 文件总长度
        // completedUnitCount 已经下载的长度
        // downloadProgress下载进度
        NSLog(@"%f",downloadProgress);
        // 注意：这个Block是在子线程执行的更新UI需要在main_queue
        dispatch_async(dispatch_get_main_queue(), ^{
            //在此更新UI
        });
        
    } completionHandler:^(NSError * _Nullable error,NSString *filePath) {
        
        if (error) {
            NSLog(@"下载错误%@",error);
        }else
        {
            NSLog(@"下载成功");
        }
        // 注意：这个Block是在子线程执行的更新UI需要在main_queue
        dispatch_async(dispatch_get_main_queue(), ^{
            //在此更新UI
        });
    }];
}
/**
 *  不需要监听网络状态直接用下面方法就可以
 *  此方法目前没被调用
 */
- (void)startdown
{
    [_download startDownload];
}
/**
 *  开始下载
 */
- (IBAction)startBtnclick {
    // 开始网络监控
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"-----当前的网络状态---%zd", status);
        switch (status) {
                
            case AFNetworkReachabilityStatusNotReachable:{
                NSLog(@"无网络");
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                    NSLog(@"WiFi网络");
                //如果不需要监听网络状态可以直接调用这个方法
                    [_download startDownload];
                    break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                    NSLog(@"3G/4G网络");
                    [self alert];
                    break;
            }
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未知网络状态");
            }
            default:
                break;
        }
    }];
    [mgr startMonitoring];

    
}
/**
 *  暂停下载
 */
- (IBAction)pause {
    [_download pauseDownload];
}

- (void)alert
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"警告" message:@"您现在处于3G/4G流量状态，您是否继续下载" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"继续下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
        [_download startDownload];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"停止下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
        NSLog(@"停止下载");
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

@end
