//
//  DF1FeaturePicker.h
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/17/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SECTION2 @"DF1CfgXYZPlotter",@"DF1CfgTap",@"DF1CfgFlip",@"DF1CfgCSVDataRecorder",@"DF1CfgBatteryLevel",@"DF1CfgMagnitudeValues",@"DF1CfgTop10",@"DF1CfgDistance",@"DF1CfgFreefall", nil

@interface DF1FeaturePickerCell : UITableViewCell <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, retain) UIPickerView *picker;
@property NSMutableArray *dataArray;
@property NSNumber *height;
@property UIButton *deleteCaseBtn;
@end
