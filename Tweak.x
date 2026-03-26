#import <UIKit/UIKit.h>

static NSString *authURL = @"http://webudid.gt.tc/check.php";

void verifyUser() {
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *checkUrl = [NSString stringWithFormat:@"%@?myid=%@", authURL, deviceId];

    NSError *error = nil;
    NSString *res = [NSString stringWithContentsOfURL:[NSURL URLWithString:checkUrl] encoding:NSUTF8StringEncoding error:&error];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([res isEqualToString:@"ALLOWED"]) {
            // 許可済み：そのまま遊べる
            NSLog(@"[Auth] Success");
        } else {
            // 未許可(WAITING) または バン(DENIED) の場合
            NSString *msg = [res isEqualToString:@"WAITING"] ? 
                @"あなたのIDをサーバーに飛ばしました。管理者の許可を待ってください。" : 
                @"この端末はバンされています。";

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証" message:[NSString stringWithFormat:@"%@\n\nID: %@", msg, deviceId] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"IDをコピーして終了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a){
                UIPasteboard.generalPasteboard.string = deviceId;
                exit(0);
            }]];

            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        verifyUser();
    }];
}
