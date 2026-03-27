#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0x1a : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0x1b;
@end

static UIButton *_0x2a = nil;
static _0x1a *_0x2b = nil;

@implementation _0x1a

static NSString * _0x_f(const char* h) {
    NSMutableString *s = [NSMutableString string];
    for (int i=0; i<strlen(h); i+=2) {
        unsigned int c;
        sscanf(h+i, "%02x", &c);
        [s appendFormat:@"%c", (char)c];
    }
    return s;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    [c.userContentController addScriptMessageHandler:self name:_0x_f("636c6f736548616e646c6572")];
    self._0x1b = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:c];
    self._0x1b.navigationDelegate = self;
    [self.view addSubview:self._0x1b];
    
    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    // https化を推奨 (httpだとアプリ側でブロックされるケースが多いため)
    NSString *l = [NSString stringWithFormat:@"https://%@/%@%@", _0x_f("776562756469642e67742e7463"), _0x_f("6d61696e2e7068703f756469643d"), u];
    [self._0x1b loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:l]]];
}

- (void)webView:(WKWebView *)w didFinishNavigation:(WKNavigation *)n {
    // ボタンクリックを確実に奪い取るためのJS
    // 登録やリサイターなどの文言に反応するように調整
    NSString *j = [NSString stringWithFormat:@"\
        (function(){ \
            var _h = '%@'; \
            var _f = function(){ \
                var b = document.getElementsByTagName('button'); \
                for(var i=0; i<b.length; i++){ \
                    if(b[i].innerText.match(/登録|リサ|開始|閉じる/)){ \
                        b[i].onclick = null; \
                        b[i].addEventListener('click', function(e){ \
                            window.webkit.messageHandlers[_h].postMessage(null); \
                        }, true); \
                    } \
                } \
            }; \
            _f(); \
            setTimeout(_f, 1000); /* 念のため1秒後にも再実行 */ \
        })()", _0x_f("636c6f736548616e646c6572")];
    [w evaluateJavaScript:j completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)uc didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:_0x_f("636c6f736548616e646c6572")]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (_0x2a) _0x2a.hidden = NO;
    }
}
@end

@interface _0x3a : NSObject
@end
@implementation _0x3a
+ (void)_0x3b {
    UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
    if (!_0x2b) _0x2b = [[_0x1a alloc] init];
    if (w.rootViewController.presentedViewController) return;
    _0x2b.modalPresentationStyle = UIModalPresentationFullScreen;
    [w.rootViewController presentViewController:_0x2b animated:YES completion:nil];
}
+ (void)_0x3c:(UIPanGestureRecognizer *)p {
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
            _0x2a = [UIButton buttonWithType:UIButtonTypeCustom];
            _0x2a.frame = CGRectMake(20, 150, 45, 45);
            _0x2a.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.15];
            _0x2a.layer.cornerRadius = 22.5;
            [_0x2a setTitle:@"" forState:UIControlStateNormal];
            _0x2a.hidden = YES;
            [_0x2a addTarget:[_0x3a class] action:@selector(_0x3b) forControlEvents:UIControlEventTouchUpInside];
            [_0x2a addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[_0x3a class] action:@selector(_0x3c:)]];
            [w addSubview:_0x2a];
            [_0x3a _0x3b];
        });
    }];
}
