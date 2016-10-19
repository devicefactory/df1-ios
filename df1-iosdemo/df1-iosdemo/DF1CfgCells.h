#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"
#import "UIColor+DF1Colors.h"

@interface DF1CfgCell : UITableViewCell <DF1Delegate>

@property (strong,nonatomic) NSMutableDictionary *cfg;
@property (strong,nonatomic) DF1 *df;
@property int height;
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
      withCfg:(NSMutableDictionary*) ucfg;

@end

//
// Cell for changing device name
//
@interface DF1CfgCellName : DF1CfgCell <UITextFieldDelegate>
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UITextField *nameField;
-(void) modifyChange:(NSMutableDictionary*) c;
-(IBAction) handleTextFieldEdit:(UITextField*) sender;
@end


//
// Cell for configuring G range
//
@interface DF1CfgCellRange : DF1CfgCell
@property (nonatomic,retain) UILabel *accRangeLabel;
@property (nonatomic,retain) UISegmentedControl *control;
-(void) modifyChange:(NSMutableDictionary*) c;
-(IBAction) accSliderChanged:(UISlider*)sender;
@end

@interface DF1CfgCellRes : DF1CfgCell
@property (nonatomic,retain) UILabel *accResLabel;
@property (nonatomic,retain) UISegmentedControl *control;
-(void) modifyChange:(NSMutableDictionary*) c;
@end

@interface DF1CfgCellFreqRange : DF1CfgCell
@property (nonatomic,retain) UILabel *accRangeLabel;
@property (nonatomic,retain) UISlider *accRangeSlider;
-(void) modifyChange:(NSMutableDictionary*) c;
-(IBAction) accSliderChanged:(UISlider*)sender;
@end

@interface DF1CfgCellAuto : DF1CfgCell
-(void) modifyChange:(NSMutableDictionary*) c;
@end


@interface DF1CfgXYZPlotter : DF1CfgCell
-(void) modifyChange:(NSMutableDictionary*) c;
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgTap : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;

@property (nonatomic,retain) UILabel *accLabel;
@property (nonatomic,retain) UILabel *accValueTap;
@property (nonatomic,retain) UILabel *accThsLabel;
@property (nonatomic,retain) UISlider *accThsSlider;
@property (nonatomic,retain) UILabel *accTmltLabel;
@property (nonatomic,retain) UISlider *accTmltSlider;
-(IBAction) accThsChanged:(UISlider*)sender;
-(IBAction) accTmltChanged:(UISlider*)sender;
@end

@interface DF1CfgFlip : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgCSVDataRecorder : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgBatteryLevel : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgMagnitudeValues : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgFreefall : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgTop10: DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@interface DF1CfgCellProx : DF1CfgCell
-(void) modifyChange:(NSMutableDictionary*) c;
@end

@interface DF1CfgDistance : DF1CfgCell
@property (nonatomic,retain) UILabel *featureLabel;
@property (nonatomic,retain) UIButton *featureToggle;
@end

@protocol DF1CfgCellOADTriggerDelegate
@optional
-(void) triggerOAD;
@end

@interface DF1CfgCellOADTrigger : DF1CfgCell<UIAlertViewDelegate>
-(void) modifyChange:(NSMutableDictionary*) c;
@property (nonatomic,assign) id<DF1CfgCellOADTriggerDelegate> delegate;
@property (nonatomic,retain) UILabel *oadLabel;
@property (nonatomic,retain) UIButton *oadButton;
-(void) sendOADBootCmd;
@end
