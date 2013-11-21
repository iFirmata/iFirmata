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

@implementation DetailViewController

@synthesize currentlyConnectedSensor;
@synthesize firmwareVersion;
@synthesize currentFirmata;
@synthesize pinsArray;
@synthesize pinsTable;
@synthesize analogMapping;

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
    
    if(!pinsArray){
        pinsArray = [[NSMutableArray alloc] init];
        
        [currentFirmata reset];
        
        [currentFirmata analogMappingQuery];
        
         currentlyConnectedSensor.text = [[[currentFirmata currentlyDisplayingService] peripheral] name];
    }
    
    
}

- (void) viewDidUnload
{
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
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSLog(@"%ld", (long)indexPath.row);
    NSLog(@"%@", [pinsArray objectAtIndex:indexPath.row] );
    
    PinViewController *dest =[segue destinationViewController];
    dest.currentFirmata = currentFirmata;
    dest.pinDictionary = [pinsArray objectAtIndex:indexPath.row];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinList"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PinList"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    
    NSLog(@"Pin at row  %i: %@", indexPath.row, [pinsArray objectAtIndex:indexPath.row]);
    
    NSDictionary *pin = [pinsArray objectAtIndex:indexPath.row];

    if([pin objectForKey:@"lastvalue"]){
        NSNumber *value =  [pin objectForKey:@"lastvalue"];
        NSLog(@"%@",value);
        NSString *detailTextString = [[NSString alloc] initWithFormat:@"%i", [value integerValue] ];
        [[cell detailTextLabel] setText:detailTextString];
    }
    
    [[cell textLabel] setText:[pin valueForKey:@"name"]];
    
    //no accessory if analog
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    NSMutableDictionary *modesDictionary = [pin objectForKey:@"modes"];
    
    if(modesDictionary && ([modesDictionary count] > 0)){
        
        UIButton *modeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [modeButton addTarget:self
                   action:@selector(selectMode:)
         forControlEvents:UIControlEventTouchDown];
        NSNumber *currentModeNumber =  [pin objectForKey:@"currentMode"];
        int currentModeInt = [currentModeNumber intValue];
        NSString *currentModeString = [currentFirmata pinmodeEnumToString:currentModeInt];
        [modeButton setTitle:currentModeString forState:UIControlStateNormal];
        modeButton.frame = CGRectMake(50,10,75,30);
        modeButton.tag = indexPath.row;
        [cell.contentView addSubview:modeButton];
        
    }
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
            [self performSegueWithIdentifier: @"pinView" sender:self];
            break;
            
        case SHIFT:
            [self performSegueWithIdentifier: @"pinView" sender:self];
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
- (void) didUpdatePin:(int)pin currentMode:(PINMODE)mode value:(unsigned short int)value
{
     NSMutableDictionary *pinObject =[pinsArray objectAtIndex:pin];
    [pinObject setObject:[NSNumber numberWithInt:value] forKey:@"lastvalue"];
    [pinObject setObject:[NSNumber numberWithInt:mode] forKey:@"currentMode"];
    //[self.tableView reloadData];
    
}

- (void) didReportFirmware:(NSString*)name major:(unsigned short int)major minor:(unsigned short int)minor
{
    firmwareVersion.text = [NSString stringWithFormat:@"%@ %ld.%ld",
                            name, (long)major, (long)minor];
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
    int totalPins = [incomingPins count];      //29
    int totalAnalog = [analogMapping count];   //11
    int totalDigital = totalPins-totalAnalog;  //18
    
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
        //[currentFirmata pinStateQuery:i];
        
        [pin setValue:[NSNumber numberWithInt:i] forKey:@"firmatapin"];
        
        [pinsArray addObject:pin];
    }

    NSLog(@"Local Pins declaration %@",pinsArray);
    [self.tableView reloadData];
}

- (void) didReceiveAnalogPin:(int)pin value:(unsigned short)value
{
    NSLog(@"pin: %i, value:%i", pin, value);
    if(pinsArray && [pinsArray count]>0){
        NSDictionary *aPin = pinsArray[pin];
        [aPin setValue:[NSNumber numberWithInt:value] forKey:@"lastvalue"];
        [self.tableView reloadData];
    }
}

