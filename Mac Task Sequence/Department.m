//
//  Department.m
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Department.h"
#import "Building.h"

@implementation Department

@synthesize name, value;
@synthesize buildings;

- (Department *) init
{
    self = [super init];
    if (self) {
        name = @"";
        value = @"";
        buildings = [[NSMutableDictionary alloc] init];

    }
    return self;
}

- (Department *) initWithArray:(NSArray *)line
{
    self = [super init];
    if (self) {
        // Expecting 2 elements
        // index 0 : value
        // index 1 : name
        if ([line count] >= 2) {
            value = [line objectAtIndex:0];
            name = [line objectAtIndex:1];
        }
        buildings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *) description
{
    //return [NSString stringWithFormat:@"<%@ %p>{\nName: %@\nValue: %@\nBuildings: %@}", [self class], self, [self name], [self value], [self buildings]];
    return name;
}

- (NSArray *) buildingsArray
{
    NSMutableArray *buildingsArray = [[NSMutableArray alloc] init];
    for (NSString *key in buildings)
    {
        Building *b = [buildings objectForKey:key];
        [buildingsArray addObject:b];
    }
    return [NSArray arrayWithArray:buildingsArray];
}
@end
