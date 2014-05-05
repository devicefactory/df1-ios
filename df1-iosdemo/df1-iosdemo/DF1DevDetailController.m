//
//  DF1DevDetailController.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1DevDetailController.h"
#import "DF1DevListController.h"
#import "DF1Lib.h"

@interface DF1DevDetailController ()
{
    NSTimer *reconnectTimer;
    BOOL isConnecting;
    double xyzUpdateTime;
    int connectionRetries;
    int subscriptionRetries;
}

@end


@implementation DF1DevDetailController

@synthesize df;

-(id)initWithDF:(DF1*) userdf
{
    self = [super init];
    if(self) {
        [self initializeCells];
        self.df = userdf;
        self.df.delegate = self;
    }
    return self; 
}

-(void)initializeCells
{
    if(!self.accXyzCell) {
        self.accXyzCell = [[AccXYZCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"AccXYZCell"];
        // do other default initialization here
        self.accXyzCell.accLabel.text = @"Acceleration";
    }
    if(!self.battCell) {
        self.battCell = [[BattCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"BattCell"];
        self.battCell.battLabel.text = @"Battery Level";
        self.battCell.battBar.progress = 1.0;
    }
    // if(!self.rssiCell) {
    //     self.rssiCell = [[RSSICell alloc] initWithStyle:UITableViewCellStyleDefault
    //                                           reuseIdentifier:@"RSSICell"];
    // }
}


-(void)viewDidLoad
{
    [super viewDidLoad];
     
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.navigationController) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.4
                                                                green:0.4 blue:0.9 alpha:0.5];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [(DF1DevListController*) self.previousVC willTransitionBack:self.df];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;    
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
    DF_DBG(@"indexpath row: %d", indexPath.row);
    if(indexPath.row==0) {
        return self.accXyzCell;
    }
    if(indexPath.row==1) {
        return self.battCell;
    }
    // if (indexPath.row==0 && [self.d isEnabled:@"Accelerometer service active"]) {
    //     [self.babyCell setPosition:UACellBackgroundViewPositionTop];
    //     return self.babyCell;
    // }
    // // Something has gone wrong, because we should never get here, return empty cell
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Unkown Cell"];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if(indexPath.row==0) return self.babyCell.height;
    return 100;
}


- (void) tableView:(UITableView*) tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
    }
    return @"";
}

-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
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

-(void) didConnect:(CBPeripheral*) peripheral
{
}

-(void) didUpdateRSSI:(CBPeripheral*) peripheral withRSSI:(float) rssi
{
}

-(void) receivedXYZ8:(double*) data
{
}

-(void) receivedXYZ14:(double*) data
{
}

@end
