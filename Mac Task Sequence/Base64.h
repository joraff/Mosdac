//
//  Base64.h
//
//  Copied from http://www.chrisumbel.com/article/basic_authentication_iphone_cocoa_touch
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject

+ (NSString *)encode:(NSData *)plainText;

@end
