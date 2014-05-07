//
//  DF1DevDetailCells.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#import "DF1DevDetailCells.h"

@implementation AccXYZCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;  
    self.height = 150;

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

    [self.contentView addSubview:self.accIcon];
    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueX];
    [self.contentView addSubview:self.accValueY];
    [self.contentView addSubview:self.accValueZ];
    [self.contentView addSubview:self.accXStrip];
    [self.contentView addSubview:self.accYStrip];
    [self.contentView addSubview:self.accZStrip];
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
    // fr = CGRectMake((contentRect.origin.x + (contentRect.size.width / 2 ) - 75), 80,95,50);
    // fr = CGRectMake(boundsX + 130, 35, 170,25);
    // self.accBarHolder.frame = fr;

}
@end


@implementation AccTapCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    self.height = 80;

    self.accLabel = [[UILabel alloc] init];
    self.accLabel.textAlignment = NSTextAlignmentRight;
    self.accLabel.font = [UIFont systemFontOfSize:16];
    self.accLabel.textColor = [UIColor grayColor];
    self.accLabel.backgroundColor = [UIColor clearColor];

    self.accValueTap = [[UILabel alloc] init];
    self.accValueTap.font = [UIFont systemFontOfSize:18];

    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueTap];
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;

    fr = CGRectMake(boundsX + 5, 5, width-50, 25);
    self.accLabel.frame = fr;

    fr = CGRectMake(boundsX + 30, 35, 180, 25);
    self.accValueTap.frame = fr;
}
@end



@implementation BattCell

@synthesize battLabel,battIcon,battLevel,battBar,height,battBarHolder;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // self.backgroundView = [[UACellBackgroundView alloc] initWithFrame:CGRectZero];
        self.height = 50;
        // Initialization code
        self.battLabel = [[UILabel alloc] init];
        self.battLabel.textAlignment = NSTextAlignmentRight;
        // self.battLabel.font = [UIFont boldSystemFontOfSize:17];
        self.battLabel.font = [UIFont systemFontOfSize:16];
        self.battLabel.textColor = [UIColor grayColor];
        self.battLabel.backgroundColor = [UIColor clearColor];

        self.battLevel = [[UILabel alloc] init];
        self.battLevel.textAlignment = NSTextAlignmentLeft;
        self.battLevel.font = [UIFont systemFontOfSize:22];
        // self.battLevel.textColor = [UIColor blueColor];
        self.battLevel.backgroundColor = [UIColor clearColor];

        self.battIcon = [[UIImageView alloc] init];
        self.battIcon.image = [UIImage imageNamed:@"en_top1.png"];
        [self.battIcon setAutoresizingMask:UIViewAutoresizingNone];
        self.battIcon.contentMode = UIViewContentModeScaleAspectFit;

        self.battBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 170, 25)];
        self.battBar.progress = 0.0f;
        // self.battBar.transform = CGAffineTransformRotate(self.battBar.transform, -M_PI/2 .0);
        self.battBar.transform = CGAffineTransformRotate(self.battBar.transform, 0.0);
        self.battBar.progressTintColor = [UIColor greenColor];
        self.battBarHolder = [[UIView alloc] init];
        [self.battBarHolder addSubview:self.battBar];

        [self.contentView addSubview:self.battLabel];
        [self.contentView addSubview:self.battLevel];
        [self.contentView addSubview:self.battIcon];
        [self.contentView addSubview:self.battBarHolder];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;

    fr = CGRectMake(boundsX + 5, 10, 50, 50);
    self.battIcon.frame = fr;

    fr = CGRectMake(boundsX + 5, 5, width-50, 25);
    self.battLabel.textAlignment = NSTextAlignmentRight;
    self.battLabel.frame = fr;

    fr = CGRectMake(boundsX + 55, 15, 60, 25);
    self.battLevel.frame = fr;

    // fr = CGRectMake((contentRect.origin.x + (contentRect.size.width / 2 ) - 75), 80,95,50);
    fr = CGRectMake(boundsX + 130, 35, 170,25);
    self.battBarHolder.frame = fr;
}

// - (void)setPosition:(UACellBackgroundViewPosition)newPosition {
//     [(UACellBackgroundView *)self.backgroundView setPosition:newPosition];
// }
@end


@implementation RSSICell

@end

