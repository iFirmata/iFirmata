//
//  PinViewController.m
//  iosFirmata
//
//  Created by Jacob on 11/12/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "PinViewController.h"


@implementation PinViewController

@synthesize currentlyConnectedSensor;
@synthesize currentlyDisplayingService;
@synthesize currentFirmata;
@synthesize pinNumberLabel;
@synthesize pinNumber;

#pragma mark -
#pragma mark View lifecycle
/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [pinNumberLabel setText:@"5"];
    [currentFirmata setController:self];
    currentlyConnectedSensor.text = [[currentlyDisplayingService peripheral] name];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Firmata Delegates
/****************************************************************************/
/*                              Firmata Delegates                           */
/****************************************************************************/
- (void) didUpdateDigitalPin{
    NSLog(@"something");
}

- (void) didReportFirmware:(NSData*)data{
    
    NSLog(@"%@", [[NSString alloc] initWithData:data
                                       encoding:NSUTF8StringEncoding]);
}


#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
-(IBAction)toggleOutput:(id)sender
{
    
    
}

-(IBAction)toggleStatus:(id)sender
{
    
    
}

@end
