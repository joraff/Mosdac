//
//  Building.m
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import "Room.h"

@implementation Building

@synthesize rooms;
@synthesize name, number, value;

- (Building *) init
{
    self = [super init];
    if (self) {
        value = @"";
        name = @"";
        number = @"";
        rooms = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (Building *) initWithArray:(NSArray *)line
{
    self = [super init];
    if (self) {
        // Expecting 3 elements
        // index 0 : value
        // index 1 : name
        // index 2 : building number
        // index 3 : ";"-delimited list of departments
        if ([line count] >= 4) {
            value = [line objectAtIndex:0];
            name = [line objectAtIndex:1];
            number = [line objectAtIndex:2];
        }
        rooms = [[NSMutableDictionary alloc] init];

    }
    return self;
}

- (NSString *) description
{
    if ([value length] && [number length] && [name length]) {
        return [NSString stringWithFormat:@"%@ (%@): %@", value, number, name];
    } else if ([value length]) {
        return value;
    } else {
        return @"";
    }
}

- (NSArray *) roomsArray
{
    NSMutableArray *roomsArray = [[NSMutableArray alloc] init];
    for(NSString *key in rooms)
    {
        Room *r = [rooms objectForKey:key];
        [roomsArray addObject:r];
    }
    return [NSArray arrayWithArray:roomsArray];
}
@end
