/*
*/
#define DF_LEVEL 0

#import "DF1Lib.h"
#import "DF1CfgController.h"
#import "Utility.h"
#import "NSData+Conversion.h"
#import "MBProgressHUD.h"
#import "DF1OADController.h"


@interface DF1CfgController ()
{
    NSMutableArray *_cells;
    NSMutableArray *_sectionNames;
    bool _saveOnExit;
}
@end

@implementation DF1CfgController

@synthesize cfg, useCaseTableView;

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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(featureNotif) name:@"DF1CfgXYZPlotter" object:nil];
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
    
    for(int i=0; i<classNames.count; i++)
    {
        NSArray *inner = [classNames objectAtIndex:i];
        NSMutableArray *_innerCells = [_cells objectAtIndex:i];
        [_innerCells removeAllObjects];
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
                [self.featuresTableView registerClass:cl forCellReuseIdentifier:className];
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
        _saveOnExit = true;
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

    self.navigationItem.title = @"Settings";
    // style related stuff
    self.featuresTableView.backgroundColor = [UIColor whiteColor];
    
    // [self.tableView setBackgroundView: [[UIImageView alloc]
    //                                    initWithImage: [UIImage imageNamed:@"DFLOGO07_launch_invert.png"]]];

    //self.navigationItem.rightBarButtonItem = BARBUTTON(@"save", @selector(saveCfg));
    
    //set up reuse identifiers for classes
    _useCaseToggle = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useCasePickerTogg) name:@"toggleUseCasePicker" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUseCase) name:@"useCaseSelected" object:nil];
    NSLog(@"the defaults dictionary which will store feature sets is: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat offset = self.navigationController.navigationBar.frame.size.height;
    CGRect table1Frame = CGRectMake(0, 0, width, 50);
    CGRect table2Frame = CGRectMake(0, 0, width, height-60);
    self.useCaseTableView = [[UITableView alloc]initWithFrame:table1Frame style:UITableViewStylePlain];
    
    [self.useCaseTableView registerClass:[DF1FeatureTitleCell class] forCellReuseIdentifier:@"DF1FeatureTitleCell"];
    [self.useCaseTableView registerClass:[DF1FeaturePickerCell class] forCellReuseIdentifier:@"DF1FeaturePickerCell"];
    [self.useCaseTableView registerClass:[DF1NewFeatureCell class] forCellReuseIdentifier:@"DF1NewFeatureCell"];
    
    self.useCaseTableView.showsVerticalScrollIndicator = NO;
    self.useCaseTableView.userInteractionEnabled = YES;
    self.useCaseTableView.scrollEnabled = NO;
    self.useCaseTableView.bounces = NO;
    self.useCaseTableView.tag = 1;
    self.useCaseTableView.delegate = self;
    self.useCaseTableView.dataSource = self;
    self.useCaseTableView.backgroundColor = [UIColor clearColor];
    self.useCaseTableView.opaque = NO;
    self.useCaseTableView.layer.zPosition = 1;
    //makes shadow
    self.useCaseTableView.layer.masksToBounds = NO;
    self.useCaseTableView.layer.shadowOffset = CGSizeMake(0, 3);
    self.useCaseTableView.layer.shadowRadius = 1;
    self.useCaseTableView.layer.shadowOpacity = 0.5;
    
    self.featuresTableView = [[UITableView alloc] initWithFrame:table2Frame style:UITableViewStylePlain];
    self.featuresTableView.delegate = self;
    self.featuresTableView.dataSource = self;
    self.featuresTableView.tag = 2;
    self.featuresTableView.showsVerticalScrollIndicator = YES;
    self.featuresTableView.userInteractionEnabled = YES;
    self.featuresTableView.scrollEnabled = YES;
    self.featuresTableView.bounces = YES;
    self.featuresTableView.layer.zPosition = 0;
    self.featuresTableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    
    [self.view addSubview:self.featuresTableView];
    [self.view insertSubview:useCaseTableView aboveSubview:self.featuresTableView];

}

