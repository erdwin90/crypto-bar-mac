#import "CryptoAPI.h"

@implementation CryptoAPI

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.charts =
            [NSMutableDictionary dictionary];

        [self refreshCharts];

        [NSTimer scheduledTimerWithTimeInterval:180.0
                                         target:self
                                       selector:@selector(refreshCharts)
                                       userInfo:nil
                                        repeats:YES];
    }

    return self;
}

+ (instancetype)shared
{
    static CryptoAPI *api;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        api = [[CryptoAPI alloc] init];
    });

    return api;
}

- (void)fetchCoinsWithCompletion:
(void (^)(NSArray *coins))completion
{

NSURL *url =
    [NSURL URLWithString:urlString];

[[[NSURLSession sharedSession]
dataTaskWithURL:url
completionHandler:
^(NSData *data,
  NSURLResponse *response,
  NSError *error)
{
    if (error || !data)
    {
        dispatch_async(
            dispatch_get_main_queue(),
        ^{
            completion(nil);
        });

        return;
    }

    id json =
    [NSJSONSerialization
        JSONObjectWithData:data
        options:0
        error:nil];

    if (![json isKindOfClass:[NSArray class]])
    {
        dispatch_async(
            dispatch_get_main_queue(),
        ^{
            completion(nil);
        });

        return;
    }

    NSArray *jsonArray =
        (NSArray *)json;

    NSString *chartURLString;
    NSURL *chartURL =
        [NSURL URLWithString:chartURLString];

    [[[NSURLSession sharedSession]
    dataTaskWithURL:chartURL
    completionHandler:
    ^(NSData *chartData,
      NSURLResponse *chartResponse,
      NSError *chartError)
    {
        NSMutableArray *btcChart =
            [NSMutableArray array];

        if (!chartError && chartData)
        {
            id chartJson =
            [NSJSONSerialization
                JSONObjectWithData:chartData
                options:0
                error:nil];

            if ([chartJson isKindOfClass:
                [NSDictionary class]])
            {
                NSArray *prices =
                    chartJson[@"prices"];

                for (NSArray *point
                     in prices)
                {
                    if ([point count] > 1)
                    {
                        [btcChart addObject:
                            point[1]];
                    }
                }
            }
        }

        NSMutableArray *coins =
            [NSMutableArray array];

        for (NSDictionary *item
             in jsonArray)
        {
            double value =
            [item[@"current_price"]
                doubleValue];

            NSNumberFormatter *formatter =
                [[NSNumberFormatter alloc]
                    init];

            formatter.numberStyle =
                NSNumberFormatterDecimalStyle;

            formatter.minimumFractionDigits = 2;
            formatter.maximumFractionDigits = 8;

            NSString *price =
            [NSString stringWithFormat:
                @"$%@",
                [formatter
                 stringFromNumber:
                 @(value)]];

            NSString *change =
            [NSString stringWithFormat:
                @"%.2f%%",
                [item[@"price_change_percentage_24h"]
                    doubleValue]];

            

            NSMutableDictionary *coin =
            [@{
                @"name":
                    item[@"name"] ?: @"",

                @"symbol":
                    [item[@"symbol"]
                     uppercaseString] ?: @"",

                @"price":
                    price,

                @"change":
                    change,

                @"id":
                    item[@"id"] ?: @"",

                @"favorite":
                    @NO
            } mutableCopy];

            if ([[item[@"id"]
                lowercaseString]
                isEqualToString:
                @"bitcoin"])
            {
                coin[@"chart"] =
                    btcChart;
            }

            [coins addObject:coin];
        }

        dispatch_async(
            dispatch_get_main_queue(),
        ^{
            completion(coins);
        });

    }] resume];

}] resume];
}

- (NSArray *)chartForCoin:
(NSString *)coinId
{
    return self.charts[coinId];
}

- (void)refreshCharts
{
    NSArray *chartCoins;

    for (NSString *coinId in chartCoins)
{
    @synchronized(self)
    {
        NSArray *existingChart =
            self.charts[coinId];

        if (existingChart &&
            existingChart.count > 2)
        {
            continue;
        }
    }

    NSString *urlString;

    NSURL *url =
        [NSURL URLWithString:urlString];

    [[[NSURLSession sharedSession]
    dataTaskWithURL:url
    completionHandler:
    ^(NSData *data,
      NSURLResponse *response,
      NSError *error)
    {
        if (error || !data)
            return;

        id json =
        [NSJSONSerialization
            JSONObjectWithData:data
            options:0
            error:nil];

        if (![json isKindOfClass:
            [NSDictionary class]])
        {
            return;
        }

        NSArray *prices =
            json[@"prices"];

        NSMutableArray *points =
            [NSMutableArray array];

        for (NSArray *entry in prices)
        {
            if ([entry count] > 1)
            {
                [points addObject:entry[1]];
            }
        }

        if (points.count < 2)
            return;

        @synchronized(self)
        {
            self.charts[coinId] =
                points;
        }

    }] resume];
}
}


@end
