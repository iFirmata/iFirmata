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
@synthesize nonSysexData;
@synthesize analogMapping;
@synthesize ports;
@synthesize pins;

// Place this in the .m file, inside the @implementation block
// A method to convert an enum to string
- (NSString*) pinmodeEnumToString:(PINMODE)enumVal
{
    NSArray *enumArray = [[NSArray alloc] initWithObjects:pinmodeArray];
    return [enumArray objectAtIndex:enumVal];
}

// A method to retrieve the int value from the NSArray of NSStrings
-(PINMODE) modeStringToEnum:(NSString*)strVal
{
    NSArray *enumArray = [[NSArray alloc] initWithObjects:pinmodeArray];
    NSUInteger n = [enumArray indexOfObject:strVal];
    if(n < 1) n = INPUT;
    return (PINMODE) n;
}


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithService:(LeDataService*)service controller:(id<FirmataProtocol>)controller
{
    self = [super init];
    if (self) {
        ports = [[NSMutableArray alloc] init];
        pins = [[NSMutableArray alloc] init];
        
        firmataData = [[NSMutableData alloc] init];
        nonSysexData = [[NSMutableArray alloc] init];
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
// analog I/O message    0xE0   pin #      LSB(bits 0-6)         MSB(bits 7-13)
- (void) parseAnalogMessageResponse:(NSData*) data
{
    const unsigned char *bytes = [data bytes];

    int pin =(bytes[0] & 0x0f);
    unsigned short int lsb = bytes[1] & 0x7f;
    unsigned short int msb = (bytes[2] & 0x7f ) <<7 ;
    
    [peripheralDelegate didReceiveAnalogPin:pin value:lsb+msb];

}

// digital I/O message   0x90   port       LSB(bits 0-6)         MSB(bits 7-13)
- (void) parseDigitalMessageResponse:(NSData*) data
{
    const unsigned char *bytes = [data bytes];
    
    int port =(bytes[0] & 0x0f);
    unsigned short int lsb = bytes[1] & 0x7f;
    unsigned short int msb = (bytes[2] & 0x7f) <<7;
    unsigned short int mask = lsb+msb;
        
    [peripheralDelegate didReceiveDigitalPort:port mask:mask];
    
    for(int i = 0; i<8; i++){
        
        int pin = (port * 8) + i;
        BOOL status = ((0x01<<i) & mask)>>i;
        
        NSLog(@"Port: %d, Digital Value: %hhd",port, status);
        [peripheralDelegate didReceiveDigitalPin:pin status:status];

    }
    
}

/* Receive Firmware Name and Version (after query)
 * 0  START_SYSEX (0xF0)
 * 1  STRING_DATA (0x71)
 * 2  first character LSB (0-6)
 * 3  first character MSB (7-13)
 * x  ...for as many bytes as it needs)
 * 4  END_SYSEX (0xF7)
 */
- (void) parseStringData:(NSData*)data
{
    //location 0+1 to ditch start sysex, +1 command byte
    //length = -1 to kill end sysex, -1 start sysex, -1 command byte
    unsigned char *bytes = (unsigned char *)[data bytes];

    NSMutableString *returnString = [[NSMutableString alloc] init];
    
    for (int i = 2; i < [data length] - 1; i=i+2){
        unsigned short int lsb = bytes[i] & 0x7f;
        unsigned short int msb = (bytes[i+1] & 0x7f ) <<7 ;
        [returnString appendFormat:@"%c", lsb+msb];
    }

    [peripheralDelegate didReceiveStringData:returnString];
}

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
- (void) parseReportFirmwareResponse:(NSData*)data
{
    //location 0+1 to ditch start sysex, +1 command byte, +1 major +1 minor
    //length = -1 to kill end sysex, -1 start sysex, -1 command byte -1 major -1 minor =
    NSRange range = NSMakeRange (4, [data length]-5);
    
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    
    NSData *nameData =[data subdataWithRange:range];
    NSString *name = [[NSString alloc] initWithData:nameData encoding:NSASCIIStringEncoding];
    
    [peripheralDelegate didReportFirmware:name major:(unsigned short int)bytePtr[2] minor:(unsigned short int)bytePtr[3]];
}

/* version report format
 * -------------------------------------------------
 * 0  version report header (0xF9) (MIDI Undefined)
 * 1  major version (0-127)
 * 2  minor version (0-127)
 */
- (void) parseReportVersionResponse:(NSData*)data
{
    unsigned char *bytes = (unsigned char *)[data bytes];
    
    [peripheralDelegate didReportVersionMajor:(unsigned short int)bytes[1] minor:(unsigned short int)bytes[2]];

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
The pin "state" is any data written to the pin. For output modes (digital output, PWM, and Servo), the state is any value that has been previously written to the pin. A GUI needs this state to properly initialize any on-screen controls, so their initial settings match whatever the pin is actually doing. For input modes, typically the state is zero. However, for digital inputs, the state is the status of the pullup resistor.
 */
- (void) parsePinStateResponse:(NSData*)data
{
    unsigned char *bytePtr = (unsigned char *)[data bytes];

    int pin = bytePtr[2];
    int currentMode = bytePtr[3];
    unsigned short int value = (unsigned short int)bytePtr[4] & 0x7F;
    int port = pin / 8;

    NSLog(@"Pin: %i, Mode: %i, Value %i", pin, currentMode, value);
    
    NSLog(@"Setting Pin %i for port %i", pin, port);
    
    //check if if its digital
    
//    @try {
//        unsigned short int mask = [(NSNumber*)[ports objectAtIndex:port] unsignedShortValue];
//        [ports insertObject:[NSNumber numberWithUnsignedChar:mask & ~(value<<(pin % 8))] atIndex:port];
//
//    }
//    @catch (NSException *exception) {
//    }
//    @finally {
//        [ports insertObject:[NSNumber numberWithUnsignedChar:value<<(pin % 8)] atIndex:port];
//    }


    [peripheralDelegate didUpdatePin:pin currentMode:(PINMODE)currentMode value:value];
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
    analogMapping = [[NSMutableDictionary alloc] init];
    
    int j = 0;
    unsigned char *bytes = (unsigned char *)[data bytes];
    for (int i = 2; i < [data length]-1; i++)
    {

        if(bytes[i]!=127){
            [analogMapping setObject:[NSNumber numberWithUnsignedChar:j]
                              forKey:[NSNumber numberWithUnsignedChar:bytes[i]]
             ];
        }
        
        j=j+1;
    }
    
    NSLog(@"Analog Mapping Response %@",analogMapping);
    
    [peripheralDelegate didUpdateAnalogMapping:analogMapping];
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

     int j = 0;
     
     const char *bytes = [data bytes];
     //start at 2 to ditch start and command byte
     //take end byte off the end
     for (int i = 2; i < [data length] - 1; i++)
     {
         //ugh altering i inside of loop...
         NSMutableDictionary *modes = [[NSMutableDictionary alloc] init];

         while(bytes[i]!=127){

             const char *mode = bytes[i++];
             const char *resolution = bytes[i++];
             
             NSLog(@"Pin %i  Mode: %02hhx Resolution:%02hhx", j, mode, resolution);
             
             [modes setObject:[NSNumber numberWithChar:resolution] forKey:[NSNumber numberWithChar:mode]];
             
         }
         j=j+1;
         [pins addObject:modes];
     }
     
     NSLog(@"Capability Response %@",pins);
     [peripheralDelegate didUpdateCapability:(NSMutableArray*)pins];
 }


#pragma mark -
#pragma mark Firmata Delegate Methods
/****************************************************************************/
/*				Firmata Delegate Methods                                    */
/****************************************************************************/
// * system reset
- (void) reset
{
    const unsigned char bytes[] = {START_SYSEX, RESET, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    NSLog(@"reset bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/* Query Firmware Name and Version
 * 0  START_SYSEX (0xF0)
 * 1  queryFirmware (0x79)
 * 2  END_SYSEX (0xF7)
 */
- (void) reportFirmware
{
    const unsigned char bytes[] = {START_SYSEX, REPORT_FIRMWARE, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"reportFirmware bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/* request version report
 * 0  request version report (0xF9) (MIDI Undefined)
 */
- (void) reportVersion
{
    const unsigned char bytes[] = {REPORT_VERSION};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    NSLog(@"reportVersion bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

// analog I/O message    0xE0   pin #      LSB(bits 0-6)         MSB(bits 7-13)
- (void) analogMessagePin:(int)pin value:(unsigned short int)value
{
    const unsigned char bytes[] = {ANALOG_MESSAGE + pin, value & 0x7f, (value>>7) & 0x7f};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"analogMessagePin bytes in hex: %@", [dataToSend description]);

    [currentlyDisplayingService write:dataToSend];
}

/* two byte digital data format, second nibble of byte 0 gives the port number (e.g. 0x92 is the third port, port 2)
 * 0  digital data, 0x90-0x9F, (MIDI NoteOn, but different data format)
 * 1  digital pins 0-6 bitmask
 * 2  digital pin 7 bitmask
 */
- (void) digitalMessagePort:(int)port mask:(unsigned short int)mask
{
    const unsigned char bytes[] = {DIGITAL_MESSAGE + port, mask & 0x7f, (mask>>7) & 0x7f};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    NSLog(@"digitalMessagePin bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/*
 * report analog pin     0xC0   pin #      disable/enable(0/1)   - n/a -
 */
- (void) reportAnalog:(int)pin enable:(BOOL)enable
{
    const unsigned char bytes[] = {REPORT_ANALOG + pin, enable};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"reportAnalog bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/* toggle digital port reporting by port (second nibble of byte 0), e.g. 0xD1 is port 1 is pins 8 to 15,
 * 0  toggle digital port reporting (0xD0-0xDF) (MIDI Aftertouch)
 * 1  disable(0)/enable(non-zero)
 */
- (void) reportDigital:(int)port enable:(BOOL)enable
{
    const unsigned char bytes[] = {REPORT_DIGITAL + port, enable};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"reportDigital bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/* set pin mode
 * 1  set digital pin mode (0xF4) (MIDI Undefined)
 * 2  pin number (0-127)
 * 3  state (INPUT/OUTPUT/ANALOG/PWM/SERVO, 0/1/2/3/4)
 */
- (void) setPinMode:(int)pin mode:(PINMODE)mode
{
    const unsigned char bytes[] = {SET_PIN_MODE, pin, mode};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
 
    NSLog(@"setPinMode bytes in hex: %@", [dataToSend description]);

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
    const unsigned char bytes[] = {START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"analogMappingQuery bytes in hex: %@", [dataToSend description]);
    
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

    NSLog(@"capabilityQuery bytes in hex: %@", [dataToSend description]);

    [currentlyDisplayingService write:dataToSend];
}

/* pin state query
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  pin state query (0x6D)
 * 2  pin (0 to 127)
 * 3  END_SYSEX (0xF7) (MIDI End of SysEx - EOX)
 */
- (void) pinStateQuery:(int)pin
{
    const unsigned char bytes[] = {START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"pinStateQuery bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];

}

/* servo config
 * --------------------
 * 0  START_SYSEX (0xF0)
 * 1  SERVO_CONFIG (0x70)
 * 2  pin number (0-127)
 * 3  minPulse LSB (0-6)
 * 4  minPulse MSB (7-13)
 * 5  maxPulse LSB (0-6)
 * 6  maxPulse MSB (7-13)
 * 7  END_SYSEX (0xF7)
 */
- (void) servoConfig:(int)pin minPulse:(unsigned short int)minPulse maxPulse:(unsigned short int)maxPulse
{
    const unsigned char bytes[] = {START_SYSEX, SERVO_CONFIG, pin, minPulse & 0x7f, minPulse>>7 & 0x7f, maxPulse & 0x7f, maxPulse>>7 & 0x7f, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"servoConfig bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/* I2C config
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  I2C_CONFIG (0x78)
 * 2  Delay in microseconds (LSB)
 * 3  Delay in microseconds (MSB)
 * ... user defined for special cases, etc
 * n  END_SYSEX (0xF7)
 */
// default delay time between i2c read request and Wire.requestFrom()
- (void) i2cConfig:(unsigned short int)delay data:(NSData *)data{

    const unsigned char first[] = {START_SYSEX, I2C_CONFIG, delay, delay>>8};
    NSMutableData *dataToSend = [[NSMutableData alloc] initWithBytes:first length:sizeof(first)];
    
    // need to split this data into msb and lsb
    const unsigned char *bytes = [data bytes];
    
    for (int i = 0; i < [data length]; i++)
    {
        unsigned char lsb = bytes[i] & 0x7f;
        unsigned char msb = bytes[i] >> 7  & 0x7f;
        
        const unsigned char append[] = { lsb, msb };
        [dataToSend appendBytes:append length:sizeof(append)];
    }
    
    const unsigned char end[] = {END_SYSEX};
    [dataToSend appendBytes:end length:sizeof(end)];

    NSLog(@"i2cConfig bytes in hex: %@", [dataToSend description]);
    
    [currentlyDisplayingService write:dataToSend];
}

/* I2C read/write request
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  I2C_REQUEST (0x76)
 * 2  slave address (LSB)
 * 3  slave address (MSB) + read/write and address mode bits
 {7: always 0} + {6: reserved} + {5: address mode, 1 means 10-bit mode} +
 {4-3: read/write, 00 => write, 01 => read once, 10 => read continuously, 11 => stop reading} +
 {2-0: slave address MSB in 10-bit mode, not used in 7-bit mode}
 * 4  data 0 (LSB)
 * 5  data 0 (MSB)
 * 6  data 1 (LSB)
 * 7  data 1 (MSB)
 * ...
 * n  END_SYSEX (0xF7)
 */
- (void) i2cRequest:(I2CMODE)i2cMode address:(unsigned short int)address data:(NSData *)data{
    
    const unsigned char first[] = {START_SYSEX, I2C_REQUEST, address, i2cMode};
    NSMutableData *dataToSend = [[NSMutableData alloc] initWithBytes:first length:sizeof(first)];
    
    // need to split this data into msb and lsb
    const unsigned char *bytes = [data bytes];

    for (int i = 0; i < [data length]; i++)
    {
        unsigned char lsb = bytes[i] & 0x7f;
        unsigned char msb = bytes[i] >> 7  & 0x7f;
        
        const unsigned char append[] = { lsb, msb };
        [dataToSend appendBytes:append length:sizeof(append)];
    }
    
    const unsigned char end[] = {END_SYSEX};
    [dataToSend appendBytes:end length:sizeof(end)];
    
    NSLog(@"i2cRequest bytes in hex: %@", [dataToSend description]);

    [currentlyDisplayingService write:dataToSend];
}

/* extended analog
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  extended analog message (0x6F)
 * 2  pin (0 to 127)
 * 3  bits 0-6 (least significant byte)
 * 4  bits 7-13
 * ... additional bytes may be sent if more bits needed
 * N  END_SYSEX (0xF7) (MIDI End of SysEx - EOX)
 */
//- (void) extendedAnalogQuery:(int)pin:] withData:(NSData)data{
//    const unsigned char bytes[] = {START_SYSEX, EXTENDED_ANALOG, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

//    NSLog(@"extendedAnalogQuery bytes in hex: %@", [dataToSend description]);

//
//    [currentlyDisplayingService write:dataToSend];
//}

- (void) stringData:(NSString*)string{
    
    const unsigned char first[] = {START_SYSEX, STRING_DATA};
        
    NSMutableData *dataToSend = [[NSMutableData alloc] initWithBytes:first length:sizeof(first)];
    
    NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];

    const unsigned char *bytes = [data bytes];
    
    for (int i = 0; i < [data length]; i++)
    {
        unsigned char lsb = bytes[i] & 0x7f;
        unsigned char msb = bytes[i] >> 7  & 0x7f;
        
        const unsigned char append[] = { lsb, msb };
        [dataToSend appendBytes:append length:sizeof(append)];
    }
    
    //issue #72 and #50 on firmata, will be fixed in 2.4
    const unsigned char end[] = {0, 0, END_SYSEX};
    [dataToSend appendBytes:end length:sizeof(end)];
    
    NSLog(@"stringData bytes in hex: %@", [dataToSend description]);

    [currentlyDisplayingService write:dataToSend];
}

//- (void) shiftData:(int)high{
//    const unsigned char bytes[] = {START_SYSEX, SHIFT_DATA, pin, END_SYSEX};
//    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

//    NSLog(@"shiftData bytes in hex: %@", [dataToSend description]);
//
//    [currentlyDisplayingService write:dataToSend];
//}


/* Set sampling interval
 * -------------------------------
 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
 * 1  SAMPLING_INTERVAL (0x7A)
 * 2  sampling interval on the millisecond time scale (LSB)
 * 3  sampling interval on the millisecond time scale (MSB)
 * 4  END_SYSEX (0xF7)
 */
- (void) samplingInterval:(unsigned short int)intervalMilliseconds
{
    const unsigned char bytes[] = {START_SYSEX, SAMPLING_INTERVAL, intervalMilliseconds & 0x7f, (intervalMilliseconds>>7) & 0x7f, END_SYSEX};
    NSData *dataToSend = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];

    NSLog(@"samplingInterval bytes in hex: %@", [dataToSend description]);
    
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
    
    //data may or may not be a whole (or a single) command
    //unless jumbled, sysex bytes should never occur in data stream
    const unsigned char *bytes = [data bytes];
    for (int i = 0; i < [data length]; i++)
    {
        const unsigned char byte = bytes[i];
        NSLog(@"Processing %02hhx", byte);
        
        if(byte==START_SYSEX) //start me up
        {
            NSLog(@"Start sysex received, clear data");
            [firmataData setLength:0];
            [firmataData appendBytes:( const void * )&byte length:1];
            seenStartSysex=true;
            
        }else if(byte==END_SYSEX) //Thats it, parse it
        {
            [firmataData appendBytes:( const void * )&byte length:1];
            
            NSLog(@"End sysex received");
            seenStartSysex=false;
            
            const unsigned char *firmataDataBytes = [firmataData bytes];
            NSLog(@"Sysex Command byte is %02hhx", firmataDataBytes[1]);
            
            switch ( firmataDataBytes[1] )
            {
                    
                case ANALOG_MAPPING_RESPONSE:
                    [self parseAnalogMappingResponse:firmataData];
                    break;
                    
                case CAPABILITY_RESPONSE:
                    [self parseCapabilityResponse:firmataData];
                    break;
                    
                case PIN_STATE_RESPONSE:
                    [self parsePinStateResponse:firmataData];
                    break;
                    
                case REPORT_FIRMWARE:
                    NSLog(@"type of message is firmware report");
                    [self parseReportFirmwareResponse:firmataData];
                    break;
                case STRING_DATA:
                    [self parseStringData:firmataData];
                    break;
                    
                default:
                    NSLog(@"type of message unknown");
                    break;
            }
            [firmataData setLength:0];
            
        }else if(seenStartSysex) //In sysex, but were not at the end yet, just store it
        {
            NSLog(@"In sysex, appending waiting for end sysex %c", byte);
            [firmataData appendBytes:( const void * )&byte length:1];
            
        }else //not in sysex
        {
            NSLog(@"Nonsysex data");

            //really want like 3 byte queue here, if we know what the first byte is, parse it, else remove it
            [nonSysexData addObject:[NSNumber numberWithUnsignedShort:byte]];
            
            if([nonSysexData count]==3)
            {
                const unsigned short byte = [(NSNumber*)[nonSysexData objectAtIndex:0] unsignedShortValue];
                
                NSLog(@"3 bytes received, first byte is %02hx", byte);
                
                if( byte >= ANALOG_MESSAGE && byte <=  ANALOG_MESSAGE +15 )
                {
                    NSLog(@"Analog Message");
                    
                    [self parseAnalogMessageResponse:[NSData dataWithBytes:(unsigned char[]){[(NSNumber*)nonSysexData[0] unsignedCharValue],[(NSNumber*)nonSysexData[1] unsignedCharValue],[(NSNumber*)nonSysexData[2] unsignedCharValue]} length:3]];
                    [nonSysexData removeAllObjects];
                    
                }
                else if( byte >= DIGITAL_MESSAGE && byte <=  DIGITAL_MESSAGE +15 )
                {
                    NSLog(@"Digital Message");
                    [self parseDigitalMessageResponse:[NSData dataWithBytes:(unsigned char[]){[(NSNumber*)nonSysexData[0] unsignedCharValue],[(NSNumber*)nonSysexData[1] unsignedCharValue],[(NSNumber*)nonSysexData[2] unsignedCharValue]} length:3]];
                        [nonSysexData removeAllObjects];
                    
                }
                else if(byte==REPORT_VERSION){
                    NSLog(@"Report Version");
                    [self parseReportVersionResponse:[NSData dataWithBytes:(unsigned char[]){[(NSNumber*)nonSysexData[0] unsignedCharValue],[(NSNumber*)nonSysexData[1] unsignedCharValue],[(NSNumber*)nonSysexData[2] unsignedCharValue]} length:3]];
                        [nonSysexData removeAllObjects];
                    
                }
                else{
                    NSLog(@"Don't know, dumping %hu", byte);
                    //dont know!, dump it
                    [nonSysexData removeObjectAtIndex:0 ];
                }
                
            }
        }
    }
}
- (int) portForPin:(int)pin{
    return pin/8;
}

- (unsigned short int) bitMaskForPin:(int)pin{
    return 0x01 << pin % 8;
}

/** Central Manager reset */
- (void) serviceDidReset
{
    NSLog(@"Service reset");
    //TODO do something? probably have to go back to root controller and reconnect?
}

/** Peripheral connected or disconnected */
- (void) serviceDidChangeStatus:(LeDataService*)service
{
    NSLog(@"serviceDidChangeStatus in Firmata");
    
    //TODO do something?
    if ( [[service peripheral] isConnected] ) {
        NSLog(@"Service (%@) connected", service.peripheral.name);
        [peripheralDelegate didConnect];
    }
    
    else {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        [peripheralDelegate didDisconnect];
    }
}


@end
