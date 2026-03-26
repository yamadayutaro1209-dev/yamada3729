#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

// URL生成（隠蔽済み）
static NSString *generate_secure_gate() {
    NSArray *p = @[@"http://", @"webudid", @".gt", @".tc", @"/", @"main", @".php"];
    NSString *u = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", p[0], p[1], p[2], p[3], p[4], p[5], p[6]];
    long ts = (long)[[NSDate date] timeIntervalSince1970] / 30;
    NSString *key = @"MySuperSecretSalt"; 
    NSString *raw = [NSString stringWithFormat:@"%ld%@", ts, key];
    const char *cStr = [raw UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), r);
    NSString *sig = [NSString stringWithFormat:@"%02x%02x%02x%02x", r[0], r[1], r[2], r[3]];
    return [NSString stringWithFormat:@"%@?t=%ld&s=%@", u, ts, sig];
}

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor]; 

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // ★ここがポイント：JSからiOSを操作するための設定
    [config.userContentController addScriptMessageHandler:self name:@"closeHandler"];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.webView];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:generate_secure_gate()]]];
}

// ★JSから「closeHandler」が呼ばれたら画面を閉じる
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"closeHandler"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Prompt処理
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *t) { t.text = defaultText; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        completionHandler(alert.textFields.firstObject.text ?: @"");
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction *a) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

@interface MenuManager : NSObject
+ (void)toggleMenu;
@end

@implementation MenuManager
+ (void)toggleMenu {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (!authVC) authVC = [[AuthViewController alloc] init];
    if (window.rootViewController.presentedViewController) return;
    authVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [window.rootViewController presentViewController:authVC animated:YES completion:nil];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [MenuManager toggleMenu];
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(15, 120, 50, 50); 
            menuButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.3];
            menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
            menuButton.layer.borderWidth = 1.0;
            menuButton.layer.cornerRadius = 25;
            [menuButton setTitle:@"MOD" forState:UIControlStateNormal];
            [menuButton addTarget:[MenuManager class] action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
            [window addSubview:menuButton];
        });
    }];
}
