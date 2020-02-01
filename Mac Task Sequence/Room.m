//
//  Room.m
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 Texas A&M University. All rights reserved.
//

#import "Room.h"

/**
 A simple object to represent a room.
 A room object may be owned by a building.
 */

@implementation Room

@synthesize number, type;

#pragma mark -
#pragma mark Initialization methods

/**
 Initializes a new Room object
 @returns An initialized and allocated Room object populated with default/empty values
 
 */
- (Room *) init
{
    self = [super init];
    if (self) {
        number = @"";
        type = @"";
    }
    return self;
}

/**
 Initializes a new Room object from an array of line items (from the Task Sequence Rooms.txt file)
 
 @param line:   Array of line from the Task Sequence Rooms.txt file
 @returns An initialized and allocated Room object populated with the param values
 
 */
- (Room *) initWithArray:(NSArray *)line
{
    self = [super init];
    if (self) {
        // Expecting 3 elements
        // index 0 : building // Not used in this implementation. This relationship exists elsewhere
        // index 1 : room number
        // index 2 : room type
        // index 3 : department // Not used in this implementation. This relationship exists elsewhere
        
        // Make sure line has at least the number of values we need.
        if ([line count] >= 3) {
            number = [line objectAtIndex:1];
            type = [line objectAtIndex:2];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Description methods
/**
 Override default NSObject description method
 @returns a formatted string describing the Room object.
 */
- (NSString *) description
{
    // If we have both a room and a type, display them both
    if ([number length] && [type length]) {
        return [NSString stringWithFormat:@"%@: %@", number, type];
        
    // Otherwise only show the room number (never show type only, that wouldn't make sense)
    } else if ([number length]) {
        return number;
    } else {
        return @"";
    }
    // TODO: refactor this to only have one return point
}

@end
