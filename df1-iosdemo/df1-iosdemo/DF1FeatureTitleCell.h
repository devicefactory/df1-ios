//
//  DF1FeatureTitleCell.h
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/17/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+DF1Colors.h"
#import "DF1FeaturepickerCell.h"

@interface DF1FeatureTitleCell : UITableViewCell
@property (nonatomic, retain) UILabel *featureTitle;
@property (nonatomic, retain) UIButton *changeFeatureSetBtn;
@property NSNumber *height;
@end
