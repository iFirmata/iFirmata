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

@synthesize currentlyDisplayingService;
@synthesize currentlyConnectedSensor;
@synthesize firmwareVersion;
@synthesize currentFirmata;
@synthesize pins;
@synthesize pinsTable;

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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.pins = nil;
    
    currentFirmata = [[Firmata alloc] initWithService:currentlyDisplayingService controller:self];
    currentlyConnectedSensor.text = [[currentlyDisplayingService peripheral] name];


}

- (void) viewDidUnload
{
    [self setCurrentlyConnectedSensor:nil];
    [self setCurrentlyDisplayingService:nil];
    [self setPinsTable:nil];

    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    PinViewController *dest =[segue destinationViewController];
    dest.currentlyDisplayingService = currentlyDisplayingService;
    dest.currentFirmata = currentFirmata;
    
}


#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinList"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PinList"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    
    NSDictionary *pin = pins[indexPath.row];
    
    NSMutableDictionary *modesDictionary = [pin objectForKey:@"modes"];
    
    NSString *modesString = [[NSString alloc] init];
    
    for (NSString* mode in modesDictionary) {
        //NSLog(@"%d",[mode intValue]);
        //NSLog([currentFirmata modeEnumToString:0]);
        modesString = [modesString stringByAppendingString:
                       [NSString stringWithFormat:@"%@,", [currentFirmata pinmodeEnumToString:(PINMODE)[mode intValue]] ]
                       ];
    }
    
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] setText:[NSString stringWithFormat:@"Pin: %ld",(long)indexPath.row]];
    
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ %@", modesString,[pin objectForKey:@"value"]]];
    
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pins count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //todo, SUPPOSED to this this from IB but fuck if I know how
    [self performSegueWithIdentifier: @"pinView" sender:self];
}


#pragma mark -
#pragma mark Firmata Delegates
/****************************************************************************/
/*                              Firmata Delegates                           */
/****************************************************************************/
- (void) didUpdatePin:(int)pin currentMode:(PINMODE)mode value:(unsigned int)value
{
     NSMutableDictionary *pinObject =[pins objectAtIndex:pin];
    [pinObject setObject:[NSNumber numberWithInt:value] forKey:@"value"];
    [pinObject setObject:[NSNumber numberWithInt:mode] forKey:@"currentMode"];
    [self.tableView reloadData];
    
}

- (void) didReportFirmware:(NSString*)name major:(unsigned int*)major minor:(unsigned int*)minor
{
    firmwareVersion.text = [NSString stringWithFormat:@"%@ %ld.%ld",
                            name, (long)major, (long)minor];
}

- (void) didUpdateCapability:(NSMutableArray*)pins
{
    self.pins = pins;
    [self.tableView reloadData];
    
    for (int i =0; i< [pins count]; i++) {
        [currentFirmata pinStateQuery:i];
    }
}

- (void) didReportAnalogPin:(int)pin value:(unsigned int*)value
{
    [self.tableView reloadData];
}






#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
-(IBAction)send:(id)sender
{

    

//    
//    [currentFirmata setPinMode:11 mode:OUTPUT];
//
//    [currentFirmata digitalMessagePin:11 value:0xffff];
    
    [currentFirmata capabilityQuery];
    //[currentFirmata reportDigital:1 enable:YES];
    
    
//#define DISP_CHAR_5X7	0x80
//#define LEDAddress 0x04
//    
//    const unsigned char led[] = {DISP_CHAR_5X7, 'a', 0x03, 0xE8};
//    
//    NSData *data = [[NSData alloc] initWithBytes:led length:4];
//    
//    NSLog(@"i2cRequest bytes in hex: %@", [data description]);
//
//    
//    [currentFirmata i2cRequest:WRITE address:LEDAddress data:data];


}

-(void)buttonPressed:(id)sender {
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    NSLog(@"%@",clickedButtonPath);
    
}
@end