- (void) didReceiveDigitalPort:(int)port mask:(unsigned short)mask
{
    NSLog(@"port: %i, mask:%i", port, mask);
    
}

- (void) didReceiveDigitalPin:(int)pin status:(BOOL)status
{
    NSLog(@"Digital Update pin: %d, value:%hhd", pin, status);

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

        [pin setObject:[NSNumber numberWithInt:newMode] forKey:@"currentMode"];

        [currentFirmata setPinMode:actionSheet.tag mode:newMode];

        if(newMode == ANALOG){

            [currentFirmata reportAnalog:actionSheet.tag enable:YES];
        }
        

        [self.tableView reloadData];
    }

}

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld", (long)buttonIndex);
    //could do something here
}

#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
-(IBAction)send:(id)sender
{
//    [currentFirmata setPinMode:16 mode:OUTPUT];
//    [currentFirmata setPinMode:23 mode:OUTPUT];
//
//    [currentFirmata digitalMessagePort:2 mask:0x81];
    
//    int motorPin1 = 16;//digital 16
//    int motorPin2 = 5;//analog 5
//    
//    int motorPin2Firmata = [(NSNumber*)[analogMapping objectForKey:[NSNumber numberWithInt:motorPin2]] intValue];
//    
//    NSLog(@"firmata lookup %d -> %d",motorPin2, motorPin2Firmata);
//    
//    int port1 = [currentFirmata portForPin:motorPin1];
//    int port2 = [currentFirmata portForPin:motorPin2Firmata];
//    
//    unsigned short int mask1 = [currentFirmata bitMaskForPin:motorPin1];
//    unsigned short int mask2 = [currentFirmata bitMaskForPin:motorPin2Firmata];
//    unsigned short int mask = [currentFirmata bitMaskForPin:motorPin1] | [currentFirmata bitMaskForPin:motorPin2Firmata];
//    
//    NSLog(@"port1: %d mask1: %hu port2: %d mask2: %hu ",port1, mask1, port2, mask2);
//    
//    NSLog(@"port: %d mask: %hu",port1, mask);
//    
//    [currentFirmata setPinMode:motorPin1 mode:OUTPUT];
//    [currentFirmata setPinMode:motorPin2Firmata mode:OUTPUT];
//    [currentFirmata digitalMessagePort:port1 mask:mask];
    
//    [currentFirmata samplingInterval:10000]; //optional
//    [currentFirmata reportAnalog:0 enable:YES];
    
    
    //    [currentFirmata samplingInterval:10000]; //optional
    //    [currentFirmata reportAnalog:0 enable:YES];
    
    
//    [currentFirmata setPinMode:23 mode:INPUT]; //make input
//    [currentFirmata digitalMessagePort:[currentFirmata portForPin:23]
//                                  mask:[currentFirmata bitMaskForPin:23]]; //turn on pullups
//    [currentFirmata reportDigital:[currentFirmata portForPin:23] enable:YES];


////    [currentFirmata setPinMode:2 mode:I2C]; //seemingly not necessary?
////    [currentFirmata setPinMode:3 mode:I2C]; //seemingly not necessary?
//    
//    [currentFirmata i2cConfig:0 data:[[NSData alloc]init]];
//
//    #define DISP_CHAR_5X7	0x80
//    #define LEDAddress      0x04
//    
//    int time = 10000;
//    
//    const unsigned char led[] = {DISP_CHAR_5X7, 'n', time>>8, time & 0xff};
//    NSData *data = [[NSData alloc] initWithBytes:led length:sizeof(led)];
//    
//    [currentFirmata i2cRequest:WRITE address:0 data:[[NSData alloc] init ]];//first call never works?
//    [currentFirmata i2cRequest:WRITE address:LEDAddress data:data];

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
        
        for (NSString* mode in modesDictionary) {
            NSString *modeString =[currentFirmata pinmodeEnumToString:(PINMODE)[mode intValue]];
            
            [actionsheet addButtonWithTitle:modeString ];

        }
    }

    actionsheet.tag=sender.tag;
    [actionsheet showInView:self.view];
}

@end
