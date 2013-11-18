//
//  PinViewController.m
//  iosFirmata
//
//  Created by Jacob on 11/12/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "PinViewController.h"


@implementation PinViewController


@synthesize currentFirmata;
@synthesize pinDictionary;
@synthesize deviceLabel;
@synthesize pinLabel;
@synthesize pinStatus;

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
    
    NSLog(@"Setting controller");
    
    [currentFirmata setController:self];

    NSLog(@"getting pinlable text");

    NSString *text = [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"]stringValue];
    
    NSLog(@"%@", text);
    NSLog(@"setting pinlable text");

    
    [pinLabel setText:text];
    
    NSLog(@"setting device label text");

    deviceLabel.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];
    NSLog(@"View done loading");
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
    if(pin == [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue])
    {
        NSLog(@"Analog update pin: %i, value:%i", pin, value);
        [pinStatus setText:[[NSString alloc] initWithFormat:@"%i",value] ];
    }
}


- (void) didReceiveDigitalPort:(int)port mask:(unsigned short)mask
{
}

- (void) didReceiveDigitalPin:(int)pin status:(BOOL)status
{
    if(pin == [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue])
    {
        NSLog(@"Digital Update pin: %d, value:%hhd", pin, status);
        [pinStatus setText:[[NSString alloc] initWithFormat:@"%i",status] ];
    }
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
    if([sender isOn])
    {
        NSLog(@"Setting Input");
        [currentFirmata setPinMode:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]
         mode:1];

    }else
    {
        NSLog(@"Setting Output");
        [currentFirmata setPinMode:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]
                              mode:1];
    }
}

-(IBAction)toggleValue:(id)sender
{
    if([sender isOn])
    {
        NSLog(@"Enabling Pin on port");
        [currentFirmata digitalMessagePort:[currentFirmata portForPin:
                                            [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                                      mask:[currentFirmata bitMaskForPin:
                                            [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]
                                            ]];
    }else
    {
        NSLog(@"Disabling Pins on port");
        [currentFirmata digitalMessagePort:[currentFirmata portForPin:
                                            [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                                      mask:0x00];
    }
}

-(IBAction)toggleReporting:(id)sender
{
    if([sender isOn])
    {
        NSLog(@"Enabling digital reporting for port");
        [currentFirmata reportDigital:[currentFirmata portForPin:
                                            [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                                      enable:YES];
        [pinStatus setEnabled:YES];
    }else
    {
        NSLog(@"Disabling Pins on port");
        [currentFirmata reportDigital:[currentFirmata portForPin:
                                       [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                               enable:NO];
        [pinStatus setEnabled:NO];
    }
}
@end
