//
//  PinViewController.m
//  iosFirmata
//
//  Created by Jacob on 11/12/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "PinViewController.h"
#import "DetailViewController.h"

@implementation PinViewController


@synthesize currentFirmata;
@synthesize pinDictionary;
@synthesize deviceLabel;
@synthesize pinLabel;
@synthesize pinStatus;
@synthesize pinSlider;
@synthesize i2cAddressTextField;
@synthesize i2cPayloadTextField;
@synthesize i2cResultTextView;

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

    NSNumber *currentModeNumber =  [pinDictionary objectForKey:@"currentMode"];
    PINMODE currentMode = [currentModeNumber intValue];

    if(currentMode == PWM){
        [pinSlider setMaximumValue:255];
    }
    else if( currentMode == SERVO)
    {
        [pinSlider setMaximumValue:180];
    }
    else if (currentMode == I2C){
        
        //create segmentedui -- fill with I2CMODE enums
        NSArray *itemArray = [NSArray arrayWithObjects: @"One", @"Two", @"Three", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        segmentedControl.frame = CGRectMake(20, 225, 280, 30);
        segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
        segmentedControl.selectedSegmentIndex = 1;
        [segmentedControl addTarget:nil
                              action:nil
                    forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:segmentedControl];
        [i2cPayloadTextField setDelegate:self];
        [i2cAddressTextField setDelegate:self];

    }
    
    [pinLabel setText:text];
    
    NSLog(@"setting device label text");

    deviceLabel.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];
    
    [currentFirmata pinStateQuery:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]];

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

-(void) didUpdatePin:(int)pin currentMode:(PINMODE)mode value:(unsigned short)value
{
    if(pin ==  [(NSNumber *)[pinDictionary objectForKey:@"firmatapin"] intValue]){
        NSNumber *currentModeNumber =  [pinDictionary objectForKey:@"currentMode"];
        PINMODE currentMode = [currentModeNumber intValue];
        
        if(currentMode == PWM || currentMode == SERVO){
            [pinSlider setValue:value];
        }
        
        [pinStatus setText:[[NSString alloc] initWithFormat:@"%i",value] ];
        [pinDictionary setObject:[NSNumber numberWithInt:value] forKey:@"lastvalue"];

    }
}

-(void) didReportVersionMajor:(unsigned short)major minor:(unsigned short)minor
{
    
}

-(void)didReportFirmware:(NSString *)name major:(unsigned short)major minor:(unsigned short)minor
{
    
}

-(void) didUpdateCapability:(NSMutableArray *)pins
{
    
}

-(void) didUpdateAnalogMapping:(NSMutableDictionary *)analogMapping
{
    
}


#pragma mark -
#pragma mark UI Text Field Delegates
/****************************************************************************/
/*                        UI Text Field Delegates                           */
/****************************************************************************/
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [i2cAddressTextField resignFirstResponder];
    [i2cPayloadTextField resignFirstResponder];
    return YES;
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

-(IBAction)slider:(id)sender{
    
    NSLog(@"%f", pinSlider.value);
    [pinStatus setText:[[NSString alloc] initWithFormat:@"%d",(int)pinSlider.value] ];
    [currentFirmata analogMessagePin:[[pinDictionary valueForKey:@"firmatapin"] intValue] value:pinSlider.value];

}

-(IBAction)sendi2c:(id)sender
{

//    const unsigned char led[] = {DISP_CHAR_5X7, 'n', time>>8, time & 0xff};
//    NSData *data = [[NSData alloc] initWithBytes:led length:sizeof(led)];

//    [currentFirmata i2cRequest:WRITE    address:[self bytesStringToData:[i2cAddressTextField text]]
//                                        data:   [self bytesStringToData:[i2cPayloadTextField text]]
//     ];
    
}

//+(NSData*)bytesStringToData:(NSString*)bytesString
//{
//    for(int i = [bytesString count] - 1; i > 0; i--){
//        
//        NSString *sub = substringWithRange:NSMakeRange(i, 2)];
//        NSLog(@"%@", sub);
//    }
//
//
//    NSScanner* pScanner = [NSScanner scannerWithString: pString];
//    
//    unsigned long long iValue2;
//    [pScanner scanHexLongLong: &iValue2];
//    
//    NSLog(@"iValue2 = %lld", iValue2);
//    
//}

-(IBAction)refresh:(id)sender
{
    [currentFirmata pinStateQuery:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]];
}

@end