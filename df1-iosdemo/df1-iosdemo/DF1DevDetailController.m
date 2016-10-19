//
//  DF1DevDetailController.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0
#define DF_EVENT_SEPARATION_TIME 1

#import "DF1DevDetailController.h"
#import "DF1CfgController.h"
#import "DF1DevListController.h"
#import "DF1Lib.h"
#import "Utility.h"
#import "MBProgressHUD.h"

@interface DF1DevDetailController ()
{
    NSTimer *reconnectTimer;
    NSTimer *eventResetTimer;
    BOOL _needResyncDF1Parameters;
    int subscriptionRetries;
    NSDictionary *_defaultCells;
    MBProgressHUD *_hud;
}
@end


@implementation DF1DevDetailController
@synthesize df;


-(id)initWithDF:(DF1*) userdf
{
    self = [super init];
    if(self) {
        self.df = userdf;
        self.df.delegate = self;
        [self.df connect:self.df.p];
        _needResyncDF1Parameters = FALSE;
        _avgAccCounter = 0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _defaultCells = [NSDictionary dictionaryWithObjectsAndKeys:
                         [defaults valueForKey:@"DF1CfgXYZPlotter"],   @"DF1CellAccXyz",  // class names
                         [defaults valueForKey:@"DF1CfgTap"],   @"DF1CellAccTap",  // and boolean
                         [defaults valueForKey:@"DF1CfgFlip"],    @"DF1CellFlip",
                         [defaults valueForKey:@"DF1CfgCSVDataRecorder"],   @"DF1CellDataShare",
                         [defaults valueForKey:@"DF1CfgBatteryLevel"],   @"DF1CellBatt",
                         [defaults valueForKey:@"DF1CfgMagnitudeValues"],   @"DF1CellMag",
                         [defaults valueForKey:@"DF1CfgDistance"],   @"DF1CellDistance",
                         [defaults valueForKey:@"DF1CfgFreefall"],   @"DF1CellFreefall",
                         nil];
        [self initializeCells];
    }
    NSLog(@"the def cells, %@", _defaultCells);
    return self;
}

// here, we create a dictionary we want to save under NSUserDefault library
-(void) saveUserDefaultsForDevice
{
    
    //THIS WAS COMMENTED OUT BECAUSE IT WAS CAUSING THE NEWLY UPDATED SETTINGS TO BE OVERWRITTEN...
    // NSDictionary *cellList = _defaultCells;
    /*NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.df.p.name, CFG_NAME,
                          _defaultCells,  CFG_CELLS,
                          nil];
    
    NSLog(@"save user defaults in dev detail will be saving %@", dict);

    dict = [DF1LibUtil saveUserCfgDict:self.df.p withDict:dict];*/
}

-(void)initializeCells
{
    // check the userdefaults uuid -> dict -> cellList and instantiate accordingly
    NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
    NSDictionary *cells;
    /*
    NSString *bitres = @"8bit";
    if(dict==nil)
    {
        cells = _defaultCells;
        bitres = @"8bit";
    } else {
        cells = (NSDictionary*) [dict objectForKey:CFG_CELLS];
        bitres = ([[dict objectForKey:CFG_XYZ14_ON] boolValue]) ? @"14bit" : @"8bit";
    }
    */
    cells = _defaultCells;
    
    if([[cells objectForKey:@"DF1CellAccXyz"] boolValue] &&
       !self.accXyzCell)
    {
        self.accXyzCell = [[DF1CellAccXyz alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"AccXYZCell" parentController:self];
        // do other default initialization here
        // self.accXyzCell.accLabel.text =  [[NSString alloc] initWithFormat:@"Acceleration %@", bitres];
        self.accXyzCell.accLabel.text = @"Acceleration";
        self.accXyzCell.accValueX.text = @"x axis";
        self.accXyzCell.accValueY.text = @"y axis";
        self.accXyzCell.accValueZ.text = @"z axis";
    }
    if([[cells objectForKey:@"DF1CellAccTap"] boolValue] &&
       !self.accTapCell)
    {
        self.accTapCell = [[DF1CellAccTap alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:@"AccTapCell" parentController:self];
        self.accTapCell.accLabel.text = @"Tap Event";
        self.accTapCell.accValueTap.text = @"no event";
    }
    if([[cells objectForKey:@"DF1CellFlip"] boolValue] &&
       !self.flipCell)
    {
        self.flipCell = [[DF1CellFlip alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"FlipCell" parentController:self];
        self.flipCell.accLabel.text = @"Flip Event";
        self.flipCell.accValueTap.text = @"no event";
    }
    if([[cells objectForKey:@"DF1CellDataShare"] boolValue] &&
       !self.dataCell)
    {
        self.dataCell = [[DF1CellDataShare alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"DataCell" parentController:self];
        self.dataCell.mainLabel.text = @"Record Data";
    }
    if([[cells objectForKey:@"DF1CellBatt"] boolValue] &&
       !self.battCell)
    {
        self.battCell = [[DF1CellBatt alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"BattCell"];
        self.battCell.battLabel.text = @"Battery Level";
        self.battCell.battLevel.text = @"NA";
        self.battCell.battBar.progress = 0.0;
    }
    if([[cells objectForKey:@"DF1CellMag"] boolValue] && !self.magCell) {
        _magCell = [[DF1CellAccMagnitude alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AccMagCell" parentController:self];
        
        _magCell.magText.text = @"";
        //_magCell.mag
        
    }
    if([[cells objectForKey:@"DF1CellDistance"] boolValue] && !self.distCell) {
        _distCell = [[DF1CellDistance alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DistCell" parentController:self];
        //_magCell.mag
        NSLog(@"making dist cell");
        
        _rssiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
        
    }
    
    if([[cells objectForKey:@"DF1CellFreefall"] boolValue] && !self.freeCell) {
        _freeCell = [[DF1CellFreefall alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FreeCell" parentController:self];
        self.freeCell.accLabel.text = @"Freefall Event";
        self.freeCell.accValueTap.text = @"no event";
        NSLog(@"making freefall cell");
        
        }
    // if(!self.rssiCell) {
    //     self.rssiCell = [[RSSICell alloc] initWithStyle:UITableViewCellStyleDefault
    //                                           reuseIdentifier:@"RSSICell"];
    // }
}



-(void) viewDidLoad
{
    [super viewDidLoad];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"initializing";
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Settings", @selector(showCfgController));
    [self setTitle:@"DF1"];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Devices";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    /*
    if(self.navigationController) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.4
                                                                green:0.4 blue:0.9 alpha:0.5];
    }
    */
    
    if(_needResyncDF1Parameters)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"sync parameters";
        [self _modifyDF1Parameters];  // contents of user cfg might have changed
        [self.df syncParameters];  // will incur callback didSyncParameters
        [self.tableView reloadData];
    }
    
    //reload what cells should be in the table
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _defaultCells = [NSDictionary dictionaryWithObjectsAndKeys:
                     [defaults valueForKey:@"DF1CfgXYZPlotter"],   @"DF1CellAccXyz",  // class names
                     [defaults valueForKey:@"DF1CfgTap"],   @"DF1CellAccTap",  // and boolean
                     [defaults valueForKey:@"DF1CfgFlip"],  @"DF1CellFlip",
                     [defaults valueForKey:@"DF1CfgCSVDataRecorder"],   @"DF1CellDataShare",
                     [defaults valueForKey:@"DF1CfgBatteryLevel"],   @"DF1CellBatt",
                     [defaults valueForKey:@"DF1CfgMagnitudeValues"],   @"DF1CellMag",
                     [defaults valueForKey:@"DF1CfgDistance"],   @"DF1CellDistance",
                     [defaults valueForKey:@"DF1CfgFreefall"],   @"DF1CellFreefall",
                     nil];
    [self initializeCells];

}

-(void)viewWillDisappear:(BOOL)animated
{
    _needResyncDF1Parameters = TRUE;
}


-(void) showCfgController
{
    // DF1CfgController *vc = [[DF1CfgController alloc] initWithStyle:UITableViewCellStyleDefault];
    DF1CfgController *vc = [[DF1CfgController alloc] initWithDF:self.df];
    [self.navigationController pushViewController:vc animated:YES];
    //[self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    DF_DBG(@"DF1DevDetailController calling navigationController:willShowViewController:animated");
    if ([viewController isEqual:self])
    {
        [viewController viewWillAppear:animated];
    }
    else if ([viewController conformsToProtocol:@protocol(UINavigationControllerDelegate)])
    {
        // Set the navigation controller delegate to the passed-in view controller and call the UINavigationViewControllerDelegate method on the new delegate.
        [navigationController setDelegate:(id<UINavigationControllerDelegate>)viewController];
        
        if([viewController isMemberOfClass:[DF1DevListController class]])
        {
            [self.df unsubscribeBatt];
            [self.df unsubscribeXYZ8];
            [self.df unsubscribeXYZ14]; // just in case
            [self.df unsubscribeTap];
            [self.df unsubscribeFreefall];
            DF1DevListController *vc = (DF1DevListController*) viewController;
            vc.df = self.df;
            vc.df.delegate = vc;
        }
        
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
    }
    
}


#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //check the bools for cell initialization and sum them as integers
    NSInteger cellsCount = [[_defaultCells valueForKey:@"DF1CellAccXyz"] integerValue] + [[_defaultCells valueForKey:@"DF1CellAccTap"] integerValue] + [[_defaultCells valueForKey:@"DF1CellDataShare"] integerValue] + [[_defaultCells valueForKey:@"DF1CellBatt"] integerValue] + [[_defaultCells valueForKey:@"DF1CellMag"] integerValue] + [[_defaultCells valueForKey:@"DF1CellDistance"] integerValue] + [[_defaultCells valueForKey:@"DF1CellFreefall"] integerValue];
    NSLog(@"cells count is %ld", cellsCount);
    return cellsCount;
    // int count = 1; // by default we need the signal strength
    // if([self.d isEnabled:@"Accelerometer service active"])
    //   count += 2;
    // if([self.d isEnabled:@"Battery service active"])
    //   count += 1;
    // if([self.d isEnabled:@"LED service active"])
    //   count += 1;
    // // Return the number of rows in the section.
    // return count;
}

#pragma mark cellForRow
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellIndexer = 0;
    DF_DBG(@"indexpath row: %ld", (long)indexPath.row);
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgXYZPlotter"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.accXyzCell;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgTap"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.accTapCell;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgFlip"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.flipCell;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgCSVDataRecorder"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.dataCell;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgBatteryLevel"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.battCell;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgMagnitudeValues"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.magCell;
        }
    }

    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgDistance"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.distCell;
        }
    }
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgFreefall"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.freeCell;
        }
    }
    // if (indexPath.row==0 && [self.d isEnabled:@"Accelerometer service active"]) {
    //     [self.babyCell setPosition:UACellBackgroundViewPositionTop];
    //     return self.babyCell;
    // }
    // // Something has gone wrong, because we should never get here, return empty cell
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Unknown Cell"];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellIndexer = 0;
    DF_DBG(@"indexpath row: %ld", (long)indexPath.row);
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgXYZPlotter"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.accXyzCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgTap"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.accTapCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgFlip"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.accTapCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgCSVDataRecorder"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.dataCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgBatteryLevel"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return self.battCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgMagnitudeValues"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return _magCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgDistance"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return _distCell.height;
        }
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgFreefall"] boolValue]) {
        cellIndexer++;
        if(cellIndexer==indexPath.row+1) {
            return _freeCell.height;
        }
    }

    return 100;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /*if (section == 0) {
        return [DF1LibUtil getUserCfgName:self.df.p];
    }*/
    return @"";
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:18];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor darkGrayColor];
    [headerView addSubview:myLabel];
    return headerView;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return 37.0f;
    return 1.0f;
}
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - DF1Delegate delegate functions

