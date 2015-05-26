//
//  DF1CellDistance.h
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/23/15.
//  Copyright (c) 2015 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DF1Cell.h"
#import "DF1Lib.h"

@interface DF1CellDistance : DF1Cell
@property (nonatomic,retain) UILabel *distanceText;
@property (nonatomic,retain) UILabel *RSSIText;

@property (nonatomic,retain) UILabel *distanceTitle;
@property (nonatomic,retain) UILabel *RSSITitle;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent;
@end
