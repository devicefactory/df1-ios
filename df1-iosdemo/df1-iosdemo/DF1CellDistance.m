//
//  DF1CellDistance.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/23/15.
//  Copyright (c) 2015 JB Kim. All rights reserved.
//

#import "DF1CellDistance.h"

@implementation DF1CellDistance

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    //self.parent = parent;
    self.height = 100;
    
    self.distanceText = [[UILabel alloc] init];
    self.distanceText.textAlignment = NSTextAlignmentRight;
    self.distanceText.font = [UIFont systemFontOfSize:15];
    self.distanceText.textColor = [UIColor blackColor];
    self.distanceText.backgroundColor = [UIColor clearColor];
    
    self.RSSIText = [[UILabel alloc] init];
    self.RSSIText.textAlignment = NSTextAlignmentRight;
    self.RSSIText.font = [UIFont systemFontOfSize:15];
    self.RSSIText.textColor = [UIColor blackColor];
    self.RSSIText.backgroundColor = [UIColor clearColor];
    
    self.distanceTitle = [[UILabel alloc] init];
    self.distanceTitle.textAlignment = NSTextAlignmentLeft;
    self.distanceTitle.font = [UIFont boldSystemFontOfSize:15];
    self.distanceTitle.textColor = [UIColor blackColor];
    self.distanceTitle.backgroundColor = [UIColor clearColor];
    self.distanceTitle.text = @"distance";
    
    self.RSSITitle = [[UILabel alloc] init];
    self.RSSITitle.textAlignment = NSTextAlignmentLeft;
    self.RSSITitle.font = [UIFont boldSystemFontOfSize:15];
    self.RSSITitle.textColor = [UIColor blackColor];
    self.RSSITitle.backgroundColor = [UIColor clearColor];
    self.RSSITitle.text = @"RSSI";
    
    self.titleText = [[UILabel alloc] init];
    self.titleText.textAlignment = NSTextAlignmentCenter;
    self.titleText.font = [UIFont fontWithName:@"Avenir Next" size:15];
    self.titleText.textColor = [UIColor DFBlack];
    self.titleText.backgroundColor = [UIColor clearColor];
    self.titleText.text = @"Approximate Distance";
    
    [self.contentView addSubview:self.distanceText];
    [self.contentView addSubview:self.RSSIText];
    [self.contentView addSubview:self.distanceTitle];
    [self.contentView addSubview:self.RSSITitle];
    [self.contentView addSubview:self.titleText];
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //CGFloat boundsX = self.contentView.bounds.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    
    self.distanceTitle.frame = CGRectMake(30, 35, width, 20);
    self.RSSITitle.frame = CGRectMake(30, 65, width, 20);
    self.distanceText.frame = CGRectMake(-30, 35, width, 20);
    self.RSSIText.frame = CGRectMake(-30, 65, width, 20);
    self.titleText.frame = CGRectMake(0, 5, width, 30);
    
}

@end
