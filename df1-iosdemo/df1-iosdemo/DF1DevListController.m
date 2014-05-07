/*
Here, I tried to avoid using the storyboard and setup everything in code.
This is to avoid potential version control conflicts arising from layout related tweaking on
storyboard xml files. Also, it's better to maintain full control of the app's look and feel
in the code.

However, if you do choose to implement UITableView/UITableViewCell via Storyboard following
facts need to be considered:

* Do NOT call [tableView registerClass:[yourCell class] for CellReuseIdentifier:@"blah"]
    This confuses the reuseIdentifier with the you define on the storyboard. 
* No need to initialize the underlying labels or subview members within UITableViewCell.
* No need to override "layoutSubviews" function.

*/
#define DF_LEVEL 0

#import "DF1Lib.h"
#import "DF1DevListController.h"
#import "DF1DevCell.h"
#import "DF1DevDetailController.h"
#import "Utility.h"


@interface DF1DevListController ()
{
  NSTimer *rssiTimer;
}
@end


@implementation DF1DevListController

@synthesize nDevices;
@synthesize selectedPeripheral;

- (void)initializeMembers:(DF1 *) userdf
{
    // Custom initialization
    if(self.df == nil) {
        self.df = [[DF1 alloc] initWithDelegate:self];
    } else {
        self.df = userdf;
        self.df.delegate = self;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initializeMembers:nil];
        self.title = @"DF1 Demo1";
        DF_DBG(@"loaded DF1DevListController");

    }
    return self;
}

- (void) loadView
{
    [super loadView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[DF1DevCell class] forCellReuseIdentifier:@"df1cell"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DF_DBG(@"view loaded DF1DevListController");

    self.navigationItem.title = @"DF1 Demo1";
    // style related stuff
    // self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView setBackgroundView: [[UIImageView alloc]
                                        initWithImage: [UIImage imageNamed:@"DFLOGO07_launch_invert.png"]]];

    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clearScan));
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(triggerScan)
        forControlEvents:UIControlEventValueChanged];
    // [self.refreshControl setBackgroundColor:[UIColor grayColor]];
    self.refreshControl.tintColor = [UIColor redColor];
    // make sure it's on top of the background
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
}

-(void) viewDidAppear:(BOOL)animated
{
    // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.0 alpha:0.7];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    // kick off timer for reading RSSI for connected peripherals
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
        target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    if(self.df==nil)
        [self initializeMembers:nil];
}

// so that the timer doesn't hang around
-(void) viewWillDisappear:(BOOL)animated
{
  if(rssiTimer != nil) {
    [rssiTimer invalidate];
    rssiTimer = nil;
  }
}


#pragma mark - DF1DevDetailDelegate

-(void) willTransitionBack:(DF1 *) userdf
{
    [self initializeMembers:userdf];
}


- (void) clearScan
{
    [self.df stopScan:true]; // clear the internal device list
    [self finishScan];
    [self.tableView reloadData];
}

- (void) triggerScan
{
    DF_DBG(@"triggerScan: scanning for peripherals");
    self.title = @"Scanning...";
    // self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.refreshControl beginRefreshing];
    [self.df scan:10];
    [NSTimer scheduledTimerWithTimeInterval:6.0f
        target:self selector:@selector(timeoutScan:) userInfo:nil repeats:NO];
}