-(void) useCasePickerTogg {
    NSLog(@"notif works");
    
    [useCaseTableView beginUpdates];
    
    CGFloat width = self.view.frame.size.width;
    _useCaseToggle = !_useCaseToggle;
    if(_useCaseToggle) {
        //CHANGE BTN PRESSED
        
        //save process
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *active_case_dict = [[NSMutableDictionary alloc] init];
        NSString *active_case_name = [defaults objectForKey:@"active_use_case"];
        NSMutableArray *use_cases = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"use_cases"]];
        
        for (int i=0; i<use_cases.count; i++) {
            NSDictionary *dict = [use_cases objectAtIndex:i];
            if([[dict valueForKey:@"name"] isEqualToString:active_case_name]) {
                active_case_dict = [dict mutableCopy];
                for (NSString *feature in [NSArray arrayWithObjects:SECTION2]) {
                    NSNumber *feat_bool = [defaults valueForKey:feature];
                    [active_case_dict setObject:feat_bool forKey:feature];
                }
                [use_cases replaceObjectAtIndex:i withObject:active_case_dict];
                
            }
        }
        
        [defaults setObject:use_cases forKey:@"use_cases"];
        [defaults synchronize];
        //end save process

        
        
        CGRect table1Frame = CGRectMake(0, 0, width, 250);
        [useCaseTableView setFrame:table1Frame];
        NSIndexPath *rowToReload1 = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath *rowToReload2 = [NSIndexPath indexPathForRow:2 inSection:0];
        NSArray *paths = [NSArray arrayWithObjects:rowToReload1,rowToReload2, nil];
        [useCaseTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        
        
        
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.tag = 4;
        visualEffectView.alpha = 0.8;
        
        visualEffectView.frame = _featuresTableView.bounds;
        [_featuresTableView addSubview:visualEffectView];
        
    }
    else {
        //maybe delay the below frame change for the animation to complete
        
        //DONE BTN PRESSED
        
        //Update the view
        
        CGRect table1Frame = CGRectMake(0, 0, width, 50);
        [useCaseTableView setFrame:table1Frame];
        NSIndexPath *rowToReload1 = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath *rowToReload2 = [NSIndexPath indexPathForRow:2 inSection:0];
        NSArray *paths = [NSArray arrayWithObjects:rowToReload1,rowToReload2, nil];
        [useCaseTableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        
        UIView *viewToRemove = [self.featuresTableView viewWithTag:4];
        [viewToRemove removeFromSuperview];
        
        //Get the selected use case, save it as active in user defaults and change the title text to say it.
        
        
        //Update the features to reflect the use case
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *use_cases = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"use_cases"]];
        NSDictionary *active_case_dict = [[NSDictionary alloc] init];
        NSString *active_case_name = [defaults objectForKey:@"active_use_case"];
        
        for (NSDictionary *dict in use_cases) {
            if([[dict valueForKey:@"name"] isEqualToString:active_case_name]) {
                active_case_dict = dict;
            }
        }
        
        //write the active use case to the main bools used for the view.
        for (NSString *feature in [NSArray arrayWithObjects:SECTION2]) {
            NSNumber *feat_bool = [active_case_dict valueForKey:feature];
            [defaults setObject:feat_bool forKey:feature];
            
        }
        
        [defaults synchronize];
        NSLog(@"reloaded the table of features");
        
    }
    
    NSLog(@"the defaults before the table reload are %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    [useCaseTableView endUpdates];
    
    [self initializeCells];
    [_featuresTableView reloadData];

    
}


-(void) updateUseCase {
    
        //NSDictionary *userInfo = notification.userInfo;
        //NSLog(@"the defaults dictionary which will store feature sets is: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

}


-(void) viewDidAppear:(BOOL)animated
{
    DF_DBG(@"entering viewDidAppear");
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}

-(void) viewWillAppear:(BOOL)animated
{
    //[self.featuresTableView setFrame:CGRectMake(0, 50, self.view.window.frame.size.width, self.view.window.frame.size.height-120)];
    //self.featuresTableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
}


-(void) viewWillDisappear:(BOOL)animated
{
    // force the save here
    if(_saveOnExit)
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
        // if we are transitioning to other viewcontrollers other than oad vc, we save the config
        /*
        if(![viewController isMemberOfClass:[DF1OADController class]])
        {
            [self saveCfg];
        }
        */
        
        // Set the navigation controller delegate to the passed-in view controller and call the UINavigationViewControllerDelegate method on the new delegate.
        [navigationController setDelegate:(id<UINavigationControllerDelegate>)viewController];
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
        
    }
}


#pragma mark - Internal functions

