#import <UIKit/UIKit.h>

// あなたのサーバーURL
static NSString *authURL = @"http://webudid.gt.tc/check.php";

void verifyUser() {
    // 端末固有のIDを取得
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *checkUrl = [NSString stringWithFormat:@"%@?myid=%@", authURL, deviceId];

    NSError *error = nil;
    NSString *res = [NSString stringWithContentsOfURL:[NSURL URLWithString:checkUrl] encoding:NSUTF8StringEncoding error:&error];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([res isEqualToString:@"ALLOWED"]) {
            // 認証成功：何もしない（そのまま遊べる）
            NSLog(@"[Auth] Success: Device is allowed.");
        } else {
            // 認証失敗：IDを表示してアプリを終了させる
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証が必要です" 
                message:[NSString stringWithFormat:@"以下のIDを管理者に送ってください:\n\n%@", deviceId] 
                preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"IDをコピーして終了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [UIPasteboard generalPasteboard].string = deviceId;
                exit(0); 
            }]];

            // 画面に表示
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

// アプリ起動時に実行
%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        verifyUser();
    }];
}
