#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0xM : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0xW;
@property (nonatomic, strong) UIButton *_0xC; // これが表示切替（閉じ）ボタン
@end

static UIButton *_0xB = nil; // MODボタン（再表示用）
static _0xM *_0xV = nil;      // メニュー画面本体

@implementation _0xM
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 小窓のデザイン設定
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    self.view.layer.cornerRadius = 20;
    self.view.layer.borderWidth = 1.5;
    self.view.layer.borderColor = [UIColor cyanColor].CGColor;
    self.view.userInteractionEnabled = YES;

    // 2. ドラッグ機能（小窓のどこを触っても動かせる）
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_0xDragMenu:)];
    [self.view addGestureRecognizer:pan];

    // 3. 表示切替ボタン（右上の赤い✕ボタン）
    // 窓のサイズ(300x350)に合わせて、押しやすい位置に配置
    self._0xC = [UIButton buttonWithType:UIButtonTypeCustom];
    self._0xC.frame = CGRectMake(255, 5, 40, 40); // 右上に配置
    self._0xC.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.8];
    self._0xC.layer.cornerRadius = 20;
    [self._0xC setTitle:@"✕" forState:UIControlStateNormal];
    self._0xC.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self._0xC addTarget:self action:@selector(_0xHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self._0xC];
    [self.view bringSubviewToFront:self._0xC]; // ボタンを最前面に

    // 4. Web内容表示 (WebView)
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    [c.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    // ボタンと重ならないよう、少し下げて配置
    self._0xW = [[WKWebView alloc] initWithFrame:CGRectMake(0, 45, 300, 305) configuration:c];
    self._0xW.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self._0xW.scrollView.bounces = NO;
    self._0xW.scrollView.scrollEnabled = NO;
    self._0xW.navigationDelegate = self;
    self._0xW.backgroundColor = [UIColor clearColor];
    self._0xW.opaque = NO;
    [self.view addSubview:self._0xW];

    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *url = [NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u];
    [self._0xW loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

// 閉じボタンを押した時の処理
- (void)_0xHideSelf {
    [UIView animateWithDuration:0.2 animations:^{ self.view.alpha = 0; } completion:^(BOOL f){ 
        self.view.hidden = YES; 
        _0xB.hidden = NO; // MODボタンを出す
    }];
}

// ドラッグ移動の処理
- (void)_0xDragMenu:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}

- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"closeHandler"]) [self _0xHideSelf];
}
@end

@interface _0xH : NSObject
@end
@implementation _0xH
// MODボタン（再表示）を押した時の処理
+ (void)_0xShow {
    _0xV.view.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{ _0xV.view.alpha = 1; }];
    _0xB.hidden = YES; // MODボタンを隠す
}
// MODボタン自体のドラッグ移動
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

            // 初期位置：中央
            _0xV = [[_0xM alloc] init];
            _0xV.view.frame = CGRectMake((w.bounds.size.width-300)/2, (w.bounds.size.height-350)/2, 300, 350);
            [w addSubview:_0xV.view];

            // 浮遊する再表示用ボタン
            _0xB = [UIButton buttonWithType:UIButtonTypeCustom];
            _0xB.frame = CGRectMake(20, 150, 60, 60);
            _0xB.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.6];
            _0xB.layer.cornerRadius = 30;
            _0xB.layer.borderWidth = 1.5;
            _0xB.layer.borderColor = [UIColor whiteColor].CGColor;
            [_0xB setTitle:@"MOD" forState:UIControlStateNormal];
            [_0xB addTarget:[_0xH class] action:@selector(_0xShow) forControlEvents:UIControlEventTouchUpInside];
            [_0xB addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[_0xH class] action:@selector(_0xDragBtn:)]];
            _0xB.hidden = YES; // 最初はメニューが開いているので隠しておく
            [w addSubview:_0xB];
        });
    }];
}
