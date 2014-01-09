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
@synthesize modeSwitch;
@synthesize statusSwitch;
@synthesize reportSwitch;
@synthesize scrollView;
@synthesize activeField;
@synthesize pinsArray;
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
        [pinSlider setMaximumValue:255];
    }
    else if( currentMode == SERVO)
    {
        [pinSlider setMaximumValue:180];
    }
    else if (currentMode == I2C){
        
        [self registerForKeyboardNotifications];
        
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
    
    deviceLabel.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];
    
    [currentFirmata pinStateQuery:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]];

    //fix for uiscrollview
    //http://stackoverflow.com/questions/8528134/uiscrollview-not-scrolling-when-keyboard-covers-active-uitextfield-using-apple
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect navigationFrame = [[self.navigationController navigationBar] frame];
    CGFloat height = applicationFrame.size.height - navigationFrame.size.height;
    CGSize newContentSize = CGSizeMake(applicationFrame.size.width, height);
    
    scrollView.contentSize = newContentSize;
    //end
    
}

- (void) viewDidUnload
{
    [self setCurrentFirmata:nil];
    [self setPinDictionary:nil];
    [self setDeviceLabel:nil];
    [self setPinLabel:nil];
    [self setPinStatus:nil];
    [self setPinSlider:nil];
    [self setI2cAddressTextField:nil];
    [self setI2cPayloadTextField:nil];
    [self setI2cResultTextView:nil];
    [self setModeSwitch:nil];
    [self setStatusSwitch:nil];
    [self setReportSwitch:nil];
    [self setScrollView:nil];

    [super viewDidUnload];

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
- (void) didReceiveStringData:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"String Data Recieved" message:string delegate:nil
                          cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    
}

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
        [pinDictionary setObject:[NSNumber numberWithInt:status] forKey:@"lastvalue"];

        NSLog(@"Digital Update pin: %d, value:%hhd", pin, status);
        [pinStatus setText:[[NSNumber numberWithBool:status] stringValue]];
        [statusSwitch setOn:status];
        [reportSwitch setOn:YES]; //were getting status from it, must be on?

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
/*                        UI Text Field Methods                             */
/****************************************************************************/
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [i2cAddressTextField resignFirstResponder];
    [i2cPayloadTextField resignFirstResponder];
    return YES;
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(textFieldShouldReturn:)];
    [self.view addGestureRecognizer:tap];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
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
         mode:INPUT];
        [self refresh:nil]; //wasteful but lets call and get true status
    }else
    {
        NSLog(@"Setting Output");
        [currentFirmata setPinMode:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]
                              mode:OUTPUT];
        [self refresh:nil]; //wasteful but lets call and get true status
    }
}

-(IBAction)toggleValue:(id)sender
{
    
    int port = [currentFirmata portForPin:
                [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]];
    
    int mask = 0;
    //build a mask from first pin of this port, to last pin of this port
    for(int x = port * 8; x< port * 8 +7; x++){
        
        int value = [(NSNumber*)[[pinsArray objectAtIndex:x] valueForKey:@"lastvalue"] intValue] ;
        int shiftedpin = value << (x % 8);
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
    
    [currentFirmata digitalMessagePort:port mask:mask];
    
    [self refresh:nil]; //wasteful but lets call and get true status
}

-(IBAction)toggleReporting:(id)sender
{
    if([sender isOn])
    {
        [currentFirmata samplingInterval:1000]; //bluetooth really can't support more
        NSLog(@"Enabling digital reporting for port");
        [currentFirmata reportDigital:[currentFirmata portForPin:
                                            [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                                      enable:YES];
        //[pinStatus setEnabled:YES];
    }else
    {
        NSLog(@"Disabling Pins on port");
        [currentFirmata reportDigital:[currentFirmata portForPin:
                                       [(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]]
                               enable:NO];
        //[pinStatus setEnabled:NO];
    }
}

-(IBAction)slider:(id)sender{
    
    NSLog(@"%f", pinSlider.value);
    [pinStatus setText:[[NSString alloc] initWithFormat:@"%d",(int)pinSlider.value] ];
    [currentFirmata analogMessagePin:[[pinDictionary valueForKey:@"firmatapin"] intValue] value:pinSlider.value];

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
        [currentFirmata i2cRequest:WRITE address:[[i2cAddressTextField text] intValue ] data:data];
    }
}

-(IBAction)refresh:(id)sender
{
    [currentFirmata pinStateQuery:[(NSNumber*)[pinDictionary valueForKey:@"firmatapin"] intValue]];
}


@end