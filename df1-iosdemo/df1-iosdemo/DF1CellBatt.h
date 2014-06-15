//
//  DF1CellBatt.h
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DF1Lib.h"
#import "DF1Cell.h"

@interface DF1CellBatt : DF1Cell
@property int height;
@property (nonatomic,retain) UILabel *battLabel;
@property (nonatomic,retain) UIImageView *battIcon;
@property (nonatomic,retain) UILabel *battLevel;
@property (nonatomic,retain) UIProgressView *battBar;
@property (nonatomic,retain) UIView *battBarHolder;
// -(void)setPosition:(UACellBackgroundViewPosition)newPosition;
@end

