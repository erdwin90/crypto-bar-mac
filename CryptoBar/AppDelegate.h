#import <Cocoa/Cocoa.h>

@class CoinViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSPopover *popover;

@property (strong, nonatomic) CoinViewController *coinViewController;

- (void)togglePopover:(id)sender;

@end