-(bool) didScan:(NSArray*) devices
{
    return true;
}

-(void) didStopScan
{
}


// takes user config and modifies the parameters on DF1 accordingly.

//I think what you wrote reads what the df1 has and just puts it back on the DF1...
-(void) _modifyDF1Parameters
{

    NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
    if(dict==nil)
    {
        DF_DBG(@"no user specific parameters to update");
        return;
    }
    NSLog(@"The User Config Dict is %@", dict);
    if([dict objectForKey:CFG_XYZ8_RANGE]!=nil)
    {
        int range = [[dict objectForKey:CFG_XYZ8_RANGE] intValue];
        [self.df modifyRange:range];
        DF_DBG(@"modifying user CFG_XYZ8_RANGE to %d", range);
    }
    if([dict objectForKey:CFG_XYZ_FREQ]!=nil)
    {
        int hz = [[dict objectForKey:CFG_XYZ_FREQ] integerValue];
        [self.df modifyXyzFreq:hz];
        DF_DBG(@"modifying user CFG_XYZ_FREQ to %d", hz);
    }
    if([dict objectForKey:CFG_TAP_TMLT]!=nil)
    {
        float tmlt = [[dict objectForKey:CFG_TAP_TMLT] floatValue];
        [self.df modifyTapTmlt:tmlt];
        DF_DBG(@"modifying user CFG_TAP_TMLT to %f", tmlt);
    }
    if([dict objectForKey:CFG_TAP_THSZ]!=nil)
    {
        float gz = [[dict objectForKey:CFG_TAP_THSZ] floatValue];
        [self.df modifyTapTmlt:gz];
        DF_DBG(@"modifying user CFG_TAP_THSZ to %f", gz);
    }
    if([dict objectForKey:CFG_TAP_THSY]!=nil)
    {
        float gy = [[dict objectForKey:CFG_TAP_THSY] floatValue];
        [self.df modifyTapTmlt:gy];
        DF_DBG(@"modifying user CFG_TAP_THSZ to %f", gy);
    }
    if([dict objectForKey:CFG_TAP_THSX]!=nil)
    {
        float gx = [[dict objectForKey:CFG_TAP_THSX] floatValue];
        [self.df modifyTapTmlt:gx];
        DF_DBG(@"modifying user CFG_TAP_THSZ to %f", gx);
    }
    
}


