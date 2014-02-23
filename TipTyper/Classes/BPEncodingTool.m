//
//  EncodingTool.m
//  TipTyper
//
//  Created by Bruno Philipe on 4/29/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import "BPEncodingTool.h"

@implementation BPEncodingTool
{
	NSDictionary *encodings;
}

+ (BPEncodingTool *)sharedTool
{
    static dispatch_once_t once;
    static BPEncodingTool *__singleton__;
    dispatch_once(&once, ^ { __singleton__ = [[BPEncodingTool alloc] init]; });
    return __singleton__;
}

- (id)init
{
	self = [super init];
	
	NSInteger rawEncodings[] = {NSUTF8StringEncoding,NSASCIIStringEncoding,NSISOLatin1StringEncoding,NSISOLatin2StringEncoding,NSMacOSRomanStringEncoding,NSWindowsCP1251StringEncoding,NSWindowsCP1252StringEncoding,NSWindowsCP1253StringEncoding,NSWindowsCP1254StringEncoding,NSWindowsCP1250StringEncoding,NSUTF16StringEncoding,NSUTF16BigEndianStringEncoding,NSUTF16LittleEndianStringEncoding,NSUTF32StringEncoding,NSUTF32BigEndianStringEncoding,NSUTF32LittleEndianStringEncoding,NSNEXTSTEPStringEncoding,NSSymbolStringEncoding,NSISO2022JPStringEncoding,NSJapaneseEUCStringEncoding,NSNonLossyASCIIStringEncoding,NSShiftJISStringEncoding};
	NSString *rawNames[] = {@"UTF-8",@"ASCII",@"ISO Latin-1",@"ISO Latin-2",@"Mac OS Roman",@"Windows-1251",@"Windows-1252",@"Windows-1253",@"Windows-1254",@"Windows-1250",@"UTF-16",@"UTF-16 BE",@"UTF-16 LE",@"UTF-32",@"UTF-32 BE",@"UTF-32 LE",@"NeXT",@"Symbol",@"ISO-2022 JP",@"Japanese EUC",@"Lossy ASCII",@"Shift JIS"};

	NSMutableDictionary *dEncodings = [[NSMutableDictionary alloc] initWithCapacity:22];

	for (NSInteger i=0; i<22; i++) {
		[dEncodings setObject:rawNames[i] forKey:[NSNumber numberWithInteger:rawEncodings[i]]];
	}

	encodings = [dEncodings copy];

	return self;
}

- (NSString *)nameForEncoding:(NSInteger)encoding
{
	return [encodings objectForKey:[NSNumber numberWithInteger:encoding]];
}

- (NSArray *)getAllEncodings
{
	NSArray *encs = [encodings allValues];
	encs = [encs sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	return encs;
}

- (NSUInteger)encodingForEncodingName:(NSString *)name
{
	for (NSNumber *enc in [encodings allKeys]) {
		if ([name isEqualToString:[encodings objectForKey:enc]]) {
			return [enc integerValue];
		}
	}

	return -1;
}


@end
