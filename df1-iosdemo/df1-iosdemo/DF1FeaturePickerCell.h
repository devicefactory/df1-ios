//
//  DF1FeaturePicker.h
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/17/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DF1FeaturePickerCell : UITableViewCell <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, retain) UIPickerView *picker;
@property NSMutableArray *dataArray;
@property NSNumber *height;
@end
