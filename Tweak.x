#import <UIKit/UIKit.h>

// ★あなたのサーバーURL（httpだとブロックされる可能性があるので注意）
static NSString *authURL = @"http://webudid.gt.tc/check.php";

@interface AuthManager : NSObject
+ (void)load;
@end

@implementation AuthManager

// アプリがメモリに読み込まれた瞬間に実行される（libsubstrate不要）
+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self verifyUser];
    });
}

+ (void)verifyUser {
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?myid=%@", authURL, deviceId]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *res = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";

        dispatch_async(dispatch_get_main_queue(), ^{
            // サーバーから ALLOWED が返ってこない限り、邪魔をする
            if (![res containsString:@"ALLOWED"]) {
                NSString *msg = [res containsString:@"WAITING"] ? @"【登録完了】管理者の許可待ちです。" : @"【未承認】アクセス権がありません。";
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証システム" 
                    message:[NSString stringWithFormat:@"%@\n\nID: %@", msg, deviceId] 
                    preferredStyle:1];

                [alert addAction:[UIAlertAction actionWithTitle:@"IDコピーして終了" style:2 handler:^(id a){
                    [UIPasteboard generalPasteboard].string = deviceId;
                    exit(0);
                }]];

                // 画面の一番上に表示
                UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
                [window.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
    }] resume];
}
@end
