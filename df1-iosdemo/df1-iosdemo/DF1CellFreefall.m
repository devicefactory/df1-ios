//
//  DF1DevDetailCells.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
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
    self.height = 45;
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

    fr = CGRectMake(boundsX + 5, 8, width-50, 25);
    self.accLabel.frame = fr;

    fr = CGRectMake(boundsX + 30, 8, 100, 25);
    self.accValueTap.frame = fr;

}

@end

