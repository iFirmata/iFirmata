//
//  DetailViewController.h
//  iosFirmata
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import <UIKit/UIKit.h>
#import "LeDataService.h"
#import "Firmata.h"

@interface DetailViewController : UITableViewController  <FirmataProtocol, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentlyConnectedSensor;
@property (weak, nonatomic) IBOutlet UITableView *pinsTable;
@property (weak, nonatomic) IBOutlet UITextField *stringToSend;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersion;

@property (weak, nonatomic) Firmata *currentFirmata;
@property (strong, nonatomic) NSMutableArray *pinsArray;
@property (weak, nonatomic) NSMutableDictionary *analogMapping;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property int refreshCounter;

-(IBAction)refresh:(id)sender;
-(IBAction)sendString:(id)sender;
-(IBAction)textFieldDidBeginEditing:(UITextField *)textField;
-(IBAction)textFieldDidEndEditing:(UITextField *)textField;
@end