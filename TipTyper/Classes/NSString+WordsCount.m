//
//  NSString+WordsCount.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/10/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "NSString+WordsCount.h"

@implementation NSString (WordsCount)

- (NSUInteger)wordsCount {
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [self componentsSeparatedByCharactersInSet:separators];

    NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqualToString:@""];
    }];

    return [words count] - [separatorIndexes count];
}

- (NSUInteger)charactersCount
{
	NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSUInteger __block count = 0;

	[self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if (![separators characterIsMember:[substring UTF8String][0]])
			count++;
	}];

	return count;
}

@end
