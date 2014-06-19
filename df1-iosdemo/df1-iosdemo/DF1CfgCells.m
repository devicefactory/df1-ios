#define DF_LEVEL 0
#import "DF1Lib.h"
#import "Utility.h"
#import "NSData+Conversion.h"
#import "DF1CfgCells.h"

// base class for config related cells
@implementation DF1CfgCell
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self==nil) return self;
    self.cfg = ucfg;
    self.height = 20; // default
    return self;
}
@end

// editable name config cell
@implementation DF1CfgCellName
@synthesize height,nameLabel,nameField;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self; 

    self.height = 50;
    // Initialization code
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentRight;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    // self.battLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel.textColor = [UIColor blackColor];
    // self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.text = @"Device Name";

    self.nameField = [[UITextField alloc] init];
    self.nameField.delegate = self;
    NSString *defaultName = [self.cfg objectForKey:@"defaultName"];
    self.nameField.placeholder = (defaultName==nil) ? @"DF1" : defaultName;
    [self.nameField addTarget:self action:@selector(handleTextFieldEdit:) forControlEvents:UIControlEventEditingDidEnd];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.nameField];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    self.nameLabel.frame = CGRectMake(5,   5, 110, 45);
    self.nameField.frame = CGRectMake(150, 5, 200, 45);
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    [c setValue:self.nameField.text forKey:@"defaultName"];
}

-(void) handleTextFieldEdit:(UITextField*) sender
{
    [self modifyChange:self.cfg];
    [sender resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField==self.nameField)
        [self.nameField resignFirstResponder];
    return NO;
}

#pragma mark - UITextFieldDelegate
@end


@implementation DF1CfgCellRange

@end


@implementation DF1CfgCellAuto

@end


@implementation DF1CfgCellBatt

@end


@implementation DF1CfgCellProx

@end


@implementation DF1CfgCellXyz

@end


@implementation DF1CfgCellTap

@end


