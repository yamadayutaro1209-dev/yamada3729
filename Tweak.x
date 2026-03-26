#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *debugLabel;
@end

// ボタンを管理するためのグローバル変数
static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

// --- URL生成ロジック（前回と同じ） ---
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

    self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 100)];
    self.debugLabel.numberOfLines = 0;
    self.debugLabel.font = [UIFont systemFontOfSize:10];
    self.debugLabel.textColor = [UIColor redColor];
    self.debugLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.debugLabel];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.hidden = YES;
    [self.view addSubview:self.webView];

    [self loadAuthPage];
}

- (void)loadAuthPage {
    NSString *urlStr = generate_secure_gate();
    self.debugLabel.text = [NSString stringWithFormat:@"Loading...\n%@", urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.webView.hidden = NO;
    self.debugLabel.hidden = YES;
    
    // 成功ページに飛んだら「閉じる」
    if ([webView.URL.absoluteString containsString:@"complete_success"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// 閉じるボタン（右上にバツボタンが欲しい場合用）
- (void)addCloseButton {
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(self.view.frame.size.width - 60, 40, 40, 40);
    [close setTitle:@"✕" forState:UIControlStateNormal];
    [close addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:close];
}
- (void)closeMe { [self dismissViewControllerAnimated:YES completion:nil]; }

@end

// --- フローティングボタンの処理 ---
static void toggle_menu() {
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

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // 1. 最初の表示
            toggle_menu();

            // 2. フローティングボタンの作成
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(20, 100, 50, 50); // 左上に配置
            menuButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            menuButton.layer.cornerRadius = 25;
            [menuButton setTitle:@"🔑" forState:UIControlStateNormal];
            [menuButton addTarget:nil action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
            
            // ボタンをドラッグ可能にする（簡易版）
            [window addSubview:menuButton];
        });
    }];
}

// ボタンクリック時の挙動（本当はカテゴリ化が必要ですが、簡易的に）
%hook UIButton
- (void)btnClick { toggle_menu(); }
%end
