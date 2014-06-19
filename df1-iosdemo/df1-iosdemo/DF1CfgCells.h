#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"

#define SECTION0 @"DF1CfgCellName",@"DF1CfgCellRange",@"DF1CfgCellAuto",nil 
#define SECTION1 @"DF1CfgCellBatt",@"DF1CfgCellProx",nil 

@interface DF1CfgCell : UITableViewCell
// will be provided from external source
@property (strong,nonatomic) NSMutableDictionary *cfg;
// to be overloaded later
@property int height;
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg;
-(void) modifyChange:(NSMutableDictionary*) c;
@end


@interface DF1CfgCellName : DF1CfgCell <UITextFieldDelegate>
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UITextField *nameField;
-(void) modifyChange:(NSMutableDictionary*) c;
-(void) handleTextFieldEdit:(UITextField*) sender;
@end


@interface DF1CfgCellRange : DF1CfgCell

@end


@interface DF1CfgCellAuto : DF1CfgCell

@end


@interface DF1CfgCellBatt : DF1CfgCell

@end


@interface DF1CfgCellProx : DF1CfgCell

@end


@interface DF1CfgCellXyz : DF1CfgCell

@end


@interface DF1CfgCellTap : DF1CfgCell

@end
