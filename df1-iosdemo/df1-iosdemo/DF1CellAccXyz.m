//
//  DF1CellAccXyz.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1Cell.h"
#import "DF1DevDetailController.h"

@interface DF1CellAccXyz ()
{
    NSUInteger accSliderValuePrevious;
}

@end

@implementation DF1CellAccXyz

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    self.parent = parent;
    self.height = 160;

    // self.accBarX = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 170, 25)];
    // self.accBarX.progress = 0.0f;
    // self.accBarX.transform = CGAffineTransformRotate(self.accBarX.transform, -M_PI/2 .0);
    // self.accBarX.transform = CGAffineTransformRotate(self.accBarX.transform, 0.0);
    // self.accBarX.progressTintColor = [UIColor redColor];
    // self.accBarHolder = [[UIView alloc] init];
    // [self.accBarHolder addSubview:self.accBarX];

    // Initialization code
    self.accLabel = [[UILabel alloc] init];
    self.accLabel.textAlignment = NSTextAlignmentRight;
    self.accLabel.font = [UIFont systemFontOfSize:16];
    self.accLabel.textColor = [UIColor grayColor];
    self.accLabel.backgroundColor = [UIColor clearColor];

    self.accIcon = [[UIImageView alloc] init];
    self.accIcon.image = [UIImage imageNamed:@"en_top1.png"];
    [self.accIcon setAutoresizingMask:UIViewAutoresizingNone];
    self.accIcon.contentMode = UIViewContentModeScaleAspectFit;

    // X - value
    self.accValueX = [[UILabel alloc] init];
    self.accValueX.font = [UIFont systemFontOfSize:14];
    // plot strip
    self.accXStripLabel = [[UILabel alloc] init];
    self.accXStrip = [[F3PlotStrip alloc] initWithFrame:CGRectMake(0,0,180,30)];
    self.accXStrip.backgroundColor = [UIColor clearColor];
    self.accXStrip.capacity = 180;
    self.accXStrip.baselineValue = 0.0;
    self.accXStrip.lineColor = [UIColor redColor];
    self.accXStrip.showDot = YES;
    self.accXStrip.labelFormat = @"Accelerometer X value: (%0.02f)";
    self.accXStrip.label = self.accXStripLabel;
    
    // Y - value
    self.accValueY = [[UILabel alloc] init];
    self.accValueY.font = [UIFont systemFontOfSize:14];
    // plot strip
    self.accYStripLabel = [[UILabel alloc] init];
    self.accYStrip = [[F3PlotStrip alloc] initWithFrame:CGRectMake(0,0,180,30)];
    self.accYStrip.backgroundColor = [UIColor clearColor];
    self.accYStrip.capacity = 180;
    self.accYStrip.baselineValue = 0.0;
    self.accYStrip.lineColor = [UIColor greenColor];
    self.accYStrip.showDot = YES;
    self.accYStrip.labelFormat = @"Accelerometer Y value: (%0.02f)";
    self.accYStrip.label = self.accYStripLabel;

    // Z - value
    self.accValueZ = [[UILabel alloc] init];
    self.accValueZ.font = [UIFont systemFontOfSize:14];
    // plot strip
    self.accZStripLabel = [[UILabel alloc] init];
    self.accZStrip = [[F3PlotStrip alloc] initWithFrame:CGRectMake(0,0,180,30)];
    self.accZStrip.backgroundColor = [UIColor clearColor];
    self.accZStrip.capacity = 180;
    self.accZStrip.baselineValue = 0.0;
    self.accZStrip.lineColor = [UIColor blueColor];
    self.accZStrip.showDot = YES;
    self.accZStrip.labelFormat = @"Accelerometer Z value: (%0.02f)";
    self.accZStrip.label = self.accZStripLabel;
    
//    self.accRangeLabel = [[UILabel alloc] init];
//    self.accRangeLabel.font = [UIFont systemFontOfSize:14];
//    self.accRangeLabel.text = @"Range 2G";
//    self.accRangeSlider = [[UISlider alloc] init];
//    self.accRangeSlider.continuous = true;
//    [self.accRangeSlider setMinimumValue:2];
//    [self.accRangeSlider setMaximumValue:8];
//    
//    [self.accRangeSlider addTarget:self action:@selector(accSliderChanged:)
//               forControlEvents:UIControlEventValueChanged];
//    accSliderValuePrevious = 2;

    [self.contentView addSubview:self.accIcon];
    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueX];
    [self.contentView addSubview:self.accValueY];
    [self.contentView addSubview:self.accValueZ];
    [self.contentView addSubview:self.accXStrip];
    [self.contentView addSubview:self.accYStrip];
    [self.contentView addSubview:self.accZStrip];
    // [self.contentView addSubview:self.accRangeLabel];
    // [self.contentView addSubview:self.accRangeSlider];
    // [self.contentView addSubview:self.accBarHolder];
    return self;
}

-(void)layoutSubviews
{ 
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;

    fr = CGRectMake(boundsX + 5, 10, 50, 50);
    self.accIcon.frame = fr;
    fr = CGRectMake(boundsX + 5, 5, width-50, 25);
    self.accLabel.frame = fr;

    fr = CGRectMake(boundsX + 30, 35, 80, 25);
    self.accValueX.frame = fr;
    fr = CGRectMake(boundsX + 120, 35, 180,30);
    self.accXStrip.frame = fr;

    fr = CGRectMake(boundsX + 30, 35+35, 80, 25);
    self.accValueY.frame = fr;
    fr = CGRectMake(boundsX + 120, 35+35, 180,30);
    self.accYStrip.frame = fr;

    fr = CGRectMake(boundsX + 30, 35+35+35, 80, 25);
    self.accValueZ.frame = fr;
    fr = CGRectMake(boundsX + 120, 35+35+35, 180,30);
    self.accZStrip.frame = fr;
    
//    fr = CGRectMake(boundsX + 15, 35+35+35+35, 70,40);
//    self.accRangeLabel.frame = fr;
//    fr = CGRectMake(boundsX + 120, 35+35+35+35, 180,40);
//    self.accRangeSlider.frame = fr;
    // fr = CGRectMake((contentRect.origin.x + (contentRect.size.width / 2 ) - 75), 80,95,50);
    // fr = CGRectMake(boundsX + 130, 35, 170,25);
    // self.accBarHolder.frame = fr;

}

-(IBAction) accSliderChanged:(UISlider*)sender
{
//    NSUInteger index = (NSUInteger)(self.accRangeSlider.value + 0.5); // Round the number.
//    if(2<index && index<3)       { index = 2; }
//    else if(3<=index && index<6) { index = 4; }
//    else if(6<=index)            { index = 8; }
//    
//    if(accSliderValuePrevious != index)
//    {
//        [self.parent.df modifyRange:index];
//    }
//    [self.accRangeSlider setValue:index animated:NO];
//    self.accRangeLabel.text = [[NSString alloc] initWithFormat:@"Range %dG",index];
//    accSliderValuePrevious = index;
}
@end

