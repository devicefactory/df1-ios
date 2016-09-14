#define DF_LEVEL 0
#import "DF1Lib.h"
#import "Utility.h"
#import "NSData+Conversion.h"
#import "DF1CfgCells.h"

#define PAD_LEFT 20
#define PAD_TOP 5

//
// base class for config related cells
//
@implementation DF1CfgCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self==nil) return self;
    self.cfg = ucfg;
    self.height = 20; // default
    self.df.delegate = self;
    [self.df connect:self.df.p];
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
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.text = @"Device Name";

    self.nameField = [[UITextField alloc] init];
    self.nameField.delegate = self;
    NSString *defaultName = [self.cfg objectForKey:CFG_NAME];
    self.nameField.placeholder = (defaultName==nil) ? @"DF1" : defaultName;
    [self.nameField addTarget:self action:@selector(handleTextFieldEdit:) forControlEvents:UIControlEventEditingDidEnd];
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.nameField];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    // CGRect contentRect = self.contentView.bounds;
    // CGFloat boundsX = contentRect.origin.x;
    // CGFloat width = self.contentView.bounds.size.width;
    // CGRect fr;
    self.nameLabel.frame = CGRectMake(PAD_LEFT,     PAD_TOP, 110, 45);
    self.nameField.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 200, 45);
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    DF_DBG(@"nameField text: %@", self.nameField.text);
    [c setValue:self.nameField.text forKey:CFG_NAME];
    
    
    NSLog(@"the cfg dict is %@", c);
    
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

@end


// 2,4,8G range selector
@interface DF1CfgCellRange ()
{
    NSUInteger accRangeValue;
}
@end

@implementation DF1CfgCellRange

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    
    self.cfg = ucfg;
    self.height = 50;
    // Initialization code
    self.accRangeLabel = [[UILabel alloc] init];
    self.accRangeLabel.font = [UIFont boldSystemFontOfSize:16];
    self.accRangeLabel.textAlignment = NSTextAlignmentLeft;
    
    _control = [[UISegmentedControl alloc] initWithItems:@[@"2G", @"4G",@"8G"]];
    [_control addTarget:self action:@selector(updateRange:) forControlEvents: UIControlEventValueChanged];
    _control.tintColor = [UIColor DFRed];
    
    accRangeValue = 0;
    if ([self.cfg objectForKey:CFG_XYZ8_RANGE]!=nil) {
        NSNumber *n = (NSNumber*) [self.cfg objectForKey:CFG_XYZ8_RANGE];
        accRangeValue = [n intValue];
    }
    else {
        NSLog(@"The range is nil, something is likely wrong");
    }
    
    _control.selectedSegmentIndex = accRangeValue;
    
    self.accRangeLabel.text = [[NSString alloc] initWithFormat:@"Range"];
    [self.contentView addSubview:self.accRangeLabel];
    [self.contentView addSubview:self.control];
    return self;
}

-(void) updateRange :(UISegmentedControl *)segment {
    accRangeValue = segment.selectedSegmentIndex;
    [self modifyChange:self.cfg];

}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.accRangeLabel.frame = CGRectMake(PAD_LEFT,      PAD_TOP, 110, 45);
    self.control.frame = CGRectMake(PAD_LEFT+130, PAD_TOP+7, 150, 25);
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    [c setValue:[NSNumber numberWithInteger:accRangeValue] forKey:CFG_XYZ8_RANGE];
    [self.df modifyRange:accRangeValue];
}

@end



@interface DF1CfgCellRes ()
{
    NSUInteger acc14BitOnOff;
}
@end

