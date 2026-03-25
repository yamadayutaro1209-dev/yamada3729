#import <UIKit/UIKit.h>

static NSString *authURL = @"http://webudid.gt.tc/check.php";

void verifyUser() {
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *checkUrl = [NSString stringWithFormat:@"%@?myid=%@", authURL, deviceId];

    NSError *error = nil;
    NSString *res = [NSString stringWithContentsOfURL:[NSURL URLWithString:checkUrl] encoding:NSUTF8StringEncoding error:&error];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([res isEqualToString:@"ALLOWED"]) {
            NSLog(@"[Auth] Success");
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証が必要です" 
                message:[NSString stringWithFormat:@"以下のIDを管理者に送ってください:\n\n%@", deviceId] 
                preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"IDをコピーして終了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [UIPasteboard generalPasteboard].string = deviceId;
                exit(0); 
            }]];

            // --- ここを修正：古い keyWindow を使わない書き方 ---
            UIWindow *window = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        window = scene.windows.firstObject;
                        break;
                    }
                }
            }
            if (!window) {
                window = [UIApplication sharedApplication].windows.firstObject;
            }
            
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        verifyUser();
    }];
}
