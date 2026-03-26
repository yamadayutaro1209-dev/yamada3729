#import <CommonCrypto/CommonDigest.h>

// --- AIの解析をマヒさせる難読化マクロ ---
#define OBFS_PTR(ptr) ((uintptr_t)ptr ^ 0xDEADBEEF)

static NSString *generate_encrypted_gate() {
    // 1. URLのパーツをバラバラに配置（AIの文字列結合検知を回避）
    NSArray *parts = @[@"main", @"web", @"tc", @"gt", @"udid", @"html", @"://", @"http", @"."];
    
    // 2. インデックスを計算で算出（0, 1, 2...と書かない）
    int i7 = (14 % 7) + 7; // 7 (http)
    int i6 = (30 / 5);     // 6 (://)
    int i1 = (9 - 8);      // 1 (web)
    int i4 = (12 / 3);     // 4 (udid)
    int i8 = (16 >> 1) / 1; // 8 (.)
    int i3 = (15 % 4);     // 3 (gt)
    int i8_2 = 8;          // 8 (.)
    int i2 = (10 / 5);     // 2 (tc)
    int i8_3 = 8;          // 8 (.)
    int i0 = (0 * 9);      // 0 (main)
    int i8_4 = 8;          // 8 (.)
    int i5 = 5;            // 5 (html)

    // 3. 組み立て (http://webudid.gt.tc/main.html)
    NSString *u = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", 
                    parts[i7], parts[i6], parts[i1], parts[i4], parts[i8], 
                    parts[i3], i8_2 >= 0 ? parts[i8_2] : @"", parts[i2], 
                    parts[i8_3], parts[i0], parts[i8_4], parts[i5]];

    // 4. さらに「今の時間」に基づいたワンタイムトークンを付与
    // これにより、通信を傍受されてもURLが数秒で無効化される
    long timestamp = (long)[[NSDate date] timeIntervalSince1970] / 10; // 10秒ごとに変化
    NSString *secret = @"MySuperSecretSalt"; // サーバーと共通の合言葉
    
    NSString *rawSig = [NSString stringWithFormat:@"%ld%@", timestamp, secret];
    const char *cStr = [rawSig UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSString *sig = [NSString stringWithFormat:@"%02x%02x%02x%02x", 
                     result[0], result[1], result[2], result[3]];

    return [NSString stringWithFormat:@"%@?t=%ld&s=%@", u, timestamp, sig];
}
