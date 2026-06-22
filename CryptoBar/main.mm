#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"


int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSApplication *app = [NSApplication sharedApplication];

        AppDelegate *delegate =
            [[AppDelegate alloc] init];

        [app setDelegate:delegate];

        [app run];
    }

    return 0;
}
