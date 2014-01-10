//
//  PinViewController.h
//  iosFirmata
//
//  Created by Jacob on 11/12/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firmata.h"

@interface PinViewController : UIViewController <FirmataProtocol, UITextFieldDelegate>
@property (strong, nonatomic) Firmata                   *currentFirmata;
@property (strong, nonatomic) IBOutlet UILabel          *deviceLabel;
@property (strong, nonatomic) IBOutlet UILabel          *pinStatus;
@property (strong, nonatomic) IBOutlet UILabel          *pinLabel;
@property (strong, nonatomic) IBOutlet UISlider         *pinSlider;
@property (strong, nonatomic) IBOutlet UISwitch         *modeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch         *statusSwitch;
@property (strong, nonatomic) IBOutlet UISwitch         *reportSwitch;
@property (strong, nonatomic) IBOutlet UITextField      *i2cAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField      *i2cPayloadTextField;
@property (strong, nonatomic) IBOutlet UITextView       *i2cResultTextView;
@property (strong, nonatomic) NSMutableDictionary       *pinDictionary;
@property (strong, nonatomic) IBOutlet UIScrollView     *scrollView;
@property (strong, nonatomic) UITextField               *activeField;
@property (strong, nonatomic) NSMutableArray            *pinsArray;
@property (retain, nonatomic) NSMutableDictionary       *analogMapping;
@property (retain, nonatomic) NSTimer                   *ignoreTimer;
@property                     bool                      ignoreReporting;
@property                     int                       pinNumber;

-(IBAction)sendi2c:(id)sender;
-(IBAction)toggleValue:(id)sender;
-(IBAction)toggleMode:(id)sender;
-(IBAction)toggleReporting:(id)sender;
-(IBAction)refresh:(id)sender;
-(IBAction)textFieldDidBeginEditing:(UITextField *)textField;
-(IBAction)textFieldDidEndEditing:(UITextField *)textField;
@end