-(void) saveCfg
{
    //Is the settings cfg dictionary ever being set or updated?
    NSLog(@"the df old is %@, and the new cfg is %@", self.df.p, self.cfg);
    /*NSDictionary *dict =*/
    [DF1LibUtil saveUserCfgDict:self.df.p withDict:self.cfg];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Saved user preferences";
    hud.margin = 10.f;
    hud.yOffset = 50.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];

    //save process
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *active_case_dict = [[NSMutableDictionary alloc] init];
    NSString *active_case_name = [defaults objectForKey:@"active_use_case"];
    NSMutableArray *use_cases = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"use_cases"]];
   
    for (int i=0; i<use_cases.count; i++) {
        NSDictionary *dict = [use_cases objectAtIndex:i];
            if([[dict valueForKey:@"name"] isEqualToString:active_case_name]) {
            active_case_dict = [dict mutableCopy];
            for (NSString *feature in [NSArray arrayWithObjects:SECTION2]) {
                NSNumber *feat_bool = [defaults valueForKey:feature];
                [active_case_dict setObject:feat_bool forKey:feature];
            }
            [use_cases replaceObjectAtIndex:i withObject:active_case_dict];

        }
    }
    
    [defaults setObject:use_cases forKey:@"use_cases"];
    [defaults synchronize];
    //end save process
    
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
    if(tableView.tag == 1) {
        return 1;
    }
    else {
        return _cells.count;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 2) {
        return [[_cells objectAtIndex:section] count];
    }
    if (tableView.tag == 1) {
       return _useCaseToggle ? 3 : 1;
    }
    else {
        return 1;
    }
}

#pragma mark Cell For Row

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag == 2) {
        NSInteger section = indexPath.section;
        NSInteger row     = indexPath.row;
    
        if(_cells.count<=section) section = _cells.count - 1;
            NSInteger innerCount = [[_cells objectAtIndex:section] count];
        if(innerCount<=row) row = innerCount - 1;
        
            return _cells[section][row];
    }
    if(tableView.tag == 1) {
        if (indexPath.row == 0 ) {
            NSString *CellIdentifier = @"DF1FeatureTitleCell";
            DF1FeatureTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            if (!cell) {
                cell = [[DF1FeatureTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            return cell;
        }
        if(indexPath.row == 1) {
            NSString *CellIdentifier = @"DF1FeaturePickerCell";
            DF1FeaturePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            if (!cell) {
                cell = [[DF1FeaturePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            return cell;
        }
        if (indexPath.row == 2) {
            NSString *CellIdentifier = @"DF1NewFeatureCell";
            DF1NewFeatureCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            if (!cell) {
                cell = [[DF1NewFeatureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            return cell;
        }

    }
    return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 2) {
        //return 37.0f;
        return 0;
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 2) {
        NSInteger section = indexPath.section;
        NSInteger row     = indexPath.row;
        
        DF1CfgCell *cell = [[_cells objectAtIndex:section] objectAtIndex:row];
       return cell.height;
    }
    if(tableView.tag == 1) {
        if(indexPath.row == 1) {
            return 150;
        }
        else {
            return 50;
        }
        
    }
    return 50;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_sectionNames.count<=section) section = _sectionNames.count - 1;
    return _sectionNames[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 2) {
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
    else {
        UIView *headerView = [[UIView alloc] init];
        return headerView;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}


#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //NSInteger section = indexPath.section;
    //NSInteger row     = indexPath.row;

    // DF1DevDetailController *vc = [[DF1DevDetailController alloc] initWithDF:self.df];
    // vc.previousVC = self;
    // [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Alert view cell delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        DF_DBG(@"You have clicked Cancel");
        return;
    }
    else if(buttonIndex == 1)
    {
        DF_DBG(@"Retrying triggerOAD");
        [self triggerOAD];
    }
}


#pragma mark - DF1CfgCellOADTriggerDelegate


// JB NOTE: implement OAD here!!
-(void) triggerOAD
{
    if(![self.df isConnected:self.df.p]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"OAD Trigger Failed!"
                                    message:@"Device is not connected?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView addButtonWithTitle:@"retry"];
        [alertView show];
        return;
    }
    
    NSString *uuid = [self.df.p.identifier UUIDString];
    DF_DBG(@"initiating OAD boot and subsequent firmware update for: %@", uuid);
    uint8_t byte = 0xFF; // uh oh! this is the special hex to trigger OAD mode, and boot into imgA.
    NSData *data = [NSData dataWithBytes:&byte length:1];
    // Writing this characteristic will reboot DF1. We now have to retrigger scanning and connect.
    [DF1LibUtil writeCharacteristic:self.df.p sUUID:TEST_SERV_UUID cUUID:TEST_CONF_UUID data:data];
    // jump to the viewController that can reconnect and do OAD update with the peripheral ID as the arg.
    [self showOADController:uuid];
}

-(void) showOADController:(NSString*) uuid
{
    _saveOnExit = false;
    DF1OADController *vc = [[DF1OADController alloc] initWithPeripheralUUID:uuid];
    // [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:vc animated:YES];
    // [self presentViewController:vc animated:YES completion:nil];
}


@end
