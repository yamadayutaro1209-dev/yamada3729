#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static NSString *authURL = @"http://webudid.gt.tc/main.html";

// WKUIDelegate を追加することで、prompt や alert を表示可能にします
@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ポップアップを許可する設定
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self; // ★これを追加：これで prompt が出せるようになります
    
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authURL]]];
}

// 認証後の画面遷移処理
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString containsString:@"script.html"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

// --- これがポップアップを出すための魔法のコード ---
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alert.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            AuthViewController *vc = [[AuthViewController alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            UIWindow *win = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *s in [UIApplication sharedApplication].connectedScenes) {
                    if (s.activationState == UISceneActivationStateForegroundActive) {
                        win = s.windows.firstObject; break;
                    }
                }
            }
            if (!win) win = [UIApplication sharedApplication].windows.firstObject;
            [win.rootViewController presentViewController:vc animated:YES completion:nil];
        });
    }];
}
