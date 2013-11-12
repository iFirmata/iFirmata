//
//  DetailViewController.m
//  TemperatureSensor
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "LeDataService.h"

@implementation DetailViewController

@synthesize currentlyDisplayingService;
@synthesize currentlyConnectedSensor;
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
        [pins addObject:[[NSString alloc] initWithFormat:@"%d",i ]];
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


#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PinList"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //copy trends strings into datasource object
    cell.textLabel.text = [pins objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = YES;
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
        //[self performSegueWithIdentifier: @"deviceView" sender:self];

    
}



#pragma mark -
#pragma mark Firmata Delegates
/****************************************************************************/
/*                              Firmata Delegates                           */
/****************************************************************************/
- (void) didUpdateDigitalPin{
    NSLog(@"something");
}


#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/



@end
