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
        self.height = 65;
        self.battLabel = [[UILabel alloc] init];
        self.battLabel.textAlignment = NSTextAlignmentCenter;
        self.battLabel.font = [UIFont fontWithName:@"Avenir Next" size:15];
        self.battLabel.textColor = [UIColor DFBlack];
        self.battLabel.backgroundColor = [UIColor clearColor];
        self.battLabel.text = @"Battery Level";

        self.battLevel = [[UILabel alloc] init];
        self.battLevel.textAlignment = NSTextAlignmentLeft;
        self.battLabel.font = [UIFont fontWithName:@"Avenir Next" size:15];
        self.battLabel.textColor = [UIColor DFBlack];
        self.battLevel.backgroundColor = [UIColor clearColor];

        self.battIcon = [[UIImageView alloc] init];
        self.battIcon.image = [UIImage imageNamed:@"en_top1.png"];
        [self.battIcon setAutoresizingMask:UIViewAutoresizingNone];
        self.battIcon.contentMode = UIViewContentModeScaleAspectFit;

        self.battBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 170, 25)];
        self.battBar.progress = 0.0f;
        [self.battBar setTransform:CGAffineTransformMakeScale(1.0, 3.0)];
        
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

    fr = CGRectMake(boundsX + 30, 30, width, 25);
    self.battLevel.frame = fr;

    self.battLabel.frame = CGRectMake(0, 5, width, 30);
    
    fr = CGRectMake(boundsX + 115, 45, 170,25);
    self.battBarHolder.frame = fr;
}

@end

