#import <UIKit/UIKit.h>

// ★ サーバー側が https で真っ白なら、ここは http に戻して試してください
static NSString *authURL = @"http://webudid.gt.tc/check.php";

@interface AuthSystem : NSObject
@end

@implementation AuthSystem
+ (void)load {
    // アプリ起動から3秒待ってから実行（ESignでの安定性を高める）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startAuth];
    });
}

+ (void)startAuth {
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *fullUrl = [NSString stringWithFormat:@"%@?myid=%@", authURL, udid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl] 
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                         timeoutInterval:15.0];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *res = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";

        dispatch_async(dispatch_get_main_queue(), ^{
            // サーバーから ALLOWED が返ってこない場合のみブロック
            if (![res containsString:@"ALLOWED"]) {
                NSString *msg = [res containsString:@"WAITING"] ? 
                    @"【登録完了】管理パネルで「許可」を押してください。" : 
                    @"【未認証】あなたのIDを管理者に伝えてください。";

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証が必要" 
                    message:[NSString stringWithFormat:@"%@\n\nID: %@", msg, udid] 
                    preferredStyle:1];

                [alert addAction:[UIAlertAction actionWithTitle:@"IDコピーしてアプリ終了" style:2 handler:^(id a){
                    [UIPasteboard generalPasteboard].string = udid;
                    exit(0);
                }]];

                // 画面を表示
                UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
                [window.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
    }] resume];
}
@end
