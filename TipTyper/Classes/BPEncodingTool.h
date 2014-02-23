//
//  EncodingTool.h
//  TipTyper
//
//  Created by Bruno Philipe on 4/29/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPEncodingTool : NSObject

+ (BPEncodingTool *)sharedTool;

- (NSString *)nameForEncoding:(NSInteger)encoding;
- (NSArray *)getAllEncodings;
- (NSUInteger)encodingForEncodingName:(NSString *)name;

@end
