//
//  DF1CellGMagnitude.h
//  
//
//  Created by Nicholas Breeser on 3/14/15.
//
//

#import <UIKit/UIKit.h>
#import "DF1Cell.h"
#import "DF1Lib.h"
#import "UIColor+DF1Colors.h"

@interface DF1CellAccMagnitude : DF1Cell
@property (nonatomic,retain) UILabel *titleText;
@property (nonatomic,retain) UILabel *magText;
@property (nonatomic,retain) UILabel *maxMagText;
@property (nonatomic,retain) UILabel *avgMagText;
@property (nonatomic,retain) UILabel *maxMagTitleText;
@property (nonatomic,retain) UILabel *avgMagTitleText;
@property (nonatomic,retain) UILabel *magTitleText;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent;
@end