@implementation DF1CfgCellRes

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    
    self.cfg = ucfg;
    self.height = 50;
    // Initialization code
    self.accResLabel = [[UILabel alloc] init];
    self.accResLabel.font = [UIFont boldSystemFontOfSize:16];
    self.accResLabel.textAlignment = NSTextAlignmentLeft;
    
    // self.accRangeLabel.text = @"G Range";
    
    //Change the below to a UI
    
    _control = [[UISegmentedControl alloc] initWithItems:@[@"8 bit", @"14bit"]];
    [_control addTarget:self action:@selector(updateResolution:) forControlEvents: UIControlEventValueChanged];
    _control.tintColor = [UIColor DFRed];

    if ([self.cfg objectForKey:CFG_XYZ14_ON]!=nil) {
        NSNumber *n = (NSNumber*) [self.cfg objectForKey:CFG_XYZ14_ON];
        acc14BitOnOff = [n intValue];
    }
    
    //[self.accResSwitch setOn:(bool)acc14BitOnOff animated:YES];
    _control.selectedSegmentIndex = acc14BitOnOff;

    self.accResLabel.text = [[NSString alloc] initWithFormat:@"Resolution"];
    [self.contentView addSubview:self.accResLabel];
    [self.contentView addSubview:_control];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.accResLabel.frame =  CGRectMake(PAD_LEFT,     PAD_TOP, 150, 45);
    self.control.frame = CGRectMake(PAD_LEFT+130, PAD_TOP+7, 150, 25);
    
}


-(void) modifyChange:(NSMutableDictionary*) c
{
    [c setValue:[NSNumber numberWithInteger:acc14BitOnOff] forKey:CFG_XYZ14_ON];
}


-(void) updateResolution :(UISegmentedControl *)segment {
    
    acc14BitOnOff = segment.selectedSegmentIndex;
    [self modifyChange:self.cfg];
}

@end



// 1Hz - 50Hz sampling slider.
@interface DF1CfgCellFreqRange ()
{
    NSUInteger accFreqValue;
}
@end

@implementation DF1CfgCellFreqRange

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    
    self.cfg = ucfg;
    self.height = 50;
    // Initialization code
    self.accRangeLabel = [[UILabel alloc] init];
    self.accRangeLabel.font = [UIFont boldSystemFontOfSize:16];
    self.accRangeLabel.textAlignment = NSTextAlignmentLeft;
    
    // self.accRangeLabel.text = @"G Range";
    self.accRangeSlider = [[UISlider alloc] init];
    self.accRangeSlider.continuous = true;
    self.accRangeSlider.tintColor = [UIColor DFRed];
    [self.accRangeSlider setMinimumValue:1];
    [self.accRangeSlider setMaximumValue:50];
    
    [self.accRangeSlider addTarget:self action:@selector(accSliderChanged:)
                  forControlEvents:UIControlEventValueChanged];
    accFreqValue = 5;
    if ([self.cfg objectForKey:CFG_XYZ_FREQ]!=nil) {
        NSNumber *n = (NSNumber*) [self.cfg objectForKey:CFG_XYZ_FREQ];
        accFreqValue = [n intValue];
    }
    [self.accRangeSlider setValue:(float)accFreqValue];
    self.accRangeLabel.text = [[NSString alloc] initWithFormat:@"Freq %luHz",(unsigned long)accFreqValue];
    
    [self.contentView addSubview:self.accRangeLabel];
    [self.contentView addSubview:self.accRangeSlider];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.accRangeLabel.frame = CGRectMake(PAD_LEFT,      PAD_TOP, 110, 45);
    self.accRangeSlider.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 150, 45);
}

-(void) modifyChange:(NSMutableDictionary*) c
{
    [c setValue:[NSNumber numberWithInteger:accFreqValue] forKey:CFG_XYZ_FREQ];
}

-(void) accSliderChanged:(UITextField*) sender
{
    NSUInteger currentAccFreqValue = (NSUInteger)(self.accRangeSlider.value); // Round the number.

    if(currentAccFreqValue != accFreqValue)
    {
        accFreqValue = currentAccFreqValue;
        [self modifyChange:self.cfg];
        [sender resignFirstResponder];
    }
    
    [self.accRangeSlider setValue:currentAccFreqValue animated:NO];
    self.accRangeLabel.text = [[NSString alloc] initWithFormat:@"Freq %luHz",(unsigned long)accFreqValue];
}

