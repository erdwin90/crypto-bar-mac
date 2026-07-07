#import "CoinViewController.h"
#import <objc/runtime.h>
#import "CryptoAPI.h"
#import "SparklineView.h"

@interface CoinViewController ()

@property (strong) NSMutableArray *coins;
@property (strong) NSMutableArray *filteredCoins;

@property (strong) NSTableView *tableView;
@property (strong) NSSearchField *searchField;

@property (assign) BOOL darkTheme;

@end

@implementation CoinViewController

- (void)loadView
{
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 420, 650)];

    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [[NSColor clearColor] CGColor];

    self.coins = [];

    NSMutableArray *normalized = [NSMutableArray array];

    for (NSDictionary *coin in self.coins) {
        NSMutableDictionary *m = [coin mutableCopy];
        m[@"price"] = m[@"price"] ?: @"$0.0";
        m[@"change"] = m[@"change"] ?: @"0%";
        m[@"favorite"] = @(NO);
        [normalized addObject:m];
    }

    self.coins = normalized;
    self.filteredCoins = [self.coins mutableCopy];


     [self buildUI];

    [self refreshCoins];


    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(refreshCoins)
                                   userInfo:nil
                                    repeats:YES];

  
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildUI];
    [self.tableView reloadData];

    [[CryptoAPI shared]
 fetchCoinsWithCompletion:
 ^(NSArray *coins)
{

    if (!coins)
    {
        return;
    }

    self.coins =
        [coins mutableCopy];

    self.filteredCoins =
        [coins mutableCopy];

    [self.tableView reloadData];
}];
}

- (void)buildUI
{
    NSVisualEffectView *blur =
        [[NSVisualEffectView alloc]
            initWithFrame:self.view.bounds];

    blur.autoresizingMask =
        NSViewWidthSizable |
        NSViewHeightSizable;

    blur.material =
        NSVisualEffectMaterialHUDWindow;

    blur.blendingMode =
        NSVisualEffectBlendingModeBehindWindow;

    blur.state =
        NSVisualEffectStateActive;

    [self.view addSubview:blur];

    NSButton *menuButton =
        [[NSButton alloc]
            initWithFrame:
            NSMakeRect(350,608,50,28)];

    menuButton.title = @"⋯"; 
    menuButton.font = [NSFont systemFontOfSize:18 weight:NSFontWeightBold];
    menuButton.bordered = NO;
    menuButton.wantsLayer = YES;
    menuButton.layer.backgroundColor = [NSColor clearColor].CGColor;

    menuButton.target = self;
    menuButton.action = @selector(showMenu:);

    [blur addSubview:menuButton];

    self.searchField =
        [[NSSearchField alloc]
            initWithFrame:
            NSMakeRect(10,608,120,28)];

    self.searchField.delegate = self;

    [blur addSubview:self.searchField];

    NSScrollView *scrollView =
        [[NSScrollView alloc]
            initWithFrame:
            NSMakeRect(10, 10, 400, 580)];

    scrollView.hasVerticalScroller = YES;
    scrollView.drawsBackground = NO;

    self.tableView =
        [[NSTableView alloc]
            initWithFrame:scrollView.bounds];

    self.tableView.backgroundColor =
         [NSColor clearColor];
    self.tableView.enclosingScrollView.drawsBackground = NO;
    self.tableView.selectionHighlightStyle =
    NSTableViewSelectionHighlightStyleNone;

    NSTableColumn *column =
        [[NSTableColumn alloc]
            initWithIdentifier:@"Coin"];

    column.width = 380;

    [self.tableView addTableColumn:column];

    self.tableView.headerView = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 74;

    scrollView.documentView =
        self.tableView;

    [blur addSubview:scrollView];

    [self.tableView reloadData];
}

#pragma mark - Search

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSString *text = [self.searchField.stringValue lowercaseString];

    self.filteredCoins = [NSMutableArray array];

    if (text.length == 0) {
        self.filteredCoins = [self.coins mutableCopy];
    } else {
        for (NSDictionary *coin in self.coins) {

            NSString *name = [coin[@"name"] lowercaseString];
            NSString *symbol = [coin[@"symbol"] lowercaseString];

            if ([name containsString:text] ||
                [symbol containsString:text]) {

                [self.filteredCoins addObject:coin];
            }
        }
    }

    [self refreshFilteredCoins];
    [self.tableView reloadData];
}

#pragma mark - Table

