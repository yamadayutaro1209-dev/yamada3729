#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"closeHandler"];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];

    // 初回読み込み（main.php）
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://webudid.gt.tc/main.php"]]];
}

// ページ遷移の監視（ここで「閉じられるかどうか」を判定）
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *url = webView.URL.absoluteString;
    
    // script.html内の「ゲーム開始」ボタン（URLにstart_game_nowを含む）を押した時だけ閉じる
    if ([url containsString:@"start_game_now"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
            menuButton.hidden = NO; // 認証後はMODボタンを表示
        });
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"closeHandler"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

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

@interface ButtonHandler : NSObject
@end
@implementation ButtonHandler
+ (void)showMenu {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (!authVC) authVC = [[AuthViewController alloc] init];
    if (window.rootViewController.presentedViewController) return;
    authVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [window.rootViewController presentViewController:authVC animated:YES completion:nil];
}
+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *btn = p.view;
    CGPoint t = [p translationInView:btn.superview];
    btn.center = CGPointMake(btn.center.x + t.x, btn.center.y + t.y);
    [p setTranslation:CGPointZero inView:btn.superview];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(20, 150, 55, 55);
            menuButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
            menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
            menuButton.layer.borderWidth = 1.5;
            menuButton.layer.cornerRadius = 27.5;
            [menuButton setTitle:@"MOD" forState:UIControlStateNormal];
            menuButton.hidden = YES; // 最初は隠しておく（認証成功で出す）
            
            [menuButton addTarget:[ButtonHandler class] action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[ButtonHandler class] action:@selector(handlePan:)];
            [menuButton addGestureRecognizer:pan];
            [window addSubview:menuButton];
            
            [ButtonHandler showMenu]; // 起動時に強制表示
        });
    }];
}
