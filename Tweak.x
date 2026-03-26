#import <UIKit/UIKit.h>

// ★ サーバー側が対応しているなら、ここを必ず https にしてください
static NSString *authURL = @"https://webudid.gt.tc/check.php";

@interface AuthEntry : NSObject
@end

@implementation AuthEntry
+ (void)load {
    // 起動して3秒後に実行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startVerification];
    });
}

+ (void)startVerification {
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *requestUrl = [NSString stringWithFormat:@"%@?myid=%@", authURL, udid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:20.0];

    // iOS標準の通信セッションを使用
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request 
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSString *res = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 成功（ALLOWED）以外はすべて警告を出す
                if (![res containsString:@"ALLOWED"]) {
                    NSString *status = (res.length > 0) ? res : @"SERVER_NO_RESPONSE";
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証システム" 
                        message:[NSString stringWithFormat:@"状態: %@\nID: %@", status, udid] 
                        preferredStyle:1];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:@"IDコピーして終了" style:2 handler:^(id a){
                        [UIPasteboard generalPasteboard].string = udid;
                        exit(0);
                    }]];

                    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
                    [window.rootViewController presentViewController:alert animated:YES completion:nil];
                }
            });
    }];
    [task resume];
}
@end