- (NSInteger)numberOfRowsInTableView:
    (NSTableView *)tableView
{
    return self.filteredCoins.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSDictionary *coin =
        self.filteredCoins[row];

    NSTableCellView *cell =
        [[NSTableCellView alloc]
            initWithFrame:
            NSMakeRect(0,0,380,74)];

    

    NSView *iconContainer =
    [[NSView alloc]
        initWithFrame:
        NSMakeRect(34,15,44,44)];


iconContainer.wantsLayer = YES;

iconContainer.layer.cornerRadius = 22;

iconContainer.layer.backgroundColor =
        [[NSColor colorWithWhite:1.0
                           alpha:0.02] CGColor];



iconContainer.layer.borderWidth = 1.5;

iconContainer.layer.borderColor =
    [[NSColor colorWithWhite:1.0
                       alpha:0.1] CGColor];

[cell addSubview:iconContainer];

NSButton *favButton =
[[NSButton alloc] initWithFrame:NSMakeRect(8, 27, 20, 20)];

favButton.bordered = NO;
favButton.wantsLayer = YES;
favButton.layer.backgroundColor =
    [[NSColor clearColor] CGColor];

favButton.target = self;
favButton.action = @selector(toggleFavorite:);
favButton.identifier = coin[@"symbol"];

favButton.focusRingType = NSFocusRingTypeNone;
favButton.alignment = NSTextAlignmentCenter;

favButton.imagePosition = NSNoImage;
favButton.enabled = YES; 

BOOL isFav = [coin[@"favorite"] boolValue];


NSImage *img = nil;

if (isFav) {
    img = [NSImage imageWithSystemSymbolName:@"star.fill"
                      accessibilityDescription:nil];
} else {
    img = [NSImage imageWithSystemSymbolName:@"star"
                      accessibilityDescription:nil];
}

favButton.image = img;
favButton.imagePosition = NSImageOnly;
favButton.contentTintColor = isFav ? [NSColor systemYellowColor] : [NSColor secondaryLabelColor];

[cell addSubview:favButton];

NSImageView *icon =
    [[NSImageView alloc]
        initWithFrame:
        NSMakeRect(6,6,32,32)];

NSString *coinSymbol =
    [coin[@"symbol"] lowercaseString];

NSString *iconPath =
[[NSBundle mainBundle]
 pathForResource:coinSymbol
 ofType:@"png"
 inDirectory:@"icons"];

NSImage *image =
    [[NSImage alloc]
        initWithContentsOfFile:iconPath];

if (image)
{
   icon.image = image;
[iconContainer addSubview:icon];
}
else
{
   NSView *fallback =
    [[NSView alloc]
        initWithFrame:
        NSMakeRect(6,6,32,32)];

fallback.wantsLayer = YES;
fallback.layer.cornerRadius = 16;
fallback.layer.backgroundColor =
    [[NSColor orangeColor] CGColor];

    [iconContainer addSubview:fallback];
}

    NSTextField *name =
        [[NSTextField alloc]
            initWithFrame:
            NSMakeRect(92,36,150,20)];

    name.bezeled = NO;
    name.drawsBackground = NO;
    name.editable = NO;
    name.selectable = NO;
    name.font =
        [NSFont boldSystemFontOfSize:14];
    name.stringValue =
        coin[@"name"];

    [cell addSubview:name];

    NSTextField *symbol =
        [[NSTextField alloc]
            initWithFrame:
            NSMakeRect(92,16,80,16)];

    symbol.bezeled = NO;
    symbol.drawsBackground = NO;
    symbol.editable = NO;
    symbol.selectable = NO;
    symbol.textColor =
        [NSColor secondaryLabelColor];

    symbol.font =
        [NSFont systemFontOfSize:12];

    symbol.stringValue =
        coin[@"symbol"];

    [cell addSubview:symbol];

  NSArray *chartPoints =
[[CryptoAPI shared]
    chartForCoin:coin[@"id"]];

if (chartPoints.count > 0)
{
    SparklineView *graph =
    [[SparklineView alloc]
        initWithFrame:
        NSMakeRect(170,20,80,34)];

    graph.points = chartPoints;

    [cell addSubview:graph];
}

    NSTextField *price =
        [[NSTextField alloc]
            initWithFrame:
            NSMakeRect(220,36,140,20)];

    price.alignment =
        NSTextAlignmentRight;

    price.bezeled = NO;
    price.drawsBackground = NO;
    price.editable = NO;
    price.selectable = NO;

    price.font =
        [NSFont boldSystemFontOfSize:14];

    price.stringValue =
        coin[@"price"];

    [cell addSubview:price];

    NSTextField *change =
        [[NSTextField alloc]
            initWithFrame:
            NSMakeRect(260,16,100,16)];

    change.alignment =
        NSTextAlignmentRight;

    change.bezeled = NO;
    change.drawsBackground = NO;
    change.editable = NO;
    change.selectable = NO;

   

    change.font =
        [NSFont systemFontOfSize:12];

   NSString *changeString =
    coin[@"change"];

double changeValue =
    [changeString doubleValue];

if (changeValue >= 0)
{
    change.textColor =
        [NSColor systemGreenColor];

    change.stringValue =
        [NSString stringWithFormat:
            @"▲ %@",
            changeString];
}
else
{
    change.textColor =
        [NSColor systemRedColor];

    change.stringValue =
        [NSString stringWithFormat:
            @"▼ %@",
            changeString];
}

    [cell addSubview:change];

   NSView *separator =
    [[NSView alloc]
        initWithFrame:
        NSMakeRect(0,0,360,1)];

separator.wantsLayer = YES;

separator.layer.backgroundColor =
    [[NSColor colorWithWhite:1.0
                       alpha:0.15] CGColor];

[cell addSubview:separator];

    return cell;
}

