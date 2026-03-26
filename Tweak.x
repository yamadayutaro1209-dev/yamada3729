#import <UIKit/UIKit.h>

static NSString *authURL = @"https://webudid.gt.tc/check.php"; // httpsに修正

void check() {
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?myid=%@", authURL, udid]];
    
    // サーバーに送信
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (!d) return;
        NSString *res = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![res containsString:@"ALLOWED"]) {
                // 許可されてない時だけ邪魔をする
                UIAlertController *a = [UIAlertController alertControllerWithTitle:@"認証" message:[NSString stringWithFormat:@"管理者に許可を求めてください\nID: %@", udid] preferredStyle:1];
                [a addAction:[UIAlertAction actionWithTitle:@"コピーして終了" style:2 handler:^(id x){
                    [UIPasteboard generalPasteboard].string = udid;
                    exit(0);
                }]];
                [[UIApplication sharedApplication].windows.firstObject.rootViewController presentViewController:a animated:YES completion:nil];
            }
        });
    }] resume];
}

// アプリのどこにでも効くように設定
%ctor {
    // 起動して2秒後にチェック（これが一番落ちない）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        check();
    });
}
