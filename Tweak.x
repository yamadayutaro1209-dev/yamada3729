#import <UIKit/UIKit.h>

// ★ここを https ではなく http にして、最後に / を入れない
static NSString *authURL = @"http://webudid.gt.tc/check.php";

@interface AuthObject : NSObject
@end

@implementation AuthObject
+ (void)load {
    // 起動から5秒待つ（ネットワークが安定するまで待機）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *target = [NSString stringWithFormat:@"%@?myid=%@", authURL, udid];
        NSURL *url = [NSURL URLWithString:target];
        
        // 最もシンプルな通信
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *res = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 画面に状況を出す（これで何が起きているか分かります）
                if (![res containsString:@"ALLOWED"]) {
                    NSString *displayMsg = (res.length > 0) ? res : @"通信エラー（またはブロック）";
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auth Check" 
                        message:[NSString stringWithFormat:@"Status: %@\nID: %@", displayMsg, udid] 
                        preferredStyle:1];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Copy ID & Exit" style:2 handler:^(id a){
                        [UIPasteboard generalPasteboard].string = udid;
                        exit(0);
                    }]];
                    [[UIApplication sharedApplication].windows.firstObject.rootViewController presentViewController:alert animated:YES completion:nil];
                }
            });
        }] resume];
    });
}
@end