@end

@implementation DF1CfgCellAuto
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    self.cfg = ucfg;
    self.height = 30;
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
}

-(void)modifyChange:(NSMutableDictionary *)c {
    
}

@end


@implementation DF1CfgXYZPlotter
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgXYZPlotter"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgXYZPlotter"]];
    }
    self.cfg = ucfg;
    self.height = 40;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];
    // JB: when adding more features, change here first
    //CHANGE IN CONTROLLER
    self.featureLabel.text = @"XYZ Plotter";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgXYZPlotter"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleBtnPressed {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgXYZPlotter"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgXYZPlotter"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}

-(void)modifyChange:(NSMutableDictionary *)c {
    
}

@end

@interface DF1CfgTap ()
{
    NSUInteger accThsValuePrevious;
    NSUInteger accTmltValuePrevious;
}
@end

@implementation DF1CfgTap
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgTap"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgTap"]];
    }
    
    self.cfg = ucfg;
    self.height = 140;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];
    self.featureLabel.text = @"Tap Detector";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgTap"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleFeature) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Nick: JB was zeroing accThsValuePrevious. Was there a reason for this? I am persisting the value with NSUserDefaults.
    accThsValuePrevious = [[defaults valueForKey:@"tapThs"] integerValue];
    accTmltValuePrevious = [[defaults valueForKey:@"tapTmlt"] integerValue];
    
    
    self.accLabel = [[UILabel alloc] init];
    self.accLabel.textAlignment = NSTextAlignmentRight;
    self.accLabel.font = [UIFont systemFontOfSize:16];
    self.accLabel.textColor = [UIColor grayColor];
    self.accLabel.backgroundColor = [UIColor clearColor];
    
    self.accValueTap = [[UILabel alloc] init];
    self.accValueTap.font = [UIFont systemFontOfSize:18];
    
    self.accThsLabel = [[UILabel alloc] init];
    self.accThsLabel.font = [UIFont systemFontOfSize:14];
    self.accThsLabel.text = @"Mag";
    self.accThsSlider = [[UISlider alloc] init];
    self.accThsSlider.continuous = true;
    self.accThsSlider.tintColor = [UIColor DFRed];
    [self.accThsSlider setMinimumValue:0];
    [self.accThsSlider setMaximumValue:31];
    [self.accThsSlider addTarget:self action:@selector(accThsChanged:)
                forControlEvents:UIControlEventValueChanged];
    if([self.cfg objectForKey:CFG_TAP_THSZ]){
        float value = [[self.cfg objectForKey:CFG_TAP_THSZ] floatValue];
        //Nick: SOMETHING IS WRONG WITH THIS VALUE SETTING. I am unsure where the constants are coming from in this threshold.
        [self.accThsSlider setValue:(NSUInteger)value/0.063f animated:YES];
        self.accThsLabel.text = [[NSString alloc] initWithFormat:@"Mag %.3fG",value];
    }
    
    self.accTmltLabel = [[UILabel alloc] init];
    self.accTmltLabel.font = [UIFont systemFontOfSize:14];
    self.accTmltLabel.text = @"Time";
    self.accTmltSlider = [[UISlider alloc] init];
    self.accTmltSlider.continuous = true;
    self.accTmltSlider.tintColor = [UIColor DFRed];
    [self.accTmltSlider setMinimumValue:1];
    [self.accTmltSlider setMaximumValue:20];
    [self.accTmltSlider addTarget:self action:@selector(accTmltChanged:)
                 forControlEvents:UIControlEventValueChanged];
    if([self.cfg objectForKey:CFG_TAP_TMLT])
    {
        float value = [[self.cfg objectForKey:CFG_TAP_TMLT] floatValue];
        [self.accTmltSlider setValue:(NSUInteger)value animated:YES];
        self.accTmltLabel.text = [[NSString alloc] initWithFormat:@"Time %.0fms",10*value];
    }
    
    
    [self.contentView addSubview:self.accLabel];
    [self.contentView addSubview:self.accValueTap];
    [self.contentView addSubview:self.accThsLabel];
    [self.contentView addSubview:self.accThsSlider];
    [self.contentView addSubview:self.accTmltLabel];
    [self.contentView addSubview:self.accTmltSlider];
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleFeature {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgTap"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgTap"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
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
    
    // self.accRangeLabel.frame = CGRectMake(PAD_LEFT,      PAD_TOP, 110, 45);
    // self.accRangeSlider.frame = CGRectMake(PAD_LEFT+130, PAD_TOP, 150, 45);
    self.accThsLabel.frame  = CGRectMake(PAD_LEFT,     PAD_TOP+40,  110, 45);
    self.accThsSlider.frame = CGRectMake(PAD_LEFT+130, PAD_TOP+40, 150,45);
    self.accThsSlider.tintColor = [UIColor DFRed];
    self.accTmltLabel.frame  = CGRectMake(PAD_LEFT,    PAD_TOP+35+40,  110, 45);
    self.accTmltSlider.frame = CGRectMake(PAD_LEFT+130,PAD_TOP+35+40, 150,45);
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}

