#import "DF1DevListController.h"
#import "DF1Lib.h"

@interface DF1DevListController ()
{
  NSTimer *rssiTimer;
}
@end

@implementation DF1DevListController

@synthesize m,nDevices;
@synthesize selectedPeripheral;

- (void)initializeMembers
{
    // Custom initialization
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initializeMembers];
        self.title = @"DFMove Demo App";
        NSLog(@"loaded MBSelectController");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view loaded MBSelectController");

    self.navigationItem.title = @"DFMove Demo";

    // UIImageView *imageView = [[UIImageView alloc] init];
    // imageView.image = [UIImage imageNamed:@"background1.png"];
    // [imageView setAutoresizingMask:UIViewAutoresizingNone];
    // self.babyImage.contentMode = UIViewContentModeScaleAspectFit;

    //bimage = [self imageWithImage: bimage scaledToWidth: 150];
    // [self.tableView setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"background1.png"]]];
    // [self.tableView setBackgroundView: imageView];

    [self initializeMembers];
    // [self.tableView reloadData];

    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clearScan));
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(triggerScan) forControlEvents:UIControlEventValueChanged];

}

-(void) viewDidAppear:(BOOL)animated
{
    // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.0 alpha:0.7];

    for(CBPeripheral *p in self.nDevices)
    {
        p.delegate = self;
    }

    if(self.m)
        m.delegate = self;

    // kick off timer for reading RSSI for connected peripherals
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
}

// so that the timer doesn't hang around
-(void) viewWillDisappear:(BOOL)animated
{
  if(rssiTimer != nil) {
    [rssiTimer invalidate];
    rssiTimer = nil;
  }
}

