#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

// --- URL生成（AI対策・隠蔽済み） ---
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
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.webView];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:generate_secure_gate()]]];
}

// ページ遷移の管理
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // URLに "exit_now" が含まれた時だけ自動で閉じる
    // これにより script.html は閉じずに表示され続けます
    if ([webView.URL.absoluteString containsString:@"exit_now"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

// Prompt（入力欄）の修正：OKで文字を返し、キャンセルでnilを返す
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *t) { t.text = defaultText; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *txt = alert.textFields.firstObject.text;
        completionHandler(txt ? txt : @"");
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
    
    // 既に開いているなら何もしない
    if (window.rootViewController.presentedViewController) return;

    authVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [window.rootViewController presentViewController:authVC animated:YES completion:nil];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [MenuManager toggleMenu];

            // フローティングボタン（左上に配置）
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(15, 120, 45, 45); 
            menuButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            menuButton.layer.cornerRadius = 22.5;
            [menuButton setTitle:@"🛠" forState:UIControlStateNormal];
            [menuButton addTarget:[MenuManager class] action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
            [window addSubview:menuButton];
        });
    }];
}
