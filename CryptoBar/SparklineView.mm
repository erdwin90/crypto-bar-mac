#import "SparklineView.h"

@implementation SparklineView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if (self.points.count < 2)
        return;

    CGFloat min =
        [[self.points valueForKeyPath:@"@min.self"] doubleValue];

    CGFloat max =
        [[self.points valueForKeyPath:@"@max.self"] doubleValue];

    if (max == min)
        max += 1.0;

    NSBezierPath *path =
        [NSBezierPath bezierPath];

    for (NSInteger i = 0; i < self.points.count; i++)
    {
        double value =
            [self.points[i] doubleValue];

        CGFloat x =
            (CGFloat)i /
            (self.points.count - 1) *
            self.bounds.size.width;

       CGFloat padding = 3.0;

CGFloat y =
    padding +
    ((value - min) / (max - min)) *
    (self.bounds.size.height - padding * 2);

        if (i == 0)
            [path moveToPoint:NSMakePoint(x, y)];
        else
            [path lineToPoint:NSMakePoint(x, y)];
    }

    double first =
    [self.points.firstObject doubleValue];

double last =
    [self.points.lastObject doubleValue];

if (last >= first)
{
    [[NSColor systemGreenColor] setStroke];
}
else
{
    [[NSColor systemRedColor] setStroke];
}

    path.lineWidth = 2.0;

    [path stroke];
}

@end