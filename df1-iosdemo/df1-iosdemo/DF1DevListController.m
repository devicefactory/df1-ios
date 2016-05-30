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
#import "DF1OADController.h"
#import "Utility.h"
#import "NSData+Conversion.h"

@interface DF1DevListController ()
{
  NSTimer *rssiTimer;
    bool _isScanning;
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
    // [DF1LibUtil clearUserDefaults];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initializeMembers:nil];
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor],NSForegroundColorAttributeName,
                                        [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
        
        self.navigationController.navigationBar.titleTextAttributes = textAttributes;
        self.title = @"Device Factory";
        DF_DBG(@"loaded DF1DevListController");
        _isScanning = false;
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
    NSLog(@"the defaults are %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    //check to see if it is the first time launching the app
    //if it is, then present the introduction view
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    if(![[data valueForKey:@"launchedBeforeTutorial"] isEqual:[NSNumber numberWithBool:YES]]) {
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"launchedBeforeTutorial"];
        
        //Turn on all features to get the user started
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgBatteryLevel"];
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgCSVDataRecorder"];
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgDistance"];
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgMagnitudeValues"];
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgTapDetector"];
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgXYZPlotter"];
        [data setValue:[NSNumber numberWithBool:YES] forKey:@"DF1CfgFreefall"];
        
        [data synchronize];
        [self presentTutorial];
    }
    
    [self.tableView setSeparatorColor:[UIColor DFGray]];
    
    DF_DBG(@"view loaded DF1DevListController");
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationItem.title = @"DF1";
    // style related stuff
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //[self.tableView setBackgroundView: [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Default.png"]]];

    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clearScan));
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(triggerScan)
        forControlEvents:UIControlEventValueChanged];
    // [self.refreshControl setBackgroundColor:[UIColor grayColor]];
    self.refreshControl.tintColor = [UIColor blackColor];
    // make sure it's on top of the background
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
}

-(void) viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [UIColor DFBarColor];
    self.navigationController.navigationBar.tintColor = [UIColor DFRed];
    // kick off timer for reading RSSI for connected peripherals
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
        target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self selector:@selector(triggerScan) userInfo:nil repeats:NO];
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


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    DF_DBG(@"DF1DevListController calling navigationController:willShowViewController:animated");
    if ([viewController isEqual:self]) {
        [viewController viewWillAppear:animated];
    } else if ([viewController conformsToProtocol:@protocol(UINavigationControllerDelegate)]){
        // Set the navigation controller delegate to the passed-in view controller and call the UINavigationViewControllerDelegate method on the new delegate.
        [navigationController setDelegate:(id<UINavigationControllerDelegate>)viewController];
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
    }
}

