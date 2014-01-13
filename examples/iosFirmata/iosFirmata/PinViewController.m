//
//  PinViewController.m
//  iosFirmata
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
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
@synthesize modeSwitch;
@synthesize statusSwitch;
@synthesize reportSwitch;
@synthesize pinsArray;
@synthesize pinNumber;
@synthesize analogMapping;
@synthesize ignoreReporting;
@synthesize ignoreTimer;

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
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    pinDictionary = [pinsArray objectAtIndex:pinNumber];
    
    [currentFirmata setController:self];

    NSString *text = [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"]stringValue];
    
    NSNumber *currentModeNumber =  [pinDictionary objectForKey:@"currentMode"];
    PINMODE currentMode = [currentModeNumber intValue];

    if(currentMode == INPUT){
        [modeSwitch setOn:YES];
        [statusSwitch setOn:[(NSNumber*)[pinDictionary valueForKey:@"lastvalue"]boolValue]];
    }
    else if(currentMode == OUTPUT){
        [modeSwitch setOn:NO];
        [statusSwitch setOn:[(NSNumber*)[pinDictionary valueForKey:@"lastvalue"]boolValue]];
    }
    else if(currentMode == PWM){
        [pinSlider setMaximumValue:127];
    }
    else if( currentMode == SERVO)
    {
        [pinSlider setMaximumValue:127];
    }
    else if (currentMode == I2C){
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(textFieldShouldReturn:)];
        
        [self.view addGestureRecognizer:tap];

    }
    
    [pinLabel setText:text];
    
    deviceLabel.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];
    
    [currentFirmata pinStateQuery:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue] selector:@selector(alertError:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}


#pragma mark -
#pragma mark Firmata Delegates
/****************************************************************************/
/*                              Firmata Delegates                           */
/****************************************************************************/
- (void) didReceiveStringData:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"String Data Recieved" message:string delegate:nil
                          cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    
}

- (void) didReceiveAnalogPin:(int)pin value:(unsigned short)value
{
    int translatedPin = [(NSNumber*)[analogMapping objectForKey:[NSNumber numberWithInt:pin]] intValue];

    if( translatedPin == [[pinDictionary valueForKey:@"firmatapin"] intValue] && !ignoreReporting)
    {
        NSLog(@"Analog update pin: %i, value:%i", pin, value);
        [pinStatus setText:[[NSString alloc] initWithFormat:@"%i",value] ];
        [reportSwitch setOn:YES]; //were getting status from it, must be on?
    }
}

- (void) didReceiveDigitalPin:(int)pin status:(BOOL)status
{
    if(pin == [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue] && ignoreReporting)
    {
        [pinDictionary setObject:[NSNumber numberWithInt:status] forKey:@"lastvalue"];

        NSLog(@"Digital Update pin: %d, value:%hhd", pin, status);
        [pinStatus setText:[[NSNumber numberWithBool:status] stringValue]];
        [statusSwitch setOn:status];
        [reportSwitch setOn:YES]; //were getting status from it, must be on?

    }
}

- (void) didDisconnect
{
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(void) didUpdatePin:(int)pin currentMode:(PINMODE)mode value:(unsigned short)value
{
    if(pin ==  [(NSNumber *)[pinDictionary objectForKey:@"firmatapin"] intValue]){

        [pinDictionary setObject:[NSNumber numberWithInt:value] forKey:@"lastvalue"];
        [pinDictionary setValue:[NSNumber numberWithInt:mode] forKey:@"currentMode"];
        if(mode == PWM || mode == SERVO){
            [pinSlider setValue:value];
        }else if(mode == INPUT){
            [modeSwitch setOn:YES];
            [statusSwitch setOn:[(NSNumber*)[pinDictionary valueForKey:@"lastvalue"]boolValue]];
        }
        else if(mode == OUTPUT){
            [modeSwitch setOn:NO];
            [statusSwitch setOn:[(NSNumber*)[pinDictionary valueForKey:@"lastvalue"]boolValue]];
        }
        
        [pinStatus setText:[[NSString alloc] initWithFormat:@"%i",value] ];

    }
}


#pragma mark -
#pragma mark UI Text Field Delegates
/****************************************************************************/
/*                        UI Text Field Methods                             */
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
    PINMODE modeToSend;
    
    if([sender isOn])
    {
        modeToSend = INPUT;
        NSLog(@"Setting Input");
    }else
    {
        modeToSend = OUTPUT;
        NSLog(@"Setting Output");
    }
    
    //wasteful but when it completes, lets call and get true status
    [currentFirmata setPinMode:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]
                          mode:modeToSend selector:@selector(refresh:)];

}

