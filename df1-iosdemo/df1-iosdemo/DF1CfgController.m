/*
*/
#define DF_LEVEL 0

#import "DF1Lib.h"
#import "DF1CfgController.h"
#import "Utility.h"
#import "NSData+Conversion.h"
#import "MBProgressHUD.h"


@interface DF1CfgController ()
{
    NSMutableArray *_cells;
    NSMutableArray *_sectionNames;
}
@end

@implementation DF1CfgController

@synthesize cfg;

// http://stackoverflow.com/questions/8259896/instantiate-class-programmatically-in-ios
-(void) initializeCells
{
    // NOTE: array of arrays : define your Cells here
    NSArray *classNames = [NSArray arrayWithObjects:
        [NSArray arrayWithObjects: SECTION1],
        [NSArray arrayWithObjects: SECTION2],
        [NSArray arrayWithObjects: SECTION3],
        nil
    ];
    // initialize
    if(_cells==nil)
    {
        _cells = [[NSMutableArray alloc] init];
        for(int i=0; i<classNames.count; i++)
        {
            DF_DBG(@"adding NSMutableArray for cell section %d", i);
            [_cells addObject:[[NSMutableArray alloc] init]];
        } 
    }
    if(_sectionNames==nil)
    {
        _sectionNames = [NSMutableArray arrayWithObjects:SECTION_NAMES];
    }
    // kinda like factory mechanism?
    for(int i=0; i<classNames.count; i++)
    {
        NSArray *inner = [classNames objectAtIndex:i];
        NSMutableArray *_innerCells = [_cells objectAtIndex:i];
        for(int j=0; j<inner.count; j++)
        {
            NSString *className = [inner objectAtIndex:j];
            DF_DBG(@"initializing class %@", className);
            Class cl = NSClassFromString(className);
            DF1CfgCell *cell = [[cl alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:className withCfg:self.cfg];
            if([className isEqual:@"DF1CfgCellOADTrigger"]) {
                // we explicitly set the handle to df object into this cell.
                DF1CfgCellOADTrigger *oadcell = (DF1CfgCellOADTrigger*) cell;
                oadcell.delegate = self;
            }
            // MyClass *myClass = [[cl alloc] init];
            [self.tableView registerClass:cl forCellReuseIdentifier:className];
            [_innerCells addObject:cell];
        }
    }
}

-(id) initWithDF:(DF1*) userdf
{
    self = [super init];
    if (self)
    {
        self.title = @"Configuration";
        self.df = userdf;

        NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
        if(dict==nil)
            self.cfg = [[NSMutableDictionary alloc] init];
        else
            self.cfg = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        [self initializeCells];
        DF_DBG(@"loaded DF1CfgController");
    }
    return self;
}

-(void) loadView
{
    [super loadView];
    // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // [self.tableView registerClass:[DF1DevCell class] forCellReuseIdentifier:@"df1cell"];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    DF_DBG(@"view loaded DF1CfgController");

    self.navigationItem.title = @"DF1 Configuration";
    // style related stuff
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // [self.tableView setBackgroundView: [[UIImageView alloc]
    //                                    initWithImage: [UIImage imageNamed:@"DFLOGO07_launch_invert.png"]]];

    self.navigationItem.rightBarButtonItem = BARBUTTON(@"save", @selector(saveCfg));
}

-(void) viewDidAppear:(BOOL)animated
{
    DF_DBG(@"entering viewDidAppear");
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}

-(void) viewWillAppear:(BOOL)animated
{
    // if(self.df==nil) [self initializeMembers:nil];
}

// so that the timer doesn't hang around
-(void) viewWillDisappear:(BOOL)animated
{
    // force the save here
    [self saveCfg];
}
    

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    DF_DBG(@"calling navigationController:willShowViewController:animated");
    if ([viewController isEqual:self]) {
        [viewController viewWillAppear:animated];
    } else if ([viewController conformsToProtocol:@protocol(UINavigationControllerDelegate)]){
        // Set the navigation controller delegate to the passed-in view controller and call the UINavigationViewControllerDelegate method on the new delegate.
        [navigationController setDelegate:(id<UINavigationControllerDelegate>)viewController];
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
    }
}


#pragma mark - Internal functions

-(void) saveCfg
{
    NSDictionary *dict = [DF1LibUtil saveUserCfgDict:self.df.p withDict:self.cfg];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Saved user preferences";
    hud.margin = 10.f;
    hud.yOffset = 50.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}


#pragma mark - DF1Delegate delegate

// NOTE: once we find the df1 device we want, this function should stop the central scan
//       and initiate connection to the peripheral as necessary.
-(bool) didScan:(NSArray*) devices
{
    // simply set the pointer to the internal one : is this dangerous?
    // self.nDevices = devices; 
    // [self.tableView reloadData];
    // return (devices.count>10) ? false : true; // just scan for more than 2 devices
    return true;
}

-(void) didStopScan
{
    DF_DBG(@"stopped scanning");    
}

-(void) didConnect:(CBPeripheral *) peripheral
{
    // DF_DBG(@"did connect peripheral: %@", peripheral.name);
    // for (CBService *s in peripheral.services)
    // {
    //     NSString *cname = [DF1LibUtil CBUUIDToString:s.UUID];
    //     DF_DBG(@"contains service: %@",cname);
    // }
}

-(void) didUpdateRSSI:(CBPeripheral *)p withRSSI:(float)rssi
{
    DF_DBG(@"received rssi: %f",rssi);
    // NSUInteger i = [self.nDevices indexOfObject:p];
    // if(i!=NSNotFound) {
    //     DF1DevCell *cell = (DF1DevCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    //     [cell updateSignalValue:rssi];
    // }
}

-(void) receivedXYZ8:(NSArray*) data
{
}

-(void) receivedXYZ14:(NSArray*) data
{
}


#pragma mark - Table view data source

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _cells.count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_cells objectAtIndex:section] count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;
    
    if(_cells.count<=section) section = _cells.count - 1;
    NSInteger innerCount = [[_cells objectAtIndex:section] count];
    if(innerCount<=row) row = innerCount - 1;
    
    return _cells[section][row];
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;

    DF1CfgCell *cell = [[_cells objectAtIndex:section] objectAtIndex:row];
    return cell.height;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_sectionNames.count<=section) section = _sectionNames.count - 1;
    return _sectionNames[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor darkGrayColor];
    if(_sectionNames.count<=section) section = _sectionNames.count - 1;
    [headerView addSubview:myLabel];
    return headerView;
}

-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;

    // DF1DevDetailController *vc = [[DF1DevDetailController alloc] initWithDF:self.df];
    // vc.previousVC = self;
    // [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view cell delegate


#pragma mark - DF1CfgCellOADTriggerDelegate


// JB NOTE: implement OAD here!!
-(void) triggerOAD
{
    uint8_t byte = 0xFF; // uh oh! this is the special hex to trigger OAD mode, and boot into imgA.
    NSData *data = [NSData dataWithBytes:&byte length:1];
    if(![self.df isConnected:self.df.p])
        return;
    
    NSString *uuid = [self.df.p.identifier UUIDString];
    DF_DBG(@"initiating OAD boot and subsequent firmware update for: %@", uuid);
    [DF1LibUtil writeCharacteristic:self.df.p sUUID:TEST_SERV_UUID cUUID:TEST_CONF_UUID data:data];

    // jump to the viewController that can handle OAD update with the peripheral ID as the arg.
}
@end
