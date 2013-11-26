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
@property (strong, nonatomic) IBOutlet UITextField      *i2cAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField      *i2cPayloadTextField;
@property (strong, nonatomic) IBOutlet UITextView       *i2cResultTextView;
@property (strong, nonatomic) NSMutableDictionary       *pinDictionary;

-(IBAction)sendi2c:(id)sender;
-(IBAction)toggleValue:(id)sender;
-(IBAction)toggleMode:(id)sender;
-(IBAction)toggleReporting:(id)sender;
-(IBAction)refresh:(id)sender;
@end
