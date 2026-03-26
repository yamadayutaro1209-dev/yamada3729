#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#include <string.h>

static NSString *generate_secure_gate() {
    // 1. パーツを整理（http:// webudid .gt .tc / main.php）
    NSArray *p = @[@"http://", @"webudid", @".gt", @".tc", @"/", @"main", @".php"];
    
    // 2. 結合
    NSString *u = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", p[0], p[1], p[2], p[3], p[4], p[5], p[6]];

    // 3. 署名作成（10秒単位だと厳しいので、30秒単位に緩和）
    long ts = (long)[[NSDate date] timeIntervalSince1970] / 30;
    NSString *key = @"MySuperSecretSalt";
    
    NSString *raw = [NSString stringWithFormat:@"%ld%@", ts, key];
    const char *cStr = [raw UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), r);
    
    NSString *sig = [NSString stringWithFormat:@"%02x%02x%02x%02x", r[0], r[1], r[2], r[3]];

    return [NSString stringWithFormat:@"%@?t=%ld&s=%@", u, ts, sig];
}

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation AuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor]; // 起動確認のため、最初は「青」にする

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];

    NSString *urlStr = generate_secure_gate();
    NSLog(@"[DEBUG] Target URL: %@", urlStr); // ログにも出力
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

// 読み込みエラーが起きたらアラートを出す
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通信エラー" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// （以下、前回の runJavaScript... や didFinishNavigation はそのまま維持）
@end
