//
//  DetailViewController.m
//  TemperatureSensor
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "PinViewController.h"
#import "LeDataService.h"
#import "FirmataCell.h"

@implementation DetailViewController

@synthesize currentlyConnectedSensor;
@synthesize firmwareVersion;
@synthesize currentFirmata;
@synthesize pinsArray;
@synthesize pinsTable;
@synthesize analogMapping;
@synthesize tableUpdate;
@synthesize stringToSend;

UITapGestureRecognizer *_tap;

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
        NSLog(@"Initting here");

    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    currentlyConnectedSensor.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];

    [self reset:nil]; //currentFirmata firmata so must come before any firmata calls in setup

    if(!pinsArray){
        pinsArray = [[NSMutableArray alloc] init];
        [currentFirmata analogMappingQuery];
    }
    
    _tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
            action:@selector(textFieldShouldReturn:)];

}

- (void) viewDidUnload
{
    [tableUpdate invalidate];
    tableUpdate = nil;
    _tap = nil;

    [self setPinsArray:nil];
    [self setCurrentlyConnectedSensor:nil];
    [self setPinsTable:nil];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([sender isKindOfClass:[UIBarButtonItem class]]){

    }else{
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSLog(@"%ld", (long)indexPath.row);
        NSLog(@"%@", [pinsArray objectAtIndex:indexPath.row] );
        
        PinViewController *dest =[segue destinationViewController];
        dest.currentFirmata = currentFirmata;
        dest.pinDictionary = [pinsArray objectAtIndex:indexPath.row];
        
        [tableUpdate invalidate];
    }
    
}

- (void)refreshTable:(NSTimer*)theTimer
{
    if(_REFRESH)
    {
        [self.tableView reloadData];
        _REFRESH = NO;
    }
    
}

-(IBAction)reset:(UIStoryboardSegue *)segue {

    [currentFirmata setController:self];

    tableUpdate = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(refreshTable:)
                                                 userInfo:nil
                                                  repeats:YES];
    _REFRESH = YES;

}


#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/

