#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0xM : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0xW;
@property (nonatomic, strong) UIButton *_0xC; // 閉じボタン
@end

static UIButton *_0xB = nil; // MODボタン
static _0xM *_0xV = nil;      // メニュー画面

@implementation _0xM
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 窓のデザイン
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = NO; // 閉じボタンを少しはみ出させるためNO
    self.view.layer.borderWidth = 1.5;
    self.view.layer.borderColor = [UIColor cyanColor].CGColor;

    // --- 閉じボタン (右上) ---
    self._0xC = [UIButton buttonWithType:UIButtonTypeCustom];
    self._0xC.frame = CGRectMake(self.view.frame.size.width - 35, -10, 45, 45);
    [self._0xC setTitle:@"✕" forState:UIControlStateNormal];
    [self._0xC setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self._0xC.backgroundColor = [UIColor redColor];
    self._0xC.layer.cornerRadius = 22.5;
    [self._0xC addTarget:self action:@selector(_0xHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self._0xC];

    // --- ドラッグ用ジェスチャー (小窓を動かす) ---
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_0xDragMenu:)];
    [self.view addGestureRecognizer:pan];

    // WebView設定
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    [c.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    self._0xW = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:c];
    self._0xW.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self._0xW.scrollView.bounces = NO;
    self._0xW.scrollView.scrollEnabled = NO;
    self._0xW.navigationDelegate = self;
    self._0xW.layer.cornerRadius = 20;
    self._0xW.layer.masksToBounds = YES;
    [self.view addSubview:self._0xW];

    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *url = [NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u];
    [self._0xW loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

// 小窓を隠してMODボタンを出す
- (void)_0xHideSelf {
    [UIView animateWithDuration:0.2 animations:^{ self.view.alpha = 0; } completion:^(BOOL f){ 
        self.view.hidden = YES; 
        _0xB.hidden = NO; 
    }];
}

// 小窓をドラッグする処理
- (void)_0xDragMenu:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

// HTML側からのメッセージ受け取り
- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"closeHandler"]) [self _0xHideSelf];
}
@end

@interface _0xH : NSObject
@end
@implementation _0xH
// MODボタンからメニューを開く
+ (void)_0xShow {
    _0xV.view.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{ _0xV.view.alpha = 1; }];
    _0xB.hidden = YES;
}
// MODボタンをドラッグする処理
+ (void)_0xDragBtn:(UIPanGestureRecognizer *)p {
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

            // 1. メニュー画面 (300x350)
            _0xV = [[_0xM alloc] init];
            _0xV.view.frame = CGRectMake((w.bounds.size.width-300)/2, (w.bounds.size.height-350)/2, 300, 350);
            _0xV.view.hidden = NO;
            [w addSubview:_0xV.view];

            // 2. MODボタン (浮遊ボタン)
            _0xB = [UIButton buttonWithType:UIButtonTypeCustom];
            _0xB.frame = CGRectMake(20, 150, 50, 50);
            _0xB.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.6];
            _0xB.layer.cornerRadius = 25;
            _0xB.layer.borderWidth = 1;
            _0xB.layer.borderColor = [UIColor whiteColor].CGColor;
            [_0xB setTitle:@"MOD" forState:UIControlStateNormal];
            [_0xB addTarget:[_0xH class] action:@selector(_0xShow) forControlEvents:UIControlEventTouchUpInside];
            [_0xB addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[_0xH class] action:@selector(_0xDragBtn:)]];
            _0xB.hidden = YES; // 最初はメニューが出ているので隠しておく
            [w addSubview:_0xB];
        });
    }];
}