-(IBAction) accThsChanged:(UISlider*)sender
{
    NSUInteger index = (NSUInteger)(self.accThsSlider.value);
    float gvalue = (float) index * 0.063f;
    DF_DBG(@"accThs gvalue %.4f",gvalue);
    if(index != accThsValuePrevious)
    {
        // notice we are changing all 3 threshholds
        [self.cfg setValue:[NSNumber numberWithFloat:gvalue] forKey:CFG_TAP_THSZ];
        [self.cfg setValue:[NSNumber numberWithFloat:gvalue] forKey:CFG_TAP_THSY];
        [self.cfg setValue:[NSNumber numberWithFloat:gvalue] forKey:CFG_TAP_THSX];
    }
    // [self.accRangeSlider setValue:index animated:YES];
    self.accThsLabel.text = [[NSString alloc] initWithFormat:@"Mag %.3fG",gvalue];
    accThsValuePrevious = index;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:accThsValuePrevious] forKey:@"tapThs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction) accTmltChanged:(UISlider*)sender
{
    NSUInteger msec10 = (NSUInteger) self.accTmltSlider.value;
    float msec = (float) msec10 * 10.0f;
    DF_DBG(@"accTmlt %.0f", msec);
    if(msec10 != accTmltValuePrevious)
    {
        // notice we are changing all 3 threshholds
        [self.cfg setValue:[NSNumber numberWithFloat:msec10] forKey:CFG_TAP_TMLT];
    }
    self.accTmltLabel.text = [[NSString alloc] initWithFormat:@"Time %.0fms",msec];
    accTmltValuePrevious = msec10;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:accTmltValuePrevious] forKey:@"tapTmlt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation DF1CfgDistance
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgDistance"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgDistance"]];
    }
    self.cfg = ucfg;
    self.height = 40;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];

    self.featureLabel.text = @"Signal Strength";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgDistance"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleBtnPressed {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgDistance"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgDistance"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}
@end


@implementation DF1CfgCSVDataRecorder
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgCSVDataRecorder"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgCSVDataRecorder"]];
    }
    
    self.cfg = ucfg;
    self.height = 40;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];
    self.featureLabel.text = @"CSV Recorder";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgCSVDataRecorder"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleFeature) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleFeature {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgCSVDataRecorder"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgCSVDataRecorder"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}
@end

@implementation DF1CfgFreefall
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgFreefall"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgFreefall"]];
    }
    
    self.cfg = ucfg;
    self.height = 40;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];
    self.featureLabel.text = @"Freefall";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgFreefall"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleFeature) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleFeature {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgFreefall"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgFreefall"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}
@end

