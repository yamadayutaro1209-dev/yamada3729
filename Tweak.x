#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0x5a1 : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0x2b;
@end

static UIButton *_0x7c = nil;
static _0x5a1 *_0x9e = nil;

@implementation _0x5a1
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    // closeHandlerを登録
    [c.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    self._0x2b = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:c];
    self._0x2b.navigationDelegate = self;
    [self.view addSubview:self._0x2b];

    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    // 提供されたmain.phpへUDIDを付けてリクエスト
    NSString *l = [NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u];
    [self._0x2b loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:l]]];
}

- (void)webView:(WKWebView *)w didFinishNavigation:(WKNavigation *)n {
    // ボタン（開始、認証、リサいたー等）をフックして画面を閉じるJS
    NSString *j = @"\
        (function(){ \
            var b=document.getElementsByTagName('button'); \
            for(var i=0;i<b.length;i++){ \
                if(b[i].innerText.match(/開始|認証|リサ|OK/)){ \
                    b[i].onclick=function(){window.webkit.messageHandlers.closeHandler.postMessage(null);}; \
                } \
            } \
        })()";
    [w evaluateJavaScript:j completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)uc didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"closeHandler"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (_0x7c) _0x7c.hidden = NO;
    }
}
@end

@interface _0x1d : NSObject
@end
@implementation _0x1d
+ (void)_0x2f {
    UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
    if (!_0x9e) _0x9e = [[_0x5a1 alloc] init];
    if (w.rootViewController.presentedViewController) return;
    _0x9e.modalPresentationStyle = UIModalPresentationFullScreen;
    [w.rootViewController presentViewController:_0x9e animated:YES completion:nil];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
            _0x7c = [UIButton buttonWithType:UIButtonTypeCustom];
            _0x7c.frame = CGRectMake(20, 150, 45, 45);
            _0x7c.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.15];
            _0x7c.layer.cornerRadius = 22.5;
            _0x7c.hidden = YES;
            [_0x7c addTarget:[_0x1d class] action:@selector(_0x2f) forControlEvents:UIControlEventTouchUpInside];
            [w addSubview:_0x7c];
            [_0x1d _0x2f];
        });
    }];
}