// this function gets called when services and characteristics are all discovered
-(void) didConnect:(CBPeripheral*) peripheral
{
    _peripheral = peripheral;
    _hud.labelText = @"connected to peripheral";
    [self _modifyDF1Parameters];
    [self.df syncParameters];
}

-(void) _setParamToUIControl:(NSDictionary*) params
{
    NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
    
    NSData *data; uint8_t byte;
    data = [params objectForKey:[DF1LibUtil IntToCBUUID:ACC_TAP_THSZ_UUID]]; 
    [data getBytes:&byte length:1];
    [self.accTapCell.accThsSlider setValue:(NSUInteger)byte animated:YES];
    self.accTapCell.accThsLabel.text = [[NSString alloc] initWithFormat:@"Thresh %.3fG",(float)byte*0.063f];

    data = [params objectForKey:[DF1LibUtil IntToCBUUID:ACC_TAP_TMLT_UUID]]; 
    [data getBytes:&byte length:1];
    [self.accTapCell.accTmltSlider setValue:(NSUInteger)byte animated:YES];
    self.accTapCell.accTmltLabel.text = [[NSString alloc] initWithFormat:@"Tmlt %.0fms",(float)byte*10.0f];
}


-(void) didSyncParameters:(NSDictionary *)params
{
    NSLog(@"%@",params);
    _hud.labelText = @"successfully sync-ed";
    
   //NOTE: I added the below lines becasue for some reason subscriptions were never being triggered and I am not sure I understand the initial reasoning behind the if statements to set subscriptions. Therefore I moved a set of subscriptions to outside the if statements.
    
    [self.df subscribeBatt];
    [self.df subscribeXYZ8];
    [self.df subscribeTap];
    [self.df subscribeFreefall];
    // Every DF1 device we ever connected gets userDefault saved.
    [self saveUserDefaultsForDevice];
    
    NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
    if(dict==nil)
    {
        [self.df subscribeBatt];
        [self.df subscribeXYZ8];
        [self.df subscribeTap];
        [self.df subscribeFreefall];
        // Every DF1 device we ever connected gets userDefault saved.
        [self saveUserDefaultsForDevice];
    }
    else
    {
        DF_DBG(@"user dict: %@", dict);
        // NSDictionary *cells = (NSDictionary*) [dict objectForKey:CFG_CELLS];
        NSMutableDictionary *cells;
        if([[dict objectForKey:CFG_CELLS] isKindOfClass:[NSArray class]]) {
            DF_DBG(@"wtf, I saved dict, not array!!!"); //LOL This is awesome debugging.
            cells = [[NSMutableDictionary alloc] init];
            for(NSString *key in [dict objectForKey:CFG_CELLS]) {
                [cells setObject:[NSNumber numberWithBool:YES] forKey:key];
            }
        }
        else if([[dict objectForKey:CFG_CELLS] isKindOfClass:[NSDictionary class]]) {
            cells =[dict objectForKey:CFG_CELLS];
        }
        
        if(cells==nil) {
            [self.df subscribeXYZ8];
            [self.df subscribeTap];
            [self.df subscribeBatt];
            [self.df subscribeFreefall];
        } else {
            DF_DBG(@"cell dict: %@", cells);
            if([cells objectForKey:@"DF1CellAccXyz"]!=nil &&
               [[cells objectForKey:@"DF1CellAccXyz"] boolValue]) {
                if([[dict objectForKey:CFG_XYZ14_ON] boolValue]) {
                    [self.df unsubscribeXYZ8];
                    [self.df subscribeXYZ14];
                } else {
                    [self.df unsubscribeXYZ14];
                    [self.df subscribeXYZ8];
                }
            }
            if([cells objectForKey:@"DF1CellAccTap"]!=nil &&
               [[cells objectForKey:@"DF1CellAccTap"] boolValue]) {  [self.df subscribeTap]; }
            if([cells objectForKey:@"DF1CellBatt"]!=nil &&
               [[cells objectForKey:@"DF1CellBatt"] boolValue])   {  [self.df subscribeBatt]; }
            if([cells objectForKey:@"DF1CellFreefall"]!=nil &&
               [[cells objectForKey:@"DF1CellFreefall"] boolValue])   {  [self.df subscribeFreefall]; }
        }
    }
    _hud.labelText = @"subscribing to data";
    
    [self _setParamToUIControl:params];
    [MBProgressHUD hideHUDForView:self.view animated:true];
    _needResyncDF1Parameters = FALSE;
}