- (void)toggleFavorite:(NSButton *)sender
{
   NSString *symbol = sender.identifier;
    if (!symbol) return;

    for (NSMutableDictionary *coin in self.coins)
    {
        if ([coin[@"symbol"] isEqualToString:symbol])
        {
            BOOL current = [coin[@"favorite"] boolValue];
            coin[@"favorite"] = @(!current);
            break;
        }
    }

    [self refreshFilteredCoins];
    [self sortCoins];
    [self.tableView reloadData];
}

- (void)sortCoins
{
    self.coins = [[self.coins sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {

        BOOL favA = [a[@"favorite"] boolValue];
        BOOL favB = [b[@"favorite"] boolValue];

        if (favA == favB) return NSOrderedSame;
        return favA ? NSOrderedAscending : NSOrderedDescending;

    }] mutableCopy];

   
    NSString *text = [self.searchField.stringValue lowercaseString];

    if (text.length == 0) {
        self.filteredCoins = [self.coins mutableCopy];
    } else {
        [self controlTextDidChange:nil];
    }
}

- (void)refreshFilteredCoins
{
    NSString *text = [self.searchField.stringValue lowercaseString];

    self.filteredCoins = [NSMutableArray array];

    for (NSMutableDictionary *coin in self.coins)
    {
        NSString *name = [coin[@"name"] lowercaseString];
        NSString *symbol = [coin[@"symbol"] lowercaseString];

        BOOL match =
            (text.length == 0) ||
            [name containsString:text] ||
            [symbol containsString:text];

        if (match)
        {
            [self.filteredCoins addObject:coin];
        }
    }

  
    [self.filteredCoins sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {

        BOOL favA = [a[@"favorite"] boolValue];
        BOOL favB = [b[@"favorite"] boolValue];

        if (favA == favB) return NSOrderedSame;
        return favA ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (void)refreshCoins
{
    [[CryptoAPI shared]
     fetchCoinsWithCompletion:
     ^(NSArray *coins)
    {
        if (!coins || coins.count == 0)
        {
            NSLog(@"Skip update");
            return;
        }

        NSMutableArray *newCoins =
            [coins mutableCopy];

        for (NSMutableDictionary *newCoin in newCoins)
        {
            for (NSDictionary *oldCoin in self.coins)
            {
                if ([oldCoin[@"symbol"]
                    isEqualToString:newCoin[@"symbol"]])
                {
                    newCoin[@"favorite"] =
                        oldCoin[@"favorite"] ?: @NO;

                    break;
                }
            }
        }

        self.coins = newCoins;

        [self refreshFilteredCoins];

        [self.tableView reloadData];
    }];
}

- (void)showMenu:(NSButton *)sender
{
    NSMenu *menu =
        [[NSMenu alloc] init];

    [menu addItemWithTitle:@"Update"
                    action:@selector(menuUpdate)
             keyEquivalent:@""];

    [menu addItem:[NSMenuItem separatorItem]];


    [menu addItem:[NSMenuItem separatorItem]];

    [menu addItemWithTitle:@"Quit"
                    action:@selector(menuQuit)
             keyEquivalent:@""];

    [menu popUpMenuPositioningItem:nil
                        atLocation:NSMakePoint(0,
                                               sender.bounds.size.height)
                            inView:sender];
}

- (void)menuUpdate
{
    [self refreshCoins];
}

- (void)menuQuit
{
    [NSApp terminate:nil];
}



@end