@implementation DF1CfgBatteryLevel
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgBatteryLevel"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgBatteryLevel"]];
    }
    
    self.cfg = ucfg;
    self.height = 40;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];
    self.featureLabel.text = @"Battery Level";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgBatteryLevel"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleFeature) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleFeature {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgBatteryLevel"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgBatteryLevel"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}
@end

@implementation DF1CfgMagnitudeValues
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil) {
        return self;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgMagnitudeValues"] isEqual:nil]){
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgMagnitudeValues"]];
    }
    
    self.cfg = ucfg;
    self.height = 40;
    self.featureLabel = [[UILabel alloc] init];
    self.featureLabel.textAlignment = NSTextAlignmentLeft;
    self.featureLabel.font = [UIFont systemFontOfSize:16];
    self.featureLabel.textColor = [UIColor grayColor];
    self.featureLabel.backgroundColor = [UIColor clearColor];
    self.featureLabel.text = @"Magnitudes";
    self.featureToggle = [[UIButton alloc]initWithFrame:CGRectMake(5, 5,30,30)];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DF1CfgMagnitudeValues"] boolValue]) {
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    [self.featureToggle addTarget:self action:@selector(toggleFeature) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.featureToggle];
    [self.contentView addSubview:self.featureLabel];
    return self;
}

-(void) toggleFeature {
    if([self.featureToggle.imageView.image isEqual:[UIImage imageNamed:@"off.png"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"DF1CfgMagnitudeValues"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"DF1CfgMagnitudeValues"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.featureToggle setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    CGRect fr;
    
    fr = CGRectMake(boundsX + 70, 8, width-50, 25);
    self.featureLabel.frame = fr;
    fr = CGRectMake(boundsX + 5, -5, 50, 50);
    self.featureToggle.frame = fr;
}
@end



@implementation DF1CfgCellProx
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    self.cfg = ucfg;
    self.height = 30;
    return self;
}
-(void) layoutSubviews
{
    [super layoutSubviews];
}
@end



@implementation DF1CfgCellOADTrigger
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
            withCfg:(NSMutableDictionary*) ucfg
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier withCfg:ucfg];
    if(self==nil)
        return self;
    self.cfg = ucfg;
    self.height = 50;
    
    self.oadLabel = [[UILabel alloc] init];
    self.oadLabel.font = [UIFont boldSystemFontOfSize:16];
    self.oadLabel.textAlignment = NSTextAlignmentLeft;
    self.oadLabel.text = [[NSString alloc] initWithFormat:@"Firmware Selection"];
    
    self.oadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.oadButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 30.0f);
    self.oadButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.oadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.oadButton setTitle:@"change" forState:UIControlStateNormal];
    self.oadButton.tintColor = [UIColor DFRed];
    [self.oadButton setTitle:@"danger!" forState:UIControlStateHighlighted];
    self.oadButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.oadButton sizeToFit];
    self.oadButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.oadButton addTarget:self action:@selector(doPopUp:)
             forControlEvents:UIControlEventTouchDown];

    
    [self.contentView addSubview:self.oadLabel];
    [self.contentView addSubview:self.oadButton];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.oadLabel.frame  = CGRectMake(PAD_LEFT,     PAD_TOP, 300, 45);
    self.oadButton.frame = CGRectMake(PAD_LEFT+50, PAD_TOP, 200, 45);
}

-(void) doPopUp:(id) sender
{
    NSString *msg = @"You will force your DF1 to boot into Over-Air-Update (OAD) mode. This operation cannot be undone!";
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"WARNING!"
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles: nil];
    [alert addButtonWithTitle:@"Do it!"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if (buttonIndex == 0)
    {
        NSLog(@"You have clicked Cancel");
        return;
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"Livin' dangerously!");

        if(self.delegate != nil) {
            [self.delegate triggerOAD];
        }

    }
}

-(void)sendOADBootCmd {

}

-(void)modifyChange:(NSMutableDictionary *)c {
    
}

@end
