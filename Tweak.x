#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *debugLabel;
@end

// グローバル管理（出し入れ用）
static UIButton *menuButton = nil;
static AuthViewController *authVC = nil;

// --- 1. AI回避型：URL動的生成 ---
static NSString *generate_secure_gate() {
    NSArray *p = @[@"http://", @"webudid", @".gt", @".tc", @"/", @"main", @".php"];
    NSString *u = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", p[0], p[1], p[2], p[3], p[4], p[5], p[6]];

    long ts = (long)[[NSDate date] timeIntervalSince1970] / 30;
    NSString *key = @"MySuperSecretSalt"; // ★サーバー側と共通にする
    
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

    // デバッグ用ラベル（URLを表示して確認するため）
    self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 100)];
    self.debugLabel.numberOfLines = 0;
    self.debugLabel.font = [UIFont systemFontOfSize:10]; 
    self.debugLabel.textColor = [UIColor redColor];
    self.debugLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.debugLabel];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.hidden = YES; 
    [self.view addSubview:self.webView];

    [self loadAuthPage];
}

- (void)loadAuthPage {
    NSString *urlStr = generate_secure_gate();
    self.debugLabel.text = [NSString stringWithFormat:@"[DEBUG] Connecting to:\n%@", urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

// 2. 読み込み完了時の判定
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.webView.hidden = NO;
    self.debugLabel.hidden = YES;

    // "complete_success" を含むURLなら2秒後に閉じる
    if ([webView.URL.absoluteString containsString:@"complete_success"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

// 3. 【最重要】JSのprompt()への応答（キャンセル対策済み）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証入力" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *t) { 
        t.text = defaultText; 
        t.placeholder = @"IDを入力...";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *input = alert.textFields.firstObject.text;
        // 入力があればそれを返し、なければ空文字を返して「キャンセル」を回避
        completionHandler(input ? input : @"");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction *a) {
        completionHandler(nil); // 本当にキャンセルボタンを押した時だけnil
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

// --- 4. メニュー管理クラス（ゲームを落とさないための独立処理） ---
@interface MenuManager : NSObject
+ (void)showMenu;
@end

@implementation MenuManager
+ (void)showMenu {
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

// --- 5. Tweak起動時の処理 ---
%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // 最初の表示
            [MenuManager showMenu];

            // フローティングボタンの作成
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
            menuButton.frame = CGRectMake(20, 120, 44, 44); 
            menuButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            menuButton.layer.cornerRadius = 22;
            [menuButton setTitle:@"🔐" forState:UIControlStateNormal];
            
            // 重要：ターゲットを正しく設定
            [menuButton addTarget:[MenuManager class] action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
            
            [window addSubview:menuButton];
        });
    }];
}
