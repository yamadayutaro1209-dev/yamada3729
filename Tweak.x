#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

// グローバル管理
static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

// --- URL生成（30秒署名） ---
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
    self.view.backgroundColor = [UIColor whiteColor];
    
    // WebViewの作成
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];

    // 閉じるボタン（右上の小さな「×」）
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(self.view.frame.size.width - 50, 40, 40, 40);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];

    [self loadPage];
}

- (void)loadPage {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:generate_secure_gate()]]];
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 特定のURLで自動で閉じる設定
    if ([webView.URL.absoluteString containsString:@"complete_success"]) {
        [self closeAction];
    }
}
@end

// --- ボタンクリック時の処理を管理するクラス ---
@interface MenuHandler : NSObject
+ (void)handleBtnClick;
@end

@implementation MenuHandler
+ (void)handleBtnClick {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject; break;
            }
        }
    }
    if (!window) window = [UIApplication sharedApplication].windows.firstObject;

    if (!authVC) authVC = [[AuthViewController alloc] init];
    authVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [window.rootViewController presentViewController:authVC animated:YES completion:nil];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // 1. 最初の表示
            [MenuHandler handleBtnClick];

            // 2. 邪魔にならないフローティングボタンの作成
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(20, 150, 44, 44); // 左上の方
            menuButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            menuButton.layer.cornerRadius = 22;
            [menuButton setTitle:@"🔐" forState:UIControlStateNormal];
            
            // 重要：ターゲットを正しく設定（フックを使わない）
            [menuButton addTarget:[MenuHandler class] action:@selector(handleBtnClick) forControlEvents:UIControlEventTouchUpInside];
            
            [window addSubview:menuButton];
        });
    }];
}