-(void) didUpdateRSSI:(CBPeripheral*) peripheral withRSSI:(float) rssi
{
    self.distCell.RSSIText.text = [NSString stringWithFormat:@"%.2f dBm", rssi];
    double distance = pow(10, (-75-rssi)/20);
    self.distCell.distanceText.text = [NSString stringWithFormat:@"%.2f m", distance];
    
}

-(void) receivedBatt:(float) battlev
{
    DF_DBG(@"received battery data: %f",battlev);
    self.battCell.battLevel.text = [[NSString alloc] initWithFormat:@"%.0f%%", battlev*100.0];
    self.battCell.battBar.progress = battlev;
    self.battCell.battBar.progressTintColor =
        (battlev > 0.75)                   ? [UIColor DFGreen] :
        (battlev > 0.50 & battlev <= 0.75) ? [UIColor DFYellow] :
        (battlev <= 0.50)                  ? [UIColor DFRed] : [UIColor DFRed];
}


//TODO: A NEW DATA PROCESSING CLASS SHOULD BE MADE TO SEPARATE ALL THIS LOGIC FROM THE DETAIL VIEW

-(void) receivedXYZ8:(NSArray*) data
{
    float x = [data[0] floatValue];
    float y = [data[1] floatValue];
    float z = [data[2] floatValue];
    // DF_DBG(@"8bit is coming too??");
    // self.accXyzCell.accBarX.progress = (x + 2) / 4.0;
    self.accXyzCell.accValueX.text = [[NSString alloc] initWithFormat:@"X  %.3f", x];
    self.accXyzCell.accXStrip.value = x;
    self.accXyzCell.accValueY.text = [[NSString alloc] initWithFormat:@"Y  %.3f", y];
    self.accXyzCell.accYStrip.value = y;
    self.accXyzCell.accValueZ.text = [[NSString alloc] initWithFormat:@"Z  %.3f", z];
    self.accXyzCell.accZStrip.value = z;
    
    float mag = sqrt(pow(x,2)+pow(y,2)+pow(z,2));
    if (mag>_maxAcceleration.doubleValue) {
        _maxAcceleration = [NSNumber numberWithFloat:mag];
    }
    
    
    if(_magnitudeArray.count > 9) {
        [_magnitudeArray removeObjectAtIndex:0];
    }
    [_magnitudeArray addObject:[NSNumber numberWithFloat:mag]];
    NSNumber *peak = [self testArrayForPeak:_magnitudeArray];
    if(peak) {
        [self testAndAddTopTenPoint:peak];
    }

    
    if(z<0) {
        self.flipCell.accValueTap.text =@"LED Down";
    }
    else {
        self.flipCell.accValueTap.text =@"LED Up";
    }
    
    _avgAcceleration = [NSNumber numberWithFloat:((_avgAcceleration.floatValue * _avgAccCounter.floatValue)+mag)/(_avgAccCounter.floatValue+1) ];
    _avgAccCounter = [NSNumber numberWithInt:_avgAccCounter.intValue+1];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:3];
    [formatter setMinimumFractionDigits:3];
    NSString *avgTxt = [formatter stringFromNumber:_avgAcceleration];
    NSString *maxTxt = [formatter stringFromNumber:_maxAcceleration];
    self.magCell.magText.text = [[NSString alloc] initWithFormat:@"%.3f", mag];
    self.magCell.avgMagText.text = [[NSString alloc] initWithFormat:@"%@", avgTxt];
    self.magCell.maxMagText.text = [[NSString alloc] initWithFormat:@"%@", maxTxt];
