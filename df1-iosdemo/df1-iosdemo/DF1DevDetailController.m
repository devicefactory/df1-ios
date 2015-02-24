//
//  DF1DevDetailController.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

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
        
        _defaultCells = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:TRUE],   @"DF1CellAccXyz",  // class names
                         [NSNumber numberWithBool:TRUE],   @"DF1CellAccTap",  // and boolean
                         [NSNumber numberWithBool:TRUE],   @"DF1CellDataShare",
                         [NSNumber numberWithBool:TRUE],   @"DF1CellBatt",
                         nil];
        [self initializeCells];
    }
    return self;
}

// here, we create a dictionary we want to save under NSUserDefault library
-(void) saveUserDefaultsForDevice
{
    // NSDictionary *cellList = _defaultCells;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.df.p.name, CFG_NAME,
                          _defaultCells,  CFG_CELLS,
                          nil];

    dict = [DF1LibUtil saveUserCfgDict:self.df.p withDict:dict];
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
        self.accTapCell.accValueTap.text = @"no events";
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
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Config", @selector(showCfgController));
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
            DF1DevListController *vc = (DF1DevListController*) viewController;
            vc.df = self.df;
            vc.df.delegate = vc;
        }
        
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DF_DBG(@"indexpath row: %ld", (long)indexPath.row);
    if(indexPath.row==0) {
        return self.accXyzCell;
    }
    if(indexPath.row==1) {
        return self.accTapCell;
    }
    if(indexPath.row==2) {
        DF_DBG(@"returning dataCell!!");
        return self.dataCell;
    }
    if(indexPath.row==3) {
        return self.battCell;
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
    if(indexPath.row==0) return self.accXyzCell.height;
    if(indexPath.row==1) return self.accTapCell.height;
    if(indexPath.row==2) return self.dataCell.height;
    if(indexPath.row==3) return self.battCell.height;
    return 100;
}


- (void) tableView:(UITableView*) tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [DF1LibUtil getUserCfgName:self.df.p];
    }
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
    return 37.0f;
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
-(void) _modifyDF1Parameters
{
    NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
    if(dict==nil)
    {
        DF_DBG(@"no user specific parameters to update");
        return;
    }
    
    if([dict objectForKey:CFG_XYZ8_RANGE]!=nil)
    {
        int range = [[dict objectForKey:CFG_XYZ8_RANGE] intValue];
        [self.df modifyRange:range];
        DF_DBG(@"modifying user CFG_XYZ8_RANGE to %d", range);
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

    NSDictionary *dict = [DF1LibUtil getUserCfgDict:self.df.p];
    if(dict==nil)
    {
        [self.df subscribeBatt];
        [self.df subscribeXYZ8];
        [self.df subscribeTap];
        // Every DF1 device we ever connected gets userDefault saved.
        [self saveUserDefaultsForDevice];
    }
    else
    {
        DF_DBG(@"user dict: %@", dict);
        // NSDictionary *cells = (NSDictionary*) [dict objectForKey:CFG_CELLS];
        NSMutableDictionary *cells;
        if([[dict objectForKey:CFG_CELLS] isKindOfClass:[NSArray class]]) {
            DF_DBG(@"wtf, I saved dict, not array!!!");
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
        }
    }
    _hud.labelText = @"successfully sync-ed";
    [self _setParamToUIControl:params];
    [MBProgressHUD hideHUDForView:self.view animated:true];
    _needResyncDF1Parameters = FALSE;
}

-(void) didUpdateRSSI:(CBPeripheral*) peripheral withRSSI:(float) rssi
{
}

-(void) receivedBatt:(float) battlev
{
    DF_DBG(@"received battery data: %f",battlev);
    self.battCell.battLevel.text = [[NSString alloc] initWithFormat:@"%.0f%%", battlev*100.0];
    self.battCell.battBar.progress = battlev;
    self.battCell.battBar.progressTintColor =
        (battlev > 0.75)                   ? [UIColor greenColor] :
        (battlev > 0.50 & battlev <= 0.75) ? [UIColor orangeColor] :
        (battlev <= 0.50)                  ? [UIColor redColor] : [UIColor redColor];
}

-(void) receivedXYZ8:(NSArray*) data
{
    float x = [data[0] floatValue];
    float y = [data[1] floatValue];
    float z = [data[2] floatValue];
    // DF_DBG(@"8bit is coming too??");
    // self.accXyzCell.accBarX.progress = (x + 2) / 4.0;
    self.accXyzCell.accValueX.text = [[NSString alloc] initWithFormat:@"X8 : %.3f", x];
    self.accXyzCell.accXStrip.value = x;
    self.accXyzCell.accValueY.text = [[NSString alloc] initWithFormat:@"Y8 : %.3f", y];
    self.accXyzCell.accYStrip.value = y;
    self.accXyzCell.accValueZ.text = [[NSString alloc] initWithFormat:@"Z8 : %.3f", z];
    self.accXyzCell.accZStrip.value = z;
    
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
    self.accXyzCell.accValueX.text = [[NSString alloc] initWithFormat:@"X14: %.4f", x];
    self.accXyzCell.accXStrip.value = x;
    self.accXyzCell.accValueY.text = [[NSString alloc] initWithFormat:@"Y14: %.4f", y];
    self.accXyzCell.accYStrip.value = y;
    self.accXyzCell.accValueZ.text = [[NSString alloc] initWithFormat:@"Z14: %.4f", z];
    self.accXyzCell.accZStrip.value = z;
    
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
    } else {
        self.accTapCell.accValueTap.text = @"no event";
    }
}

@end
