#import "AppDelegate.h"
#import "CoinViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.statusItem =
        [[NSStatusBar systemStatusBar]
            statusItemWithLength:NSVariableStatusItemLength];

    if (self.statusItem.button)
    {
        self.statusItem.button.title = @"₿";
        self.statusItem.button.font =
            [NSFont boldSystemFontOfSize:14];

        self.statusItem.button.target = self;
        self.statusItem.button.action =
            @selector(togglePopover:);
    }

    self.coinViewController =
        [[CoinViewController alloc] init];

    self.popover = [[NSPopover alloc] init];

    self.popover.behavior =
        NSPopoverBehaviorTransient;

    self.popover.contentSize =
        NSMakeSize(420, 650);

    self.popover.contentViewController =
        self.coinViewController;
}

- (void)togglePopover:(id)sender
{
    if (self.popover.isShown)
    {
        [self.popover performClose:sender];
    }
    else
    {
        [self.popover showRelativeToRect:
            self.statusItem.button.bounds
            ofView:self.statusItem.button
            preferredEdge:NSRectEdgeMinY];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    if (self.statusItem)
    {
        [[NSStatusBar systemStatusBar]
            removeStatusItem:self.statusItem];
    }
}

@end