//    Present notification if the magnitude exceeds 2G's allow users to change this value and make sure this runs in the background
//    if(mag > 2) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Magnitude Threshold Exceeded!" object:nil];
//    }
    
    //INCLUDE TOP 10 feature math here!!
    
    
    if(self.dataCell!=nil && [self.dataCell isFileReady]) {
        [self.dataCell recordX:x Y:y Z:z];
    }
}

-(void) receivedXYZ14:(NSArray*) data
{
    float x = [data[0] floatValue];
    float y = [data[1] floatValue];
    float z = [data[2] floatValue];
    // DF_DBG(@"14bit coming in: %.2f %.2f %.2f", x, y, z);
    // self.accXyzCell.accBarX.progress = (x + 2) / 4.0;
    self.accXyzCell.accValueX.text = [[NSString alloc] initWithFormat:@"X  %.4f", x];
    self.accXyzCell.accXStrip.value = x;
    self.accXyzCell.accValueY.text = [[NSString alloc] initWithFormat:@"Y  %.4f", y];
    self.accXyzCell.accYStrip.value = y;
    self.accXyzCell.accValueZ.text = [[NSString alloc] initWithFormat:@"Z  %.4f", z];
    self.accXyzCell.accZStrip.value = z;
    
    //calculate the max and average accelerations
    float mag = sqrt(pow(x,2)+pow(y,2)+pow(z,2));
    if (mag>_maxAcceleration.doubleValue) {
        _maxAcceleration = [NSNumber numberWithFloat:mag];
    }
    _avgAcceleration = [NSNumber numberWithFloat:((_avgAcceleration.floatValue * _avgAccCounter.floatValue)+mag)/(_avgAccCounter.floatValue+1) ];
    _avgAccCounter = [NSNumber numberWithInt:_avgAccCounter.intValue+1];

    
    NSLog(@"Setting mag of: %f", mag);
    self.magCell.magText.text = [[NSString alloc] initWithFormat:@"%f", mag];
    self.magCell.avgMagText.text = [[NSString alloc] initWithFormat:@"%@", _avgAcceleration];
    self.magCell.maxMagText.text = [[NSString alloc] initWithFormat:@"%@", _maxAcceleration];

    //Present notification if the magnitude exceeds 2G's allow users to change this value and make sure this runs in the background
//    if(mag > 2) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Magnitude Threshold Exceeded!" object:nil];
//    }
    
    if(self.dataCell!=nil && [self.dataCell isFileReady]) {
        [self.dataCell recordX:x Y:y Z:z];
    }
}

