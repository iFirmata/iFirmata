//
//  Firmata.h
//  TemperatureSensor
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LeDataService.h"

#define START_SYSEX             0xF0
#define END_SYSEX               0xF7

#define REPORT_ANALOG           0xC0 // query for analog pin
#define REPORT_DIGITAL          0xD0 // query for digital pin
#define REPORT_VERSION          0xF9 // report firmware version
#define REPORT_FIRMWARE         0x79 // report name and version of the firmware

#define SET_PIN_MODE            0xF4
#define DIGITAL_MESSAGE         0x90 // send data for a digital pin
#define ANALOG_MESSAGE          0xE0 //

#define RESERVED_COMMAND        0x00 // 2nd SysEx data byte is a chip-specific command (AVR, PIC, TI, etc).
#define ANALOG_MAPPING_QUERY    0x69 // ask for mapping of analog to pin numbers
#define ANALOG_MAPPING_RESPONSE 0x6A // reply with mapping info
#define CAPABILITY_QUERY        0x6B // ask for supported modes and resolution of all pins
#define CAPABILITY_RESPONSE     0x6C // reply with supported modes and resolution
#define PIN_STATE_QUERY         0x6D // ask for a pin's current mode and value
#define PIN_STATE_RESPONSE      0x6E // reply with a pin's current mode and value
#define EXTENDED_ANALOG         0x6F // analog write (PWM, Servo, etc) to any pin
#define SERVO_CONFIG            0x70 // set max angle, minPulse, maxPulse, freq
#define STRING_DATA             0x71 // a string message with 14-bits per char
#define SHIFT_DATA              0x75 // shiftOut config/data message (34 bits)
#define I2C_REQUEST             0x76 // I2C request messages from a host to an I/O board
#define I2C_REPLY               0x77 // I2C reply messages from an I/O board to a host
#define I2C_CONFIG              0x78 // Configure special I2C settings such as power pins and delay times
#define SAMPLING_INTERVAL       0x7A // sampling interval
#define SYSEX_NON_REALTIME      0x7E // MIDI Reserved for non-realtime messages
#define SYSEX_REALTIME          0x7F // MIDI Reserved for realtime messages


/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class Firmata;

typedef enum {
    input   = 0,
    output  = 1,
    analog  = 2,
    pwm     = 3,
    servo   = 4,
    shift     = 5,
    i2c   = 6,
} Mode;
#define modeArray @"input", @"output", @"analog", @"pwm", @"servo", @"shift", @"i2c", nil

@protocol FirmataProtocol<NSObject>
- (void) didUpdatePin:(int)pin currentMode:(Mode)mode value:(unsigned int)value;
- (void) didReportFirmware:(NSString*)name major:(unsigned int*)major minor:(unsigned int*)minor;
- (void) didUpdateCapability:(NSMutableArray*)pins;
@end


/****************************************************************************/
/*						Firmata service.                                    */
/****************************************************************************/
@interface Firmata : NSObject  <LeDataProtocol>

@property (strong, nonatomic) LeDataService         *currentlyDisplayingService;

@property (strong, nonatomic) NSMutableData         *firmataData;

- (id) initWithService:(LeDataService*)service controller:(id<FirmataProtocol>)controller;
- (void) setController:(id<FirmataProtocol>)controller;

- (NSString*) modeEnumToString:(Mode)enumVal;

//- (void) reset;
//- (void) start;

- (void) pinStateQuery:(int)pin;
- (void) reportFirmware;

- (void) analogMappingQuery;
- (void) capabilityQuery;

- (void) reportDigital:(int)pin enable:(BOOL)enable;
- (void) reportAnalog:(int)pin enable:(BOOL)enable;

- (void) analogMessagePin:(int)pin enable:(BOOL)enable;
- (void) digitalMessagePin:(int)pin enable:(BOOL)enable;

- (void) setPinMode:(int)pin state:(Mode)state;

- (void) samplingInterval:(int)intervalMillisecondLSB intervalMillisecondMSB:(int)intervalMillisecondMSB;
- (void) servoConfig:(int)pin minPulseLSB:(int)minPulseLSB minPulseMSB:(int)minPulseMSB maxPulseLSB:(int)maxPulseLSB maxPulseMSB:(int)maxPulseMSB;

/* Behave properly when heading into and out of the background */

@end