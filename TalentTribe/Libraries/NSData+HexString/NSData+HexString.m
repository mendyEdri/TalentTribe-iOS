//
//  NSData+HexString.m
//  PaYoneerP2
//
//  Created by Bogdan Andresyuk on 12/18/13.
//  Copyright (c) 2013 Amit Bar-Shai. All rights reserved.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)

- (NSString*)hexString {
    unichar* hexChars = (unichar*)malloc(sizeof(unichar) * (self.length*2));
    unsigned char* bytes = (unsigned char*)self.bytes;
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar c = bytes[i] / 16;
        if (c < 10) c += '0';
        else c += 'A' - 10;
        hexChars[i*2] = c;
        c = bytes[i] % 16;
        if (c < 10) c += '0';
        else c += 'A' - 10;
        hexChars[i*2+1] = c;
    }
    NSString* retVal = [[NSString alloc] initWithCharactersNoCopy:hexChars
                                                           length:self.length*2
                                                     freeWhenDone:YES];
    return retVal;
}

@end
