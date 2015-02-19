//
//  DF1DevDetailCells.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1CellAccTap.h"
#import "DF1DevDetailController.h"


@interface DF1CellAccTap ()
{
    NSUInteger accThsValuePrevious;
    NSUInteger accTmltValuePrevious;
}
@end

@implementation DF1CellAccTap

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    self.parent = parent;
    self.height = 140;
    accThsValuePrevious = 0;

    self.accLabel = [[UILabel alloc] init];
    self.accLabel.textAlignment = NSTextAlignmentRight;
    self.accLabel.font = [UIFont systemFontOfSize:16];
    self.accLabel.textColor = [UIColor grayColor];
    self.accLabel.backgroundColor = [UIColor clearColor];

    self.accValueTap = [[UILabel alloc] init];
    self.accValueTap.font = [UIFont systemFontOfSize:18];

    self.accThsLabel = [[UILabel alloc] init];
    self.accThsLabel.font = [UIFont systemFontOfSize:13];
    self.accThsLabel.text = @"Threshhold";
    self.accThsSlider = [[UISlider alloc] init];
    self.accThsSlider.continuous = true;
    [self.accThsSlider setMinimumValue:0];
    [self.accThsSlider setMaximumValue:31];
    [self.accThsSlider addTarget:self action:@selector(accThsChanged:)
               forControlEvents:UIControlEventValueChanged];

    self.accTmltLabel = [[UILabel alloc] init];
    self.accTmltLabel.font = [UIFont systemFontOfSize:13];
    self.accTmltLabel.text = @"TimeLimit";
    self.accTmltSlider = [[UISlider alloc] init];
    self.accTmltSlider.continuous = true;
    [self.accTmltSlider setMinimumValue:1];
    [self.accTmltSlider setMaximumValue:20];
    [self.accTmltSlider addTarget:self action:@selector(accTmltChanged:)
               forControlEvents:UIControlEventValueChanged];

    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueTap];
    [self.contentView addSubview:self.accThsLabel];
    [self.contentView addSubview:self.accThsSlider];
    [self.contentView addSubview:self.accTmltLabel];
    [self.contentView addSubview:self.accTmltSlider];
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

    fr = CGRectMake(boundsX + 30, 5, 100, 25);
    self.accValueTap.frame = fr;

    self.accThsLabel.frame  = CGRectMake(boundsX + 15, 35,  110,40);
    self.accThsSlider.frame = CGRectMake(boundsX + 120, 35, 180,40);

    self.accTmltLabel.frame  = CGRectMake(boundsX + 15,  35+35,  110,40);
    self.accTmltSlider.frame = CGRectMake(boundsX + 120, 35+35, 180,40);
}

-(IBAction) accThsChanged:(UISlider*)sender
{
    NSUInteger index = (NSUInteger)(self.accThsSlider.value);
    float gvalue = (float) index * 0.063f;
    DF_DBG(@"accThs gvalue %.4f",gvalue);
    if(index != accThsValuePrevious)
    {
        // notice we are changing all 3 threshholds
        [self.parent.df modifyTapThsz:gvalue];
        [self.parent.df modifyTapThsx:gvalue];
        [self.parent.df modifyTapThsy:gvalue];
    }
    // [self.accRangeSlider setValue:index animated:YES];
    self.accThsLabel.text = [[NSString alloc] initWithFormat:@"Thresh %.3fG",gvalue];
    accThsValuePrevious = index;
}

-(IBAction) accTmltChanged:(UISlider*)sender
{
    NSUInteger msec10 = (NSUInteger) self.accTmltSlider.value;
    float msec = (float) msec10 * 10.0f;
    DF_DBG(@"accTmlt %.0f", msec);
    if(msec10 != accTmltValuePrevious)
    {
        // notice we are changing all 3 threshholds
        [self.parent.df modifyTapTmlt:msec];
    }
    self.accTmltLabel.text = [[NSString alloc] initWithFormat:@"Tmlt %.0fms",msec];
    accTmltValuePrevious = msec10;
}
@end

