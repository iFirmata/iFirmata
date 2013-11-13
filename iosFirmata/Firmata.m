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
	BOOL				seenStartSysex;
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
        seenStartSysex=false;
        
        currentlyDisplayingService = service;
        [currentlyDisplayingService setController:self];
        
        peripheralDelegate = controller;
        
	}
    return self;
}

- (void) dealloc {
    
}

- (void) setController:(id<FirmataProtocol>)controller
{
    peripheralDelegate = controller;
    
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
/* Receive Firmware Name and Version (after query)
 * 0  START_SYSEX (0xF0)
 * 1  queryFirmware (0x79)
 * 2  major version (0-127)
 * 3  minor version (0-127)
 * 4  first 7-bits of firmware name
 * 5  second 7-bits of firmware name
 * x  ...for as many bytes as it needs)
 * 6  END_SYSEX (0xF7)
 */
- (void) parseReportFirmware:(NSData*)data
{
    //location 0+1 to ditch start sysex, +1 command byte, +1 major +1 minor
    //length = -1 to kill end sysex, -1 start sysex, -1 command byte -1 major -1 minor =
    NSRange range = NSMakeRange (4, [data length]-5);
    
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    
    NSData *nameData =[data subdataWithRange:range];
    NSString *name = [[NSString alloc] initWithData:nameData encoding:NSASCIIStringEncoding];
    
    [peripheralDelegate didReportFirmware:name major:(unsigned int*)bytePtr[2] minor:(unsigned int*)bytePtr[3]];
}

/* pin state response
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  pin state response (0x6E)
 * 2  pin (0 to 127)
 * 3  pin mode (the currently configured mode)
 * 4  pin state, bits 0-6
 * 5  (optional) pin state, bits 7-13
 * 6  (optional) pin state, bits 14-20
 ...  additional optional bytes, as many as needed
 * N  END_SYSEX (0xF7)
 */
- (void) parsePinStateResponse:(NSData*)data
{
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    [peripheralDelegate didUpdatePin:(int)bytePtr[2] mode:(Mode)bytePtr[3]];
}


/* analog mapping response
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  analog mapping response (0x6A)
 * 2  analog channel corresponding to pin 0, or 127 if pin 0 does not support analog
 * 3  analog channel corresponding to pin 1, or 127 if pin 1 does not support analog
 * 4  analog channel corresponding to pin 2, or 127 if pin 2 does not support analog
 ...   etc, one byte for each pin
 * N  END_SYSEX (0xF7)
 */
- (void) parseAnalogMappingResponse:(NSData*)data
{
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    //nsdictionary or array?
    //[peripheralDelegate didUpdateAnalogPins:;
}

/* capabilities response
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  capabilities response (0x6C)
 * 2  1st mode supported of pin 0
 * 3  1st mode's resolution of pin 0
 * 4  2nd mode supported of pin 0
 * 5  2nd mode's resolution of pin 0
 ...   additional modes/resolutions, followed by a single 127 to mark the
 end of the first pin's modes.  Each pin follows with its mode and
 127, until all pins implemented.
 * N  END_SYSEX (0xF7)
 */
- (void) parseCapabilityResponse:(NSData*)data
 {
     unsigned char *bytePtr = (unsigned char *)[data bytes];
     //[peripheralDelegate didUpdateDigitalPin:(int)bytePtr[0] value:(unsigned int*)(bytePtr[2]<<7 || bytePtr[1])];
 }





#pragma mark -
#pragma mark Firmata Delegate Methods
/****************************************************************************/
/*				Firmata Delegate Methods                                    */
/****************************************************************************/
- (void) setPinMode:(int)pin mode:(Mode)mode
{
    const unsigned char bytes[] = {START_SYSEX, SET_PIN_MODE, pin, mode, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSUTF8StringEncoding];
    NSLog(@"analogMappingQuery sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

/* analog mapping query
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  analog mapping query (0x69)
 * 2  END_SYSEX (0xF7) (MIDI End of SysEx - EOX)
 */
- (void) analogMappingQuery
{
    const unsigned char bytes[] = {START_SYSEX, REPORT_DIGITAL, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSUTF8StringEncoding];
    NSLog(@"analogMappingQuery sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

- (void) reportDigital
{
    const unsigned char bytes[] = {START_SYSEX, REPORT_DIGITAL, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"digitalQuery sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

/* capabilities query
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  capabilities query (0x6B)
 * 2  END_SYSEX (0xF7) (MIDI End of SysEx - EOX)
 */
- (void) capabilityQuery
{
    const unsigned char bytes[] = {START_SYSEX, CAPABILITY_QUERY, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"capabilityQuery sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

- (void) pinStateQuery:(int)pin
{
    const unsigned char bytes[] = {START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"pinStateQuery sending ascii: %@", stringToSend);
    
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
    NSLog(@"servoConfig sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

//- (void) stringData:(NSString)string{
//    const unsigned char bytes[] = {START_SYSEX, STRING_DATA, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"stringData sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

//- (void) shiftData:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, SHIFT_DATA, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"shiftData sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

//- (void) i2cRequest:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, I2C_REQUEST, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"i2cRequest sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

//- (void) i2cConfig:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, I2C_CONFIG, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
//    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
//    NSLog(@"i2cConfig sending ascii: %@", stringToSend);
//
//    [currentlyDisplayingService write:dataToSend];
//}

/* Query Firmware Name and Version
 * 0  START_SYSEX (0xF0)
 * 1  queryFirmware (0x79)
 * 2  END_SYSEX (0xF7)
 */
- (void) reportFirmware
{
    const unsigned char bytes[] = {START_SYSEX, REPORT_FIRMWARE, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"reportFirmware sending ascii: %@", stringToSend);
    
    [currentlyDisplayingService write:dataToSend];
}

- (void) samplingInterval:(int)intervalMillisecondLSB intervalMillisecondMSB:(int)intervalMillisecondMSB
{
    const unsigned char bytes[] = {START_SYSEX, SAMPLING_INTERVAL, intervalMillisecondMSB, intervalMillisecondMSB, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    NSString* stringToSend = [[NSString alloc] initWithData:dataToSend encoding:NSASCIIStringEncoding];
    NSLog(@"samplingInterval sending ascii: %@", stringToSend);
    
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
    
    //parse of our (up to) 20 bytes
    //may or may not be a whole (or a single) command
    const unsigned char *bytes = [data bytes];
    for (int i = 0; i < [data length]; i++)
    {
        const unsigned char byte = bytes[i];
        NSLog(@"Processing %02hhx", byte);

        if(!seenStartSysex && byte==START_SYSEX)
        {
            NSLog(@"Start sysex received, clear data");
            [firmataData setLength:0];
            [firmataData appendBytes:( const void * )&byte length:1];
            seenStartSysex=true;
        
        }else if(seenStartSysex && byte==END_SYSEX)
        {
            [firmataData appendBytes:( const void * )&byte length:1];
            
            NSLog(@"End sysex received");
            seenStartSysex=false;
            
            const unsigned char *firmataDataBytes = [firmataData bytes];
            NSLog(@"Control byte is %02hhx", firmataDataBytes[1]);
            
            switch ( firmataDataBytes[1] )
            {
                case PIN_STATE_RESPONSE:
                    [self parsePinStateResponse:firmataData];
                    break;
                case DIGITAL_MESSAGE:
                    NSLog(@"type of message is digital");
                    [self parseDigitalResponse:firmataData];
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
        }else{
            [firmataData appendBytes:( const void * )&byte length:1];
        }
    }
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
