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

@property IBOutlet UILabel          *deviceLabel;
@property IBOutlet UILabel          *pinStatus;
@property IBOutlet UILabel          *pinLabel;
@property IBOutlet UISlider         *pinSlider;
@property IBOutlet UISwitch         *modeSwitch;
@property IBOutlet UISwitch         *statusSwitch;
@property IBOutlet UISwitch         *reportSwitch;
@property IBOutlet UITextField      *i2cAddressTextField;
@property IBOutlet UITextField      *i2cPayloadTextField;
@property IBOutlet UITextView       *i2cResultTextView;

@property Firmata                   *currentFirmata;
@property NSMutableDictionary       *pinDictionary;
@property NSMutableArray            *pinsArray;
@property NSMutableDictionary       *analogMapping;
@property NSTimer                   *ignoreTimer;

@property bool                      ignoreReporting;
@property int                       pinNumber;

-(IBAction)sendi2c:(id)sender;
-(IBAction)toggleValue:(id)sender;
-(IBAction)toggleMode:(id)sender;
-(IBAction)toggleReporting:(id)sender;
-(IBAction)refresh:(id)sender;

@end
