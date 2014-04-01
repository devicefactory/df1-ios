//
//  DF1ViewController.m
//  df1-iosdemo
//
//  Created by JB Kim on 3/23/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//

#import "DF1ViewController.h"

@interface DF1ViewController ()

@end

@implementation DF1ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"allocating DF1Lib");
    self.df1 = [[DF1 alloc] initWithDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) clearButton:(UIButton*)sender
{
    [self.label setText:@"disconnecting all devices"];
    [self.df1 disconnect:nil]; // disconnects all previously connected peripherals
}

-(IBAction) scanButton:(UIButton*)sender
{
    [self.label setText:@"scanning"];
    [self.df1 scan:5];
}

#pragma mark - DF1 delegate

- (bool) didScan:(NSArray*) devices
{
    NSLog(@"found %d devices", devices.count);
    [self.label setText:@"received bLE devices"];

    for(int i=0; i<devices.count; i++)
    {
        CBPeripheral *p = [devices objectAtIndex:i];
        if([p.name rangeOfString:@"DFMove" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            NSLog(@"connecting to df1 device %@", p);
            [self.df1 connect:p];
            return false;
        }
    }
    return true; // return value is a boolean to question: keepScanning?
}


@end
