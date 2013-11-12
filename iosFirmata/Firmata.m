//
//  Firmata.m
//  TemperatureSensor
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "Firmata.h"
#import "LeDataService.h"

@interface Firmata()  <LeDataProtocol>{
@private
	BOOL				inMessage;
    id<FirmataProtocol>	peripheralDelegate;
}
@end


@implementation Firmata

@synthesize currentlyDisplayingService;
@synthesize firmataData;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithService:(LeDataService*)service controller:(id<FirmataProtocol>)controller
{
    self = [super init];
    if (self) {
        firmataData = [[NSMutableData alloc] init];
        inMessage=false;
        
        currentlyDisplayingService = service;
        [currentlyDisplayingService setController:self];
        
        peripheralDelegate = controller;
        
	}
    return self;
}

- (void) dealloc {
    
}


#pragma mark -
#pragma mark LeData Interactions
/****************************************************************************/
/*                  LeData Interactions                                     */
/****************************************************************************/
- (LeDataService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    if ( [[currentlyDisplayingService peripheral] isEqual:peripheral] ) {
        return currentlyDisplayingService;
    }
    
    return nil;
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered background notification called.");
    [currentlyDisplayingService enteredBackground];
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered foreground notification called.");
    [currentlyDisplayingService enteredForeground];
    
}


#pragma mark -
#pragma mark Firmata Parsers
/****************************************************************************/
/*				Firmata Parsers                                             */
/****************************************************************************/
- (void) parseReportFirmware:(NSData*)data{
    //TODO do some parsing first
    [peripheralDelegate didReportFirmware:data];
}


#pragma mark -
#pragma mark Firmata Delegate Methods
/****************************************************************************/
/*				Firmata Delegate Methods                                    */
/****************************************************************************/
- (void) analogMappingQuery
{
    const unsigned char bytes[] = {START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"Report firmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

- (void) capabilityQuery
{
    const unsigned char bytes[] = {START_SYSEX, CAPABILITY_QUERY, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"Report firmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

- (void) pinStateQuery:(int)pin
{
    const unsigned char bytes[] = {START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"Report firmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];

}

//- (void) extendedAnalogQuery:(int)pin:] withData:(NSData)data{
//    const unsigned char bytes[] = {START_SYSEX, EXTENDED_ANALOG, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"Report firmware sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

    
- (void) servoConfig:(int)pin minPulseLSB:(int)minPulseLSB minPulseMSB:(int)minPulseMSB maxPulseLSB:(int)maxPulseLSB maxPulseMSB:(int)maxPulseMSB
{
    const unsigned char bytes[] = {START_SYSEX, SERVO_CONFIG, pin, minPulseLSB, minPulseMSB, maxPulseLSB, maxPulseMSB, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"Report firmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

//- (void) stringData:(NSString)string{
//    const unsigned char bytes[] = {START_SYSEX, STRING_DATA, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"Report firmware sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

//- (void) shiftData:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, SHIFT_DATA, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"Report firmware sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

//- (void) i2cRequest:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, I2C_REQUEST, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"Report firmware sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

//- (void) i2cConfig:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, I2C_CONFIG, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"Report firmware sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

- (void) reportFirmware
{
    const unsigned char bytes[] = {START_SYSEX, REPORT_FIRMWARE, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"Report firmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

- (void) samplingInterval:(int)intervalMillisecondLSB intervalMillisecondMSB:(int)intervalMillisecondMSB
{
    const unsigned char bytes[] = {START_SYSEX, SAMPLING_INTERVAL, intervalMillisecondMSB, intervalMillisecondMSB, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"Report firmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}


#pragma mark -
#pragma mark LeDataProtocol Delegate Methods
/****************************************************************************/
/*				LeDataProtocol Delegate Methods                             */
/****************************************************************************/
/** Received data */
- (void) serviceDidReceiveData:(NSData*)data fromService:(LeDataService*)service
{
    
    if (service != currentlyDisplayingService)
        return;
    
//    unsigned char mockHex[] = {0xf0,0x90,0x20,0x20,0x20,0xf7};
//    NSData *mock = [NSData dataWithBytes:mockHex length:6];
    
    
    const unsigned char *bytes = [data bytes];
    for (int i = 0; i < [data length]; i++)
    {
        const unsigned char byte = bytes[i];
        NSLog(@"Processing %02hhx", byte);
        
        if(inMessage){
            
            if(byte==END_SYSEX){
                NSLog(@"End sysex received");
                inMessage=false;
                
                //nightmare to get back first byte of nsdata...
                NSRange range = NSMakeRange (0, 1);
                unsigned char buffer;
                [firmataData getBytes:&buffer range:range];
                NSLog(@"Control byte is %02hhx", buffer);
                
                switch ( buffer )
                {
                    case DIGITAL_MESSAGE:
                        NSLog(@"type of message is digital");
                        [peripheralDelegate didUpdateDigitalPin];
                        break;
                        
                    case ANALOG_MESSAGE:
                        NSLog(@"type of message is anlog");
                        break;
                        
                    case REPORT_FIRMWARE:
                        NSLog(@"type of message is firmware report");
                        [self parseReportFirmware:firmataData];
                        break;
                        
                    case REPORT_VERSION:
                        NSLog(@"type of message is version report");
                        break;
                        
                    default:
                        NSLog(@"type of message unknown");
                        break;
                }
            }
            else{
                NSLog(@"appending %02hhx", byte);
                [firmataData appendBytes:( const void * )&byte length:1];
            }
        }
        else if(byte==START_SYSEX){
            NSLog(@"Start sysex received, clear data");
            [firmataData setLength:0];
            inMessage=true;
        }
    }
    return;

    
}

/** Central Manager reset */
- (void) serviceDidReset
{
    //TODO do something? probably have to go back to root controller and reconnect?
}

/** Peripheral connected or disconnected */
- (void) serviceDidChangeStatus:(LeDataService*)service
{
    
    //TODO do something?
    if ( [[service peripheral] isConnected] ) {
        NSLog(@"Service (%@) connected", service.peripheral.name);
    }
    
    else {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        
    }
}


@end
