//
//  DF1ViewController.h
//  df1-iosdemo
//
//  Created by JB Kim on 3/23/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DF1Lib.h"

@interface DF1ViewController : UIViewController <DF1Delegate>

@property (strong,nonatomic) DF1 *df1;

@property (nonatomic,weak) IBOutlet UILabel *label;
-(IBAction) clearButton:(UIButton*)sender;
-(IBAction) scanButton:(UIButton*)sender;

@end
