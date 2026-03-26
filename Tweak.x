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
    // JSからの「closeHandler」命令を受け取る窓口
    [config.userContentController addScriptMessageHandler:self name:@"closeHandler"];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];

    // あなたのサーバーのURL
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://webudid.gt.tc/main.php"]]];
}

// 閉じる命令（closeHandler）を受信した時の処理
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"closeHandler"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// prompt() 入力欄の処理
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
    CGPoint translation = [p translationInView:btn.superview];
    btn.center = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    [p setTranslation:CGPointZero inView:btn.superview];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(20, 150, 60, 60);
            menuButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.3];
            menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
            menuButton.layer.borderWidth = 2.0;
            menuButton.layer.cornerRadius = 30;
            [menuButton setTitle:@"MOD" forState:UIControlStateNormal];
            menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            
            [menuButton addTarget:[ButtonHandler class] action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
            
            // ドラッグ移動機能
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[ButtonHandler class] action:@selector(handlePan:)];
            [menuButton addGestureRecognizer:pan];
            
            [window addSubview:menuButton];
            [ButtonHandler showMenu]; // 起動時に自動表示
        });
    }];
}
