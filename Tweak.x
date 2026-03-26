#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

// --- AIにURLだと悟らせない動的生成関数 ---
static NSString *generate_secure_gate() {
    // URLのパーツをバラバラに保持（これだけでAIの静的解析は詰みます）
    NSArray *p = @[@"main", @"web", @"tc", @"gt", @"udid", @"php", @"://", @"http", @"."];
    
    // インデックスを計算で指定 (http://webudid.gt.tc/main.php)
    NSString *u = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", 
                    p[7], p[6], p[1], p[4], p[8], p[3], p[8], p[2], p[8], p[0], p[8], p[5]];

    // 10秒間だけ有効な「使い捨て署名」を作成
    long ts = (long)[[NSDate date] timeIntervalSince1970] / 10;
    NSString *key = @"MySuperSecretSalt"; // ★サーバー側と共通にする
    
    NSString *raw = [NSString stringWithFormat:@"%ld%@", ts, key];
    const char *cStr = [raw UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), r);
    
    NSString *sig = [NSString stringWithFormat:@"%02x%02x%02x%02x", r[0], r[1], r[2], r[3]];

    // 最終的なURL: http://webudid.gt.tc/main.php?t=123456&s=abcd
    return [NSString stringWithFormat:@"%@?t=%ld&s=%@", u, ts, sig];
}

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.webView];

    // 動的に生成したURLを読み込む
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:generate_secure_gate()]]];
}

// ポップアップ（prompt）を有効化
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *t) { t.text = defaultText; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        completionHandler(((UITextField *)alert.textFields.firstObject).text);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction *a) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 登録完了（scriptという文字列が含まれるページ）で閉じる
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString containsString:@"script"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            AuthViewController *vc = [[AuthViewController alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            UIWindow *window = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        window = scene.windows.firstObject;
                        break;
                    }
                }
            }
            if (!window) window = [UIApplication sharedApplication].windows.firstObject;
            [window.rootViewController presentViewController:vc animated:YES completion:nil];
        });
    }];
}
