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
    
    self.pins = [NSMutableArray array];
    
    for(int i = 0; i<21; i++){
        NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
        
        [values setValue:[NSNumber numberWithInt:i] forKey:@"pin"];
        [values setValue:[NSNumber numberWithInt:0] forKey:@"value"];
        
        [pins addObject:values];
    }

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
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"PinList"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    
    NSDictionary *dict = pins[indexPath.row];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[cell textLabel] setText:[NSString stringWithFormat:@"Pin: %@",[dict objectForKey:@"pin"]]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@",[dict objectForKey:@"value"]]];
    
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
- (void) didUpdatePin:(int)pin mode:(Mode)mode;
{
    NSLog(@"something");
}

- (void) didReportFirmware:(NSString*)name major:(unsigned int*)major minor:(unsigned int*)minor
{
    firmwareVersion.text = [NSString stringWithFormat:@"%@ %ld.%ld",
                            name, (long)major, (long)minor];
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
    [currentFirmata analogMappingQuery];
    
}

-(void)buttonPressed:(id)sender {
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    NSLog(@"%@",clickedButtonPath);
    
}
@end
