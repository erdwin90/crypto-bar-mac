#import <Foundation/Foundation.h>

@interface CryptoAPI : NSObject

@property (nonatomic, strong) NSMutableDictionary *charts;

+ (instancetype)shared;

- (void)fetchCoinsWithCompletion:
(void (^)(NSArray *coins))completion;

- (void)refreshCharts;

- (NSArray *)chartForCoin:
(NSString *)coinId;

@end