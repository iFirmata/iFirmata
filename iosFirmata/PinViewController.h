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
@property (strong, nonatomic) LeDataService             *currentlyDisplayingService;
@property (strong, nonatomic) Firmata                   *currentFirmata;
@property (strong, nonatomic) IBOutlet UILabel          *currentlyConnectedSensor;
@property (strong, nonatomic) IBOutlet UILabel          *status;
@property (strong, nonatomic) IBOutlet UILabel          *pinNumberLabel;

@property (strong, nonatomic) NSDictionary              *pinNumber;

-(IBAction)toggleOutput:(id)sender;
-(IBAction)toggleStatus:(id)sender;
@end
