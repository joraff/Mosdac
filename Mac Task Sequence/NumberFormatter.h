//
//  NumberFormatter.h
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSNumberFormatter : NSFormatter

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string
      errorDescription:(NSString  **)error;

- (NSString *)stringForObjectValue:(id)anObject;

- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error;
                                                                                                             

@end