-(IBAction)toggleValue:(id)sender
{
    
    int port = [currentFirmata portForPin:
                [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]];
    
    int mask = 0;
    //build a mask from first pin of this port, to last pin of this port
    for(int x = port * 8; x< port * 8 +7; x++){
        
        //might run out of pins at some point, so just sub zeros
        int shiftedpin = 0;
        
        if( x < [pinsArray count] ){
            int value = [(NSNumber*)[[pinsArray objectAtIndex:x] valueForKey:@"lastvalue"] intValue] ;
            shiftedpin = value << (x % 8);
        }
        
        mask = mask + shiftedpin;
        
    }
    
    if([sender isOn])
    {
        NSLog(@"Enabling Pin on port");
        
        //set our pins bit on
        mask |= ( 1<< (pinNumber % 8) );

    }else
    {
        NSLog(@"Disabling Pins on port");

        //set our pins bit off
        mask &= ~( 1<< (pinNumber % 8) );
    }
    
    //wasteful but when it completes, lets call and get true status
    [currentFirmata digitalMessagePort:port mask:mask selector:@selector(refresh:)];
}

-(IBAction)toggleReporting:(id)sender
{
    
    NSNumber *currentModeNumber =  [pinDictionary objectForKey:@"currentMode"];
    PINMODE currentMode = [currentModeNumber intValue];
    
    if([sender isOn])
    {
        if(currentMode == ANALOG)
        {
            NSLog(@"Enabling analog pin reporting");
            
            NSArray *pins = [analogMapping allKeysForObject:[NSNumber numberWithInt: [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]];
            
            [currentFirmata samplingInterval:1000 selector:@selector(alertError:)]; //bluetooth really can't support more
            [currentFirmata reportAnalog:[(NSNumber*)[pins lastObject] intValue]
                                  enable:YES selector:@selector(alertError:)];
        }else{
            
            NSLog(@"Enabling digital reporting for port");
            [currentFirmata reportDigital:[currentFirmata portForPin:
                                           [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                                   enable:YES selector:@selector(alertError:)];
        }
        
    }else
    {
        if(currentMode == ANALOG)
        {
            NSLog(@"Disabling analog reporting");
            
            NSArray *pins = [analogMapping allKeysForObject:[NSNumber numberWithInt: [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]];

            [currentFirmata reportAnalog:[(NSNumber*)[pins lastObject] intValue]
                                   enable:NO selector:@selector(alertError:)];
            //ignore the next second or so of calls
            ignoreReporting = YES;
            ignoreTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(disableIgnore)
                                                         userInfo:nil
                                                          repeats:NO];
            
            
        }else
        {
            NSLog(@"Disabling digital reporting for port");
            [currentFirmata reportDigital:[currentFirmata portForPin:
                                           [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                                   enable:NO selector:@selector(alertError:)];
        }

    }
}

-(void)disableIgnore{
    ignoreReporting = NO;
}


-(IBAction)slider:(id)sender{
    
    NSLog(@"%f", pinSlider.value);
    [pinStatus setText:[[NSString alloc] initWithFormat:@"%d",(int)pinSlider.value] ];

    //wasteful but when it completes, lets call and get true status
    [currentFirmata analogMessagePin:[[pinDictionary valueForKey:@"firmatapin"] intValue] value:pinSlider.value selector:@selector(refresh:)];

}

-(IBAction)sendi2c:(id)sender
{
    NSString *input;

    if([[i2cPayloadTextField text] length] > 0 && [[i2cAddressTextField text] length] > 0 ){
        
        //pad to even if need be
        if([[i2cPayloadTextField text] length] % 2 !=0 )
        {
            input = [[NSString alloc] initWithFormat:@"0%@", [i2cPayloadTextField text]];
        }
        else
        {
            input = [[NSString alloc] initWithString:[i2cPayloadTextField text]];
        }

        const char *chars = [input UTF8String];
        int i = 0, len = input.length;
        
        NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
        char byteChars[3] = {'\0','\0','\0'};
        unsigned long wholeByte;
        
        while (i < len) {
            byteChars[0] = chars[i++];
            byteChars[1] = chars[i++];
            wholeByte = strtoul(byteChars, NULL, 16);
            [data appendBytes:&wholeByte length:1];
        }
        NSLog(@"%@", data);
        [currentFirmata i2cRequest:WRITE address:[[i2cAddressTextField text] intValue ] data:data selector:@selector(alertError:)];
    }
}

-(IBAction)refresh:(id)sender
{
    [currentFirmata pinStateQuery:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue] selector:@selector(alertError:)];
}

-(void) alertError:(NSError*)error{
    if(error){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Send Failed" message:@"Send to device failed. Try again or reset the device" delegate:nil
                              cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        
    }
    
}

@end