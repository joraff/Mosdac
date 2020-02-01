//
//  Department.h
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Department : NSObject
{
    NSString *name;
    NSString *value;
    
    NSMutableDictionary *buildings;
}

- (Department *) init;
- (Department *) initWithArray:(NSArray *)line;

- (NSString *) description;

- (NSArray *) buildingsArray;

@property (readwrite, retain) NSString *name, *value;
@property (nonatomic, copy) NSMutableDictionary *buildings;

@end
