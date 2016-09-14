//
//  DF1CellAccTap.h
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DF1Lib.h"
#import "DF1Cell.h"

@interface DF1CellFlip : DF1Cell
@property int height;
@property (nonatomic,strong) DF1DevDetailController *parent;
@property (nonatomic,retain) UILabel *titleText;
@property (nonatomic,retain) UILabel *accLabel;
@property (nonatomic,retain) UILabel *accValueTap;
@property (nonatomic,retain) UILabel *accThsLabel;
@property (nonatomic,retain) UISlider *accThsSlider;
@property (nonatomic,retain) UILabel *accTmltLabel;
@property (nonatomic,retain) UISlider *accTmltSlider;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent;
@end
