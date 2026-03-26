#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // JSから「閉じろ」という命令（message）を受け取る窓口
    [config.userContentController addScriptMessageHandler:self name:@"closeHandler"];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://webudid.gt.tc/main.php"]]];
}

// ページが読み終わるたびに、既存のボタンに「閉じろ」という機能を無理やり追加する
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // スクリプトを変更せずに、既存の「ゲーム開始」や「閉じる」ボタンに機能を上書きするJS
    NSString *injectJS = 
        @"var btns = document.getElementsByTagName('button');"
        "for (var i = 0; i < btns.length; i++) {"
        "  if (btns[i].innerText.indexOf('開始') !== -1 || btns[i].innerText.indexOf('閉じる') !== -1 || btns[i].innerText.indexOf('スタート') !== -1) {"
        "    btns[i].onclick = function() { window.webkit.messageHandlers.closeHandler.postMessage(null); };"
        "  }"
        "}";
    
    [webView evaluateJavaScript:injectJS completionHandler:nil];
}

// JSからの「閉じろ」命令が飛んできたら画面を閉じる
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"closeHandler"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        menuButton.hidden = NO; // 認証が終わったのでMODボタンを表示
    }
}
@end

// --- ボタンのドラッグ移動クラス（前回と同じ） ---
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(20, 150, 55, 55);
            menuButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
            menuButton.layer.borderColor = [UIColor cyanColor].CGColor;
            menuButton.layer.borderWidth = 2.0;
            menuButton.layer.cornerRadius = 27.5;
            [menuButton setTitle:@"MOD" forState:UIControlStateNormal];
            menuButton.hidden = YES;
            
            [menuButton addTarget:[ButtonHandler class] action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[ButtonHandler class] action:@selector(handlePan:)];
            [menuButton addGestureRecognizer:pan];
            [window addSubview:menuButton];
            
            [ButtonHandler showMenu];
        });
    }];
}
