//
//  DF1DevDetailCells.h
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F3PlotStrip.h"
#import "DF1Lib.h"

@class DF1DevDetailController;

@interface AccXYZCell : UITableViewCell
@property int height;
@property (nonatomic,strong) DF1DevDetailController *parent;
@property (nonatomic,retain) UILabel *accLabel;
@property (nonatomic,retain) UIImageView *accIcon;
@property (nonatomic,retain) UILabel *accValueX;
@property (nonatomic,retain) UILabel *accValueY;
@property (nonatomic,retain) UILabel *accValueZ;
@property (nonatomic,retain) IBOutlet F3PlotStrip *accXStrip;
@property (nonatomic,retain) UILabel *accXStripLabel;
@property (nonatomic,retain) IBOutlet F3PlotStrip *accYStrip;
@property (nonatomic,retain) UILabel *accYStripLabel;
@property (nonatomic,retain) IBOutlet F3PlotStrip *accZStrip;
@property (nonatomic,retain) UILabel *accZStripLabel;
// @property (nonatomic,retain) UIProgressView *accBarX;
// @property (nonatomic,retain) UIProgressView *accBarY;
// @property (nonatomic,retain) UIProgressView *accBarZ;
// @property (nonatomic,retain) UIView *accBarHolder;
// -(void)setPosition:(UACellBackgroundViewPosition)newPosition;
@property (nonatomic,retain) UILabel *accRangeLabel;
@property (nonatomic,retain) UISlider *accRangeSlider;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent;
-(IBAction) accSliderChanged:(UISlider*)sender;
@end

@interface AccTapCell : UITableViewCell
@property int height;
@property (nonatomic,retain) UILabel *accLabel;
@property (nonatomic,retain) UILabel *accValueTap;
@end

@interface BattCell : UITableViewCell
@property int height;
@property (nonatomic,retain) UILabel *battLabel;
@property (nonatomic,retain) UIImageView *battIcon;
@property (nonatomic,retain) UILabel *battLevel;
@property (nonatomic,retain) UIProgressView *battBar;
@property (nonatomic,retain) UIView *battBarHolder;
// -(void)setPosition:(UACellBackgroundViewPosition)newPosition;
@end

@interface RSSICell : UITableViewCell
@property int height;
@property (nonatomic,retain) UILabel *rssiLabel;
@property (nonatomic,retain) UIImageView *rssiIcon;
@property (nonatomic,retain) UILabel *rssiLevel;
@property (nonatomic,retain) UIProgressView *rssiBar;
@property (nonatomic,retain) UIView *rssiBarHolder;
// -(void)setPosition:(UACellBackgroundViewPosition)newPosition;
@end
