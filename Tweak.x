#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface _0xM : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0xW;
@end

static UIButton *_0xB = nil;
static _0xM *_0xV = nil;

@implementation _0xM
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    [c.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    self._0xW = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:c];
    self._0xW.navigationDelegate = self;
    [self.view addSubview:self._0xW];

    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *l = [NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u];
    [self._0xW loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:l]]];
}

- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"closeHandler"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (_0xB) _0xB.hidden = NO;
    }
}
@end

@interface _0xH : NSObject
@end
@implementation _0xH
+ (void)_0xS {
    UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
    if (!_0xV) _0xV = [[_0xM alloc] init];
    if (w.rootViewController.presentedViewController) return;
    _0xV.modalPresentationStyle = UIModalPresentationFullScreen;
    [w.rootViewController presentViewController:_0xV animated:YES completion:nil];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
            _0xB = [UIButton buttonWithType:UIButtonTypeCustom];
            _0xB.frame = CGRectMake(20, 150, 45, 45);
            _0xB.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
            _0xB.layer.cornerRadius = 22.5;
            _0xB.hidden = YES;
            [_0xB addTarget:[_0xH class] action:@selector(_0xS) forControlEvents:UIControlEventTouchUpInside];
            [w addSubview:_0xB];
            [_0xH _0xS];
        });
    }];
}
