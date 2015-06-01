//
//  DF1DevDetailCells.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1CellBatt.h"

@implementation DF1CellBatt

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

    fr = CGRectMake(boundsX + 30, 15, 60, 25);
    self.battLevel.frame = fr;

    // fr = CGRectMake((contentRect.origin.x + (contentRect.size.width / 2 ) - 75), 80,95,50);
    fr = CGRectMake(boundsX + 130, 35, 170,25);
    self.battBarHolder.frame = fr;
}

// - (void)setPosition:(UACellBackgroundViewPosition)newPosition {
//     [(UACellBackgroundView *)self.backgroundView setPosition:newPosition];
// }
@end

