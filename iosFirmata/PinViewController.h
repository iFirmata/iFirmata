//
//  PinViewController.h
//  iosFirmata
//
//  Created by Jacob on 11/12/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firmata.h"

@interface PinViewController : UIViewController <FirmataProtocol>
@property (strong, nonatomic) Firmata                   *currentFirmata;
@property (strong, nonatomic) IBOutlet UILabel          *deviceLabel;
@property (strong, nonatomic) IBOutlet UILabel          *pinStatus;
@property (strong, nonatomic) IBOutlet UILabel          *pinLabel;

@property (strong, nonatomic) NSMutableDictionary       *pinDictionary;

-(IBAction)toggleValue:(id)sender;
-(IBAction)toggleMode:(id)sender;
-(IBAction)toggleReporting:(id)sender;
@end