-(void) presentTutorial {
    DF1TutorialController *vc = [[DF1TutorialController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - DF1DevDetailDelegate

-(void) willTransitionBack:(DF1 *) userdf
{
    [self initializeMembers:userdf];
}
*/

#pragma mark - Internal functions

- (void) clearScan
{
    [self.df stopScan:true]; // clear the internal device list
    _isScanning = false;
    [self finishScan];
    [self.tableView reloadData];
}

- (void) triggerScan
{
    DF_DBG(@"triggerScan: scanning for peripherals");
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"Scanning...";
    // self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.refreshControl beginRefreshing];
    [self.df scan:30];
    [NSTimer scheduledTimerWithTimeInterval:12.0f
        target:self selector:@selector(timeoutScan:) userInfo:nil repeats:NO];
    _isScanning = true;
}

- (void) finishScan
{
    DF_DBG(@"finishScan");
    [self.refreshControl endRefreshing];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
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
    return (devices.count>10) ? false : true; // just scan for more than 2 devices
}

-(void) didStopScan
{
    DF_DBG(@"stopped scanning");    
}


-(void) hasCentralErrors:(CBCentralManager *)central
{
    if(central.state == CBCentralManagerStatePoweredOff)
    {
        // initiate rescan?
        if(_isScanning) {
            DF_DBG(@"rescanning due to central errors!!");
            [self clearScan];
            [self triggerScan];
        }
        
    }
}

-(void) didConnect:(CBPeripheral *) peripheral
{
    DF_DBG(@"did connect peripheral: %@", peripheral.name);

    if([[peripheral.name lowercaseString] hasPrefix:@"df1"])
    {
        NSUInteger i = [self.nDevices indexOfObject:peripheral];
        if(i!=NSNotFound) {
            DF1DevCell *cell = (DF1DevCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow: i inSection:0]];
            // cell.ledButton2.userInteractionEnabled = YES;
            cell.ledButton.hidden = NO;
            // cell.ledButton.userInteractionEnabled = YES;
            bool hasAccUUID = false;
            bool hasOADUUID = false;
            for (CBService *s in peripheral.services)
            {
                NSString *cname = [DF1LibUtil CBUUIDToString:s.UUID];
                DF_DBG(@"contains service: %@",cname);
                //F000FFC0-0451-4000-B000-000000000000
                if([s.UUID isEqual:[CBUUID UUIDWithString:@"0xF000FFC0-0451-4000-B000-000000000000"]]) {
                    DF_DBG(@"found OAD service!");
                    hasOADUUID = true;
                }
                if([cname isEqual:@"aa10"]) {
                    hasAccUUID = true;
                }
            }
            if(!hasAccUUID && hasOADUUID) {
                cell.isOAD = [NSNumber numberWithBool:YES];
                NSString *name = [DF1LibUtil getUserCfgName:peripheral];
                cell.nameLabel.text = [NSString stringWithFormat:@"%@ (OAD)",name];
            }
        }
    }
}

-(void) didUpdateRSSI:(CBPeripheral *)p withRSSI:(float)rssi
{
    DF_DBG(@"received rssi: %f",rssi);
    NSUInteger i = [self.nDevices indexOfObject:p];
    if(i!=NSNotFound) {
        DF1DevCell *cell = (DF1DevCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell updateSignalValue:rssi];
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
    if (nDevices.count == 0) {
        
        UIImage *backgroundLogoImage = [UIImage imageNamed:@"noDevices.png"];
        UIImageView *backgroundLogoImageView = [[UIImageView alloc] initWithImage:backgroundLogoImage];
        backgroundLogoImageView.frame = CGRectMake((self.view.frame.size.width / 2) - (backgroundLogoImage.size.width / 2), (self.view.frame.size.height / 2) - (backgroundLogoImage.size.height / 2)-40, backgroundLogoImage.size.width, backgroundLogoImage.size.height);
        
        [self.view addSubview:backgroundLogoImageView];
    }
    else {
        for (UIView *v in self.view.subviews) {
            if ([v isKindOfClass:[UIImageView class]]) {
                [v removeFromSuperview];
            }
        }
    }
    
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

        NSString *name = [DF1LibUtil getUserCfgName:p];
        NSLog(@"the cfg dict on the dev list controller is %@", [DF1LibUtil getUserCfgDict:p]);
        cell.nameLabel.text = [NSString stringWithFormat:@"%@",name];
        // cell.detailLabel.text = [NSString stringWithFormat:@"%@",[DF1LibUtil CBUUIDToString:p.UUID]];
        cell.subLabel.text = [NSString stringWithFormat:@"RSSI: NA"];
        // we set these attributes so that the cell can trigger action back to this controller
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.p = p;
        cell.delegate = self;
        cell.isOAD = [NSNumber numberWithBool:NO]; // always start off assuming there's no OAD

        BOOL foundService = NO;
        for(CBService* s in p.services) {
            // DF_DBG(@"print service %@", [DF1LibUtil CBUUIDToString:s.UUID]);

            if([DF1LibUtil isUUID:s.UUID thisInt:TEST_SERV_UUID]) {
                foundService = YES;
                break;
            }
        }
        //WHY?
        /*if(!foundService) {
            cell.ledButton.hidden = YES;
        }*/
        [cell updateSignalValue:-100.0f];
        // only discover the battery and test services : accel takes longer
        CBUUID *bserv = [DF1LibUtil IntToCBUUID:BATT_SERVICE_UUID];
        CBUUID *tserv = [DF1LibUtil IntToCBUUID:TEST_SERV_UUID];
        NSArray *services = [NSArray arrayWithObjects: bserv, tserv, nil];
        // [self.df connect:p withServices:services];
        [self.df connect:p];
        return cell;
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"
                                 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",p.name];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.userInteractionEnabled = false;
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
    //return 32.0f;
    return 1.0f;
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
    /*if (section == 0) {
        if (self.nDevices.count == 1)
            return @"1 device found";
        else if (self.nDevices.count > 1)
            return [NSString stringWithFormat:@"%lu devices found",(unsigned long)self.nDevices.count];
        else
            return [NSString stringWithFormat:@"swipe down to scan"];
    }
    return @"";*/
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    /*UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    //myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor whiteColor];
    UIView *headerView = [[UIView alloc] init];
    //headerView.backgroundColor = [UIColor DFGray];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:myLabel];
    
    return headerView;*/
    return nil;
}

-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}


#pragma mark - Table view cell delegate

-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) data
{
    if(![self.df isConnected:p])
        return;
    // JB 20150216: hexString causes issues
    // DF_DBG(@"writing characteristic to the LED service for peripheral: %@ : %@", p.name, [data hexString]);
    [DF1LibUtil writeCharacteristic:p sUUID:TEST_SERV_UUID cUUID:TEST_CONF_UUID data:data];
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSLog(@"setting peripheral to selectedPeripheral: row %d section %d", indexPath.row, indexPath.section);
    // self.selectedPeripheral = p;
    CBPeripheral *p = [self.nDevices objectAtIndex:indexPath.row];
    DF1DevCell *cell = (DF1DevCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.df.p = p;
    if([cell.isOAD boolValue]) {
        NSString *uuid = [p.identifier UUIDString];
        DF1OADController *vc = [[DF1OADController alloc] initWithDF:self.df];
        // vc.previousVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        DF1DevDetailController *vc = [[DF1DevDetailController alloc] initWithDF:self.df];
        // vc.previousVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Open settings

-(void) openSettingsPopover {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView];
    }
    else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

@end