-(void) _resetTap
{
    self.accTapCell.accValueTap.textColor = [UIColor blackColor];
    self.accTapCell.accValueTap.text = @"no event";
}

-(void) receivedTap:(NSMutableDictionary*) tbl
{
    NSInteger hasEvent = [[tbl valueForKey:@"TapHasEvent"] intValue];
    NSInteger isZEvent = [[tbl valueForKey:@"TapIsZEvent"] intValue];
    
    // if(hasEvent>0) DF_DBG(@"has tap!");
    
    if(hasEvent) {
        self.accTapCell.accValueTap.textColor = [UIColor redColor];
        self.accTapCell.accValueTap.text = [[NSString alloc] initWithFormat:@"Tap!"];
        eventResetTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(_resetTap)
                                                         userInfo:nil repeats:FALSE];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.alertBody = @"DF1 Acceleration Threshold Exceeded!";
        localNotif.alertTitle = @"DF1 Tap Detector";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        
    } else {
        self.accTapCell.accValueTap.text = @"no event";
    }
}

- (void)triggerReadRSSI: (NSTimer *) timer
{
        [self.df askRSSI:_peripheral];
    
}


-(void) _resetFall
{
    self.freeCell.accValueTap.textColor = [UIColor blackColor];
    self.freeCell.accValueTap.text = @"no event";
}

-(void) receivedFall:(NSMutableDictionary*) tbl
{
    NSInteger hasEvent = [[tbl valueForKey:@"FallHasEvent"] intValue];
    NSLog(@"Freefall has event: %li", (long)hasEvent);
    
    if(hasEvent) {
        self.freeCell.accValueTap.textColor = [UIColor redColor];
        self.freeCell.accValueTap.text = [[NSString alloc] initWithFormat:@"Falling!"];
        eventResetTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(_resetFall)
                                                         userInfo:nil repeats:FALSE];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.alertBody = @"The DF1 has undergone freefall.";
        localNotif.alertTitle = @"Freefall Detected!";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        
    } /*else {
        self.freeCell.accValueTap.text = @"no event";
    }*/
}

//This function takes in a set of 9 points and tests the middle one for a peak
-(NSNumber *) testArrayForPeak:(NSMutableArray *)accValues {
    NSNumber *testPoint = [accValues objectAtIndex:5];
    for (NSNumber *value in accValues) {
        if(value>testPoint) {
            return nil;
        }
    }
    return testPoint;
}

-(void) testAndAddTopTenPoint:(NSNumber *) newPeak{
    if(_peaksArray.count >= 9) {
        for (int i = 0; i<8; i++) {
            if(newPeak > [_peaksArray objectAtIndex:i]) {
                //new peak found, add it.
                [_peaksArray insertObject:newPeak atIndex:i];
                [_peaksArray removeObject:[_peaksArray lastObject]];
                break;
            }
        }
    
    }
    else {
        [_peaksArray addObject:newPeak];
    }
    //scan the array to see if the newPeak is greater than any old ones.
        //if yes, add it at that index and cut off the last value if greater than 10 peaks have been found. sort descending
        //else drop the value and do nothing.
    
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [_peaksArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
}

@end