//
//  pins        - array of pin dictionaries
//  pin         - a dictionary for a pin
//  name        - colloquial name of the pin (D1, D2, A1, et)
//  lastvalue   - last fetched value for that pin, IE a return from reportAnalog or digital
//  modes       - an nsdictionary keyed off of pinmode enum integers converted to strings
//                  which bring up the resoultion for each pin
//
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Pin at row %i: %@", indexPath.row, [pinsArray objectAtIndex:indexPath.row]);
    
    NSDictionary *pin = [pinsArray objectAtIndex:indexPath.row];

    NSNumber *currentModeNumber =  [pin objectForKey:@"currentMode"];
    PINMODE currentMode = [currentModeNumber intValue];
    
    NSString *currentModeString = [currentFirmata pinmodeEnumToString:[currentModeNumber intValue]];

    NSString *cellIdentifier = [NSString stringWithFormat:@"PinList %i",indexPath.row];
    FirmataCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        
        cell = [[FirmataCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //set value detail text
        if([pin objectForKey:@"lastvalue"]){
            [[cell detailTextLabel] setText:[(NSNumber*)[pin objectForKey:@"lastvalue"] stringValue]];
        }else{
            [[cell detailTextLabel] setText:@""];
        }
        
        //set name
        [[cell textLabel] setText:[pin valueForKey:@"name"]];
        
        //set mode button
        UIButton *modeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [modeButton setTitle:@"unknown" forState:UIControlStateNormal];
        [modeButton addTarget:self action:@selector(selectMode:) forControlEvents:UIControlEventTouchDown];
        [modeButton setFrame:CGRectMake(50,10,75,30)];
        [modeButton setTag:indexPath.row];
        [cell setButton:modeButton];

    }

    //set value detail text
    if([pin objectForKey:@"lastvalue"]){
        [[cell detailTextLabel] setText:[(NSNumber*)[pin objectForKey:@"lastvalue"] stringValue]];
    }else{
        [[cell detailTextLabel] setText:@""];
    }
    
    //in mode changed, change the button text
    if(currentModeNumber){
        [cell setButtonTitle:currentModeString];
    }
    
    //no accessory if analog or unknown
    if(currentModeNumber>0 && currentMode!=ANALOG )
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pinsArray count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check what curent mode is set to and send to appropriate view

    NSDictionary *pin = [pinsArray objectAtIndex:indexPath.row];

    NSNumber *currentModeNumber =  [pin objectForKey:@"currentMode"];
    
    PINMODE mode = [currentModeNumber intValue];

    //#define pinmodeArray @"input", @"output", @"analog", @"pwm", @"servo", @"shift", @"i2c", nil

    switch (mode) {
        case INPUT:
        case OUTPUT:
            [self performSegueWithIdentifier: @"digitalPinView" sender:self];
            break;
            
        case SERVO:
        case PWM:
            [self performSegueWithIdentifier: @"analogPinView" sender:self];
            break;
            
        case I2C:
            [self performSegueWithIdentifier: @"i2cPinView" sender:self];
            break;
            
        case SHIFT:
            [self performSegueWithIdentifier: @"shiftPinView" sender:self];
            break;

        default:
            break;
    }
    
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

- (void) didUpdatePin:(int)pin currentMode:(PINMODE)mode value:(unsigned short)value
{
    NSLog(@"Did update pin: %d mode:%u value:%hu", pin, mode, value);
     NSMutableDictionary *pinObject =[pinsArray objectAtIndex:pin];
    [pinObject setValue:[NSNumber numberWithInt:value] forKey:@"lastvalue"];
    [pinObject setValue:[NSNumber numberWithInt:mode] forKey:@"currentMode"];
    _REFRESH = YES;
}

- (void) didReportFirmware:(NSString*)name major:(unsigned short int)major minor:(unsigned short int)minor
{
    firmwareVersion.text = [NSString stringWithFormat:@"%@ %ld.%ld",
                            name, (long)major, (long)minor];
}

- (void) didReportVersionMajor:(unsigned short)major minor:(unsigned short)minor
{
    NSLog(@"%hu, %hu", major, minor);
}

//returns NSDictionary set of analog int 0.. NSnumber keys for
- (void) didUpdateAnalogMapping:(NSMutableDictionary *)analogMapping
{
    self.analogMapping = analogMapping;

    [currentFirmata capabilityQuery];
}

//returns an NSMutablearray of NSDictionary of modes
- (void) didUpdateCapability:(NSMutableArray*)incomingPins
{
    int totalPins = [incomingPins count];
    int totalAnalog = [analogMapping count];
    int totalDigital = totalPins-totalAnalog;
    
    int k = 0;
    for (int i = 0; i < [incomingPins count]; i++)
    {
        NSDictionary *modes = incomingPins[i];
        NSLog(@"for pin %i: %@", i, modes);
        
        NSMutableDictionary *pin = [[NSMutableDictionary alloc] init];

        if(i<totalDigital){
            [pin setValue:[NSString stringWithFormat:@"D%i", i] forKey:@"name"];
        }else{
            [pin setValue:[NSString stringWithFormat:@"A%i", k++] forKey:@"name"];
        }

        [pin setValue:modes forKey:@"modes"];
        
        [pin setValue:[NSNumber numberWithInt:i] forKey:@"firmatapin"];
        
        [pinsArray addObject:pin];
    }

    NSLog(@"Local Pins declaration %@",pinsArray);
    _REFRESH = YES;
}

- (void) didReceiveAnalogPin:(int)pin value:(unsigned short)value
{
    NSLog(@"pin: %i, value:%i", pin, value);
    if(pinsArray && [pinsArray count]>0 && pin<[pinsArray count] && analogMapping && [analogMapping count]>0){

        int translatedPin = [(NSNumber*)[analogMapping objectForKey:[NSNumber numberWithInt:pin]] intValue];
        NSDictionary *aPin = pinsArray[translatedPin];
        [aPin setValue:[NSNumber numberWithInt:value] forKey:@"lastvalue"];
        _REFRESH = YES;
    }
}

- (void) didReceiveDigitalPort:(int)port mask:(unsigned short)mask
{
    NSLog(@"port: %i, mask:%i", port, mask);
    
}

- (void) didReceiveDigitalPin:(int)pin status:(BOOL)status
{
    NSLog(@"Digital Update pin: %d, value:%hhd", pin, status);
    if(pinsArray && [pinsArray count]>0 && pin<[pinsArray count] ){
        NSDictionary *aPin = pinsArray[pin];
        [aPin setValue:[NSNumber numberWithInt:status] forKey:@"lastvalue"];
        _REFRESH = YES;
    }

}

- (void) didConnect
{
    NSLog(@"Connected?");
}

- (void) didDisconnect
{
    [[self navigationController] popToRootViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark ActionSheet Delegates
/****************************************************************************/
/*                          ActionSheet Delegates                           */
/****************************************************************************/
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex){
        NSLog(@"actionsheet index: %@", [actionSheet buttonTitleAtIndex:buttonIndex] );

        NSMutableDictionary *pin =[pinsArray objectAtIndex:actionSheet.tag];

        PINMODE newMode = [currentFirmata modeStringToEnum: [actionSheet buttonTitleAtIndex:buttonIndex]];
        NSLog(@"new mode: %u", newMode );

        NSNumber *currentModeNumber =  [pin objectForKey:@"currentMode"];
        NSLog(@"current mode: %d", [currentModeNumber intValue] );
        PINMODE currentMode = [currentModeNumber intValue];

        //if old mode was analog, make sure to turn off reporting
        if(currentMode != newMode && newMode == ANALOG) {
            [currentFirmata reportAnalog:actionSheet.tag enable:NO];
        }

        [pin setValue:[NSNumber numberWithInt:newMode] forKey:@"currentMode"];

        [currentFirmata setPinMode:actionSheet.tag mode:newMode];

        if(newMode == ANALOG){

            [currentFirmata reportAnalog:actionSheet.tag enable:YES];
            [currentFirmata samplingInterval:1000]; //bluetooth really can't support more

            
        }else if (newMode == I2C){
            
            [currentFirmata i2cConfig:0 data:[[NSData alloc]init]];
            
            //issue first call never works?
            //https://github.com/firmata/arduino/issues/101
            [currentFirmata i2cRequest:WRITE address:0 data:nil];

        }
        
        [pin removeObjectForKey:@"lastvalue"];
        _REFRESH = YES;
    }

}

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld", (long)buttonIndex);
    //could do something here
}


