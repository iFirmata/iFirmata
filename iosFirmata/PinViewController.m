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
@synthesize currentFirmata;
@synthesize pinLabel;
@synthesize pinDictionary;
@synthesize status;

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
    
    [currentFirmata setController:self];

    [pinLabel setText:[pinDictionary valueForKey:@"name"]];
    currentlyConnectedSensor.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];
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
- (void) didReceiveAnalogPin:(int)pin value:(unsigned short)value
{
    
    //check if this is our pin
    NSLog(@"pin: %i, value:%i", pin, value);
    [status setText:[[NSString alloc] initWithFormat:@"%i",value] ];
}

- (void) didReceiveDigitalPin:(int)pin value:(unsigned short)value
{
    //check if this is our pin
    NSLog(@"pin: %i, value:%i", pin, value);
    [status setText:[[NSString alloc] initWithFormat:@"%i",value] ];

}

- (void) didConnect
{
    
}

- (void) didDisconnect
{
    [[self navigationController] popToRootViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
-(IBAction)toggleMode:(id)sender
{
    
}

-(IBAction)toggleValue:(id)sender
{

}

-(IBAction)toggleReporting:(id)sender
{
    if([sender isOn])
    {
        NSLog(@"Enabling");
        [currentFirmata reportAnalog:1 enable:YES];
        [status setEnabled:YES];
    }else
    {
        NSLog(@"Disabling");
        [currentFirmata reportAnalog:1 enable:NO];
        [status setEnabled:NO];
    }
}

@end
