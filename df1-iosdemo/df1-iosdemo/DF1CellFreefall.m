//
//  DF1DevDetailCells.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 4/27/16.
//  Copyright (c) 2013 Nicholas Breeser. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1CellFreefall.h"
#import "DF1DevDetailController.h"


@interface DF1CellFreefall ()
{
    NSUInteger accThsValuePrevious;
    NSUInteger accTmltValuePrevious;
}
@end

@implementation DF1CellFreefall

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    self.parent = parent;
    self.height = 65;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    accThsValuePrevious = [[defaults valueForKey:@"tapThs"] integerValue];
    accTmltValuePrevious = [[defaults valueForKey:@"tapTmlt"] integerValue];
    self.accLabel = [[UILabel alloc] init];
    self.accLabel.textAlignment = NSTextAlignmentRight;
    self.accLabel.font = [UIFont systemFontOfSize:16];
    self.accLabel.textColor = [UIColor grayColor];
    self.accLabel.backgroundColor = [UIColor clearColor];

    self.accValueTap = [[UILabel alloc] init];
    self.accValueTap.font = [UIFont systemFontOfSize:18];
    
    self.titleText = [[UILabel alloc] init];
    self.titleText.textAlignment = NSTextAlignmentCenter;
    self.titleText.font = [UIFont fontWithName:@"Avenir Next" size:15];
    self.titleText.textColor = [UIColor DFBlack];
    self.titleText.backgroundColor = [UIColor clearColor];
    self.titleText.text = @"Freefall Detection";
    
    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueTap];
    [self.contentView addSubview:self.titleText];

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;

    fr = CGRectMake(-30, 35, width, 25);
    self.accLabel.frame = fr;

    fr = CGRectMake(boundsX + 30, 35, 100, 25);
    self.accValueTap.frame = fr;
    
    self.titleText.frame = CGRectMake(0, 5, width, 30);

}

@end

