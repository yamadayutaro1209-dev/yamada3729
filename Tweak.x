#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0xM : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0xW;
@end

static UIButton *_0xB = nil; // 浮遊ボタン
static _0xM *_0xV = nil;      // スクリプト画面

@implementation _0xM
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 背景を透明にして、角丸の小さなウィンドウを作る
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.view.layer.cornerRadius = 15;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = [UIColor cyanColor].CGColor;

    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    [c.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    
    // WebViewをこの小窓の中に収める
    self._0xW = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:c];
    self._0xW.backgroundColor = [UIColor clearColor];
    self._0xW.opaque = NO;
    self._0xW.navigationDelegate = self;
    [self.view addSubview:self._0xW];

    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *l = [NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u];
    [self._0xW loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:l]]];
}

// 閉じるとき：消さずに「隠す」だけにする
- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"closeHandler"]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0;
            self.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL f){
            self.view.hidden = YES;
            _0xB.hidden = NO; // ボタンを再表示
        }];
    }
}
@end

@interface _0xH : NSObject
@end
@implementation _0xH
// 開くとき
+ (void)_0xShow {
    _0xV.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _0xV.view.alpha = 1;
        _0xV.view.transform = CGAffineTransformIdentity;
    }];
    _0xB.hidden = YES; // ボタンを隠す
}

+ (void)_0xDrag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *w = [UIApplication sharedApplication].windows.firstObject;

            // --- 1. スクリプト画面のサイズを指定 (ここを小さく設定) ---
            _0xV = [[_0xM alloc] init];
            // 画面の中央に 300x400 のサイズで作成
            _0xV.view.frame = CGRectMake((w.bounds.size.width-300)/2, (w.bounds.size.height-400)/2, 300, 400);
            _0xV.view.hidden = YES;
            _0xV.view.alpha = 0;
            [w addSubview:_0xV.view];

            // --- 2. 浮遊ボタン ---
            _0xB = [UIButton buttonWithType:UIButtonTypeCustom];
            _0xB.frame = CGRectMake(20, 150, 50, 50);
            _0xB.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
            _0xB.layer.cornerRadius = 25;
            [_0xB setTitle:@"MOD" forState:UIControlStateNormal];
            [_0xB addTarget:[_0xH class] action:@selector(_0xShow) forControlEvents:UIControlEventTouchUpInside];
            [_0xB addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[_0xH class] action:@selector(_0xDrag:)]];
            [w addSubview:_0xB];
            
            // 初回起動時もこの Show を呼ぶ
            [_0xH _0xShow];
        });
    }];
}
