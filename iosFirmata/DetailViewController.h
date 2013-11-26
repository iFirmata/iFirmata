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

@interface DetailViewController : UITableViewController  <FirmataProtocol, UIActionSheetDelegate>

@property (strong, nonatomic) Firmata                   *currentFirmata;
@property (strong, nonatomic) IBOutlet UILabel          *currentlyConnectedSensor;
@property (strong, nonatomic) IBOutlet UILabel          *firmwareVersion;
@property (retain, nonatomic) NSMutableArray            *pinsArray;
@property (retain, nonatomic) IBOutlet UITableView      *pinsTable;
@property (retain, nonatomic) NSMutableDictionary       *analogMapping;
@property (retain, nonatomic) NSTimer                   *tableUpdate;
@property BOOL                                          REFRESH;
-(IBAction)refresh:(id)sender;
-(IBAction)reset:(UIStoryboardSegue *)segue;

@end