//
//  DetailViewController.h
//  TemperatureSensor
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeDataService.h"
#import "Firmata.h"

@interface DetailViewController : UITableViewController  <FirmataProtocol>

@property (strong, nonatomic) LeDataService             *currentlyDisplayingService;
@property (strong, nonatomic) Firmata                   *currentFirmata;
@property (strong, nonatomic) IBOutlet UILabel          *currentlyConnectedSensor;
@property (retain, nonatomic) NSMutableArray            *pins;
@property (retain, nonatomic) IBOutlet UITableView      *pinsTable;

@end