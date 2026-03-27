#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0xM : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0xW;
@property (nonatomic, strong) UIButton *_0xC; // 閉じボタン
@end

static UIButton *_0xB = nil; // MODボタン
static _0xM *_0xV = nil;

@implementation _0xM
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    self.view.layer.cornerRadius = 20;
    self.view.layer.borderWidth = 1.5;
    self.view.layer.borderColor = [UIColor cyanColor].CGColor;
    self.view.userInteractionEnabled = YES;

    // --- 1. 小窓全体のドラッグ設定 ---
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_0xDragMenu:)];
    [self.view addGestureRecognizer:pan];

    // --- 2. 閉じボタン (右上) ---
    self._0xC = [UIButton buttonWithType:UIButtonTypeCustom];
    self._0xC.frame = CGRectMake(250, 5, 40, 40);
    self._0xC.backgroundColor = [UIColor redColor];
    self._0xC.layer.cornerRadius = 20;
    [self._0xC setTitle:@"✕" forState:UIControlStateNormal];
    [self._0xC addTarget:self action:@selector(_0xHideSelf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self._0xC];

    // --- 3. WebView (真っ白回避の読み込み設定) ---
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    self._0xW = [[WKWebView alloc] initWithFrame:CGRectMake(0, 50, 300, 300) configuration:config];
    self._0xW.navigationDelegate = self;
    self._0xW.backgroundColor = [UIColor clearColor];
    self._0xW.opaque = NO;
    self._0xW.scrollView.scrollEnabled = NO;
    [self.view addSubview:self._0xW];

    // 0.5秒遅らせて確実に読み込む
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u]];
        [self._0xW loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0]];
    });
}

- (void)_0xHideSelf {
    [UIView animateWithDuration:0.2 animations:^{ self.view.alpha = 0; } completion:^(BOOL f){ self.view.hidden = YES; _0xB.hidden = NO; }];
}

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
+ (void)_0xShow {
    _0xV.view.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{ _0xV.view.alpha = 1; }];
    _0xB.hidden = YES;
}
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

            _0xV = [[_0xM alloc] init];
            _0xV.view.frame = CGRectMake((w.bounds.size.width-300)/2, (w.bounds.size.height-350)/2, 300, 350);
            [w addSubview:_0xV.view];

            _0xB = [UIButton buttonWithType:UIButtonTypeCustom];
            _0xB.frame = CGRectMake(20, 150, 60, 60);
            _0xB.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.6];
            _0xB.layer.cornerRadius = 30;
            [_0xB setTitle:@"MOD" forState:UIControlStateNormal];
            [_0xB addTarget:[_0xH class] action:@selector(_0xShow) forControlEvents:UIControlEventTouchUpInside];
            [_0xB addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[_0xH class] action:@selector(_0xDragBtn:)]];
            _0xB.hidden = YES;
            [w addSubview:_0xB];
        });
    }];
}