- (void) finishScan
{
    DF_DBG(@"finishScan");
    [self.refreshControl endRefreshing];
    self.title = @"Select Device";
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

// so that we avoid scanning indefinitely
- (void) timeoutScan: (NSTimer *) timer
{
    if([self.refreshControl isRefreshing]) {
        self.title = @"Select Device";
        [self.df stopScan:false]; // don't clear the internal device list
        [self finishScan];
        // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan Timeout" message:@"Stopped scanning"
        //                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // [alert show];
        // [alert release];
    }
}

- (void)triggerReadRSSI: (NSTimer *) timer
{
    for (int i=0; i<self.nDevices.count; i++)
    {
        CBPeripheral *p = [self.nDevices objectAtIndex:i];
        [self.df askRSSI:p];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - DF1Delegate delegate

// NOTE: once we find the df1 device we want, this function should stop the central scan
//       and initiate connection to the peripheral as necessary.
-(bool) didScan:(NSArray*) devices
{
    // simply set the pointer to the internal one : is this dangerous?
    self.nDevices = devices; 
    [self.tableView reloadData];
    return (devices.count>2) ? false : true; // just scan for more than 2 devices
}

-(void) didStopScan
{
    DF_DBG(@"stopped scanning");    
}

-(void) didConnect:(CBPeripheral *) peripheral
{
    DF_DBG(@"did connect peripheral: %@", peripheral.name);
    for (CBService *s in peripheral.services)
    {
        NSString *cname = [DF1LibUtil CBUUIDToString:s.UUID];
        DF_DBG(@"contains service: %@",cname);
    }
}

-(void) didUpdateRSSI:(CBPeripheral *)p withRSSI:(float)rssi
{
    DF_DBG(@"received rssi: %f",rssi);
    NSUInteger i = [self.nDevices indexOfObject:p];
    if(i!=NSNotFound) {
        DF1DevCell *cell = (DF1DevCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.subLabel.text = [NSString stringWithFormat:@"RSSI  %.0f dBm", rssi];
    }
}

-(void) receivedXYZ8:(NSArray*) data
{

}

-(void) receivedXYZ14:(NSArray*) data
{

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nDevices.count; // Return the number of rows in the section.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *p = [self.nDevices objectAtIndex:indexPath.row];

    // depending on name, we returns either the DF1DevCell or GenericCell
    if([[p.name lowercaseString] hasPrefix:@"df1"]) {
        DF_NRM(@"trying to create df1 cell!");
        DF1DevCell *cell = (DF1DevCell *) [self.tableView dequeueReusableCellWithIdentifier:@"df1cell"
                            forIndexPath:indexPath];
        if(cell==nil) {
            cell = [[DF1DevCell alloc] initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"df1cell"];
        }

        cell.nameLabel.text = [NSString stringWithFormat:@"%@",p.name];
        // cell.detailLabel.text = [NSString stringWithFormat:@"%@",[DF1LibUtil CBUUIDToString:p.UUID]];
        cell.subLabel.text = [NSString stringWithFormat:@"RSSI: NA"];
        // we set these attributes so that the cell can trigger action back to this controller
        cell.p = p;
        cell.delegate = self;

        BOOL foundService = NO;
        for(CBService* s in p.services) {
            if([DF1LibUtil isUUID:s.UUID thisInt:TEST_SERV_UUID]) {
                foundService = YES;
                break;
            }
        }
        if(!foundService) {
            cell.ledButton.hidden = YES;
        }
        return cell;
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"
                                 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",p.name];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        // MBGenericDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        // cell.nameLabel.text = [NSString stringWithFormat:@"%@",p.name];
        // cell.detailLabel.text = [NSString stringWithFormat:@"%@",CFUUIDCreateString(nil, p.UUID)];
        // cell.subLabel.text = [NSString stringWithFormat:@"RSSI: NA"];
        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // if (section == 0) return 0.0f;
    return 32.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *p = [self.nDevices objectAtIndex:indexPath.row];
    if([[p.name lowercaseString] hasPrefix:@"df1"]) {
        return 85;
    }
    return 45;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // return nil;
    
    if (section == 0) {
        if (self.nDevices.count > 0)
            return [NSString stringWithFormat:@"%d Devices Found",self.nDevices.count];
        else
            return [NSString stringWithFormat:@"swipe down to scan"];
    }
    return @"";
}

-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}


#pragma mark - Table view cell delegate

-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) data
{
    if(![self.df isConnected:p])
        return;
    DF_DBG(@"writing characteristic to the LED service for peripheral: %@", p.name);
    [DF1LibUtil writeCharacteristic:p sUUID:TEST_SERV_UUID cUUID:TEST_CONF_UUID data:data];
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSLog(@"setting peripheral to selectedPeripheral: row %d section %d", indexPath.row, indexPath.section);
    // self.selectedPeripheral = p;
    CBPeripheral *p = [self.nDevices objectAtIndex:indexPath.row];

    [self.df connect:p];

    DF1DevDetailController *vc = [[DF1DevDetailController alloc] initWithDF:self.df];
    vc.previousVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
