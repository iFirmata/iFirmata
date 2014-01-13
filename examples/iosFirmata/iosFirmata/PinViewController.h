//
//  PinViewController.h
//  iosFirmata
//
//  Created by Jacob on 11/12/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firmata.h"

@interface PinViewController : UIViewController <FirmataProtocol, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinStatus;
@property (weak, nonatomic) IBOutlet UILabel *pinLabel;
@property (weak, nonatomic) IBOutlet UISlider *pinSlider;
@property (weak, nonatomic) IBOutlet UISwitch *modeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *reportSwitch;
@property (weak, nonatomic) IBOutlet UITextField *i2cAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *i2cPayloadTextField;
@property (weak, nonatomic) IBOutlet UITextView *i2cResultTextView;

@property (weak, nonatomic) Firmata *currentFirmata;
@property (weak, nonatomic) NSMutableDictionary *pinDictionary;
@property (weak, nonatomic) NSMutableArray *pinsArray;
@property (weak, nonatomic) NSMutableDictionary *analogMapping;
@property (weak, nonatomic) NSTimer *ignoreTimer;

@property bool ignoreReporting;
@property int pinNumber;

-(IBAction)sendi2c:(id)sender;
-(IBAction)toggleValue:(id)sender;
-(IBAction)toggleMode:(id)sender;
-(IBAction)toggleReporting:(id)sender;
-(IBAction)refresh:(id)sender;

@end
