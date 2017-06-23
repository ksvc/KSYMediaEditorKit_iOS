//
//  AppDelegate.m
//  demo
//
//  Created by 张俊 on 30/03/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "STFilterManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    UIViewController *viewController = [[ViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc]  initWithRootViewController:viewController];
    
    //VideoEditorViewController *vc = [[VideoEditorViewController alloc] initWithUrl:nil];
    //UINavigationController *navi = [[UINavigationController alloc]  initWithRootViewController:vc];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = navi;
    _window.backgroundColor = [UIColor whiteColor];
    _window.tintColor = [UIColor blackColor];
    [_window makeKeyAndVisible];
    
#if (DEBUG)
    #ifdef FILELOG_SUPPORT
    //    [self redirectNSlogToDocumentFolder];
    #endif
#else
    
#endif
    // 获取商汤SDK信息
    [[STFilterManager instance] fetchMaterialList];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - KSYClipLog
// 将NSlog打印信息保存到Document目录下的文件中
- (void)redirectNSlogToDocumentFolder
{
    //document文件夹
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //
    NSString *foldPath = [documentDirectory stringByAppendingFormat:@"/clipLogs"];
    
    //文件保护等级
    NSDictionary *attribute = [NSDictionary dictionaryWithObject:NSFileProtectionNone
                                                          forKey:NSFileProtectionKey];
    [[NSFileManager defaultManager] createDirectoryAtPath:foldPath withIntermediateDirectories:YES attributes:attribute error:nil];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [foldPath stringByAppendingFormat:@"/%@.log",dateStr];
    
    [AppDelegate checkFlieProtection:logFilePath];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (void)checkFlieProtection:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathSqlite = path;
    NSDictionary *attributeSql = [fileManager attributesOfItemAtPath:pathSqlite error:nil];
    if ([[attributeSql objectForKey:NSFileProtectionKey] isEqualToString:NSFileProtectionComplete]) {
        NSDictionary *attribute = [NSDictionary dictionaryWithObject:NSFileProtectionCompleteUntilFirstUserAuthentication
                                                              forKey:NSFileProtectionKey];
        [fileManager setAttributes:attribute ofItemAtPath:pathSqlite error:nil];
        NSLog(@"改变文件权限 %@ : %@",path,attribute);
    }
}

@end
