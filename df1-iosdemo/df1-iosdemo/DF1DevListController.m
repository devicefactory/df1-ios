#define DF_LEVEL 0

#import "DF1Lib.h"
#import "DF1DevListController.h"
#import "DF1DevCell.h"
#import "Utility.h"


@interface DF1DevListController ()
{
  NSTimer *rssiTimer;
}
@end


@implementation DF1DevListController

@synthesize nDevices;
@synthesize selectedPeripheral;

- (void)initializeMembers
{
    // Custom initialization
    self.df = [[DF1 alloc] initWithDelegate:self];
    self.nDevices = [[NSMutableArray alloc] init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initializeMembers];
        self.title = @"DF1 Demo1";
        DF_DBG(@"loaded DF1DevListController");
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    // self.tableView.rowHeight = 60.0f;
    // self.tableView.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerClass:[DF1DevCell class] forCellReuseIdentifier:@"df1cell"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DF_DBG(@"view loaded DF1DevListController");

    self.navigationItem.title = @"DF1 Demo1";

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"DFLOGO07_launch.png"];
    [imageView setAutoresizingMask:UIViewAutoresizingNone];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    // [self.tableView setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"background1.png"]]];
    [self.tableView setBackgroundView: imageView];

    [self initializeMembers];
    // [self.tableView reloadData];

    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clearScan));
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(triggerScan)
        forControlEvents:UIControlEventValueChanged];
}

-(void) viewDidAppear:(BOOL)animated
{
    // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.0 alpha:0.7];
    
    // kick off timer for reading RSSI for connected peripherals
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
        target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
}

-(void) viewWillAppear:(BOOL)animated {

}

// so that the timer doesn't hang around
-(void) viewWillDisappear:(BOOL)animated
{
  if(rssiTimer != nil) {
    [rssiTimer invalidate];
    rssiTimer = nil;
  }
}

- (void) clearScan
{
    [self.refreshControl endRefreshing];
    [self.df stopScan:YES]; // clear the devices
    // [self.nDevices removeAllObjects];
    [self.tableView reloadData];
}

- (void) triggerScan
{
    DF_DBG(@"triggerScan: scanning for peripherals");
    self.title = @"Scanning...";
    // self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.refreshControl beginRefreshing];

    [self.df scan:10];
    [NSTimer scheduledTimerWithTimeInterval:20.0f
        target:self selector:@selector(timeoutScan:) userInfo:nil repeats:NO];
}

- (void) finishScan
{
    DF_DBG(@"finishScan");
    // [self.df stopScan:NO];
    self.title = @"Select Device";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.refreshControl endRefreshing];
}

// so that we avoid scanning indefinitely
- (void) timeoutScan: (NSTimer *) timer
{
    if([self.refreshControl isRefreshing]) {
       self.title = @"Select Device";
       [self finishScan];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan Timeout" message:@"Stopped scanning"
                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        // [self.df stopScan:NO];
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

-(bool) didScan:(NSArray*) devices
{
    // simply set the pointer to the internal one : is this dangerous?
    self.nDevices = devices; 
    [self.tableView reloadData];
    return false; // false means stop scanning
}

-(void) didStopScan
{
    [self finishScan];
}

-(void) didUpdateRSSI:(CBPeripheral *)p withRSSI:(float)rssi
{
    DF_DBG(@"received rssi: %f",rssi);
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
    DF_NRM(@"trying to create df1 cell!");

    // depending on name, we returns either the DF1DevCell or GenericCell
    if([[p.name lowercaseString] hasPrefix:@"df1"]) {
        DF1DevCell *cell = (DF1DevCell *) [self.tableView dequeueReusableCellWithIdentifier:@"df1cell"
                            forIndexPath:indexPath];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@",p.name];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",p.name];
        // cell.detailLabel.text = [NSString stringWithFormat:@"%@",[DF1LibUtil CBUUIDToString:p.UUID]];
        cell.subLabel.text = [NSString stringWithFormat:@"RSSI: NA"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        cell.textLabel.text = [NSString stringWithFormat:@"%@",p.name];
        cell.textLabel.textColor = [UIColor whiteColor];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *p = [self.nDevices objectAtIndex:indexPath.row];
    if([[p.name lowercaseString] hasPrefix:@"df1"]) {
        return 100;
    }
    return 45;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.nDevices.count > 1)
            return [NSString stringWithFormat:@"%d Devices Found",self.nDevices.count];
        else
            return [NSString stringWithFormat:@"%d Devices Found",self.nDevices.count];
    }
    return @"";
}

-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}


#pragma mark - Table view cell delegate

-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) data
{
    if(!p.isConnected)
        return;
    DF_DBG(@"writing characteristic to the LED service for peripheral: %@", p.name);
    [DF1LibUtil writeCharacteristic:p sUUID:TEST_SERV_UUID cUUID:TEST_CONF_UUID data:data];
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // CBPeripheral *p = [self.nDevices objectAtIndex:indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSLog(@"setting peripheral to selectedPeripheral: row %d section %d", indexPath.row, indexPath.section);
    // self.selectedPeripheral = p;

    //BLEDevice *d = [[BLEDevice alloc]init];
    //d.p = p;
    //d.m = self.m;
    //d.setupData = [self makeSensorTagConfiguration];

    // SensorTagApplicationViewController *vC = [[SensorTagApplicationViewController alloc]initWithStyle:UITableViewStyleGrouped andSensorTag:d];
    // [self.navigationController pushViewController:vC animated:YES];

    // MBFirstViewController *vc = [[MBFirstViewController alloc] initWithBLEDevice:d];
    // [self.navigationController pushViewController:vc animated:YES];
}

/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"entering prepareForSegue");
    if([segue.identifier isEqualToString:@"DeviceDetailSegue"])
    {
        NSLog(@"hitting segue to MBFirstViewController");
        UITabBarController* tbc = [segue destinationViewController];
        MBFirstViewController *detailViewController = (MBFirstViewController*) [[tbc customizableViewControllers] objectAtIndex:0];

        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        CBPeripheral *p = [self.nDevices objectAtIndex:path.row];

        // cancel connection on all the devices except the one we chose
        for(int i=0; i<nDevices.count; i++) {
            CBPeripheral *pother = [self.nDevices objectAtIndex:i];
            if(![pother isEqual:p]) {
                if(pother.isConnected) {
                    [self.m cancelPeripheralConnection:pother];
                }
            }
        }
        [self.nDevices removeAllObjects];
        [self.nDevices addObject:p]; // save just the one we care about.
        [self.tableView reloadData];
        [self.m stopScan];

        BLEDevice *d = [[BLEDevice alloc] init];
        d.p = p;
        d.m = self.m;
        d.setupData = [BLEConfig makeMBConfig];
        [d assignDelegate: detailViewController];

        detailViewController.d = d;
    }
}
*/

@end