#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              UI Text Field Methods                       */
/****************************************************************************/

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [stringToSend resignFirstResponder];
    return YES;
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view addGestureRecognizer:_tap];
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
-(IBAction)refresh:(id)sender
{
    //blocking delay because some devices can't handle spammed commands
    //since blocking, lets put it in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        for(int i=0; i<[pinsArray count]; i++)
        {
            [currentFirmata pinStateQuery:i];
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow: 0.4 ]];
        }
        
    });
}

-(void)selectMode:(UIButton*)sender{
    
    UIActionSheet *actionsheet = [[UIActionSheet alloc] init ];
    
    [actionsheet setTitle:@"Choose Mode"];
    [actionsheet setDelegate:self];
    
    [actionsheet addButtonWithTitle:@"Cancel"];
    [actionsheet setCancelButtonIndex:0];

    NSDictionary *pin = [pinsArray objectAtIndex:sender.tag];
    NSMutableDictionary *modesDictionary = [pin objectForKey:@"modes"];

    if(modesDictionary && [modesDictionary count] > 0){
        
        for (NSNumber* modeNumber in modesDictionary) {
            NSString *modeString =[currentFirmata pinmodeEnumToString:(PINMODE)[modeNumber intValue]];
            
            
            [actionsheet addButtonWithTitle:modeString ];

        }
    }

    actionsheet.tag=sender.tag;
    [actionsheet showInView:self.view];
}

-(IBAction)sendString:(id)sender
{
    UITextField *input = (UITextField*)sender;
    [sender resignFirstResponder];
    NSLog(@"Sending ascii: %@", [input text]);

    [currentFirmata stringData:[input text]];
}


@end
