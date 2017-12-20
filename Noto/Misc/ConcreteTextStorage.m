//
//  ConcreteTextStorage.m
//  Noto
//
//  Created by Bruno Philipe on 20/12/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

#import "ConcreteTextStorage.h"

@implementation ConcreteTextStorage
{
	NSTextStorage *_storage;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_storage = [[NSTextStorage alloc] init];
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString *)attrStr
{
	self = [super init];
	if (self)
	{
		_storage = [[NSTextStorage alloc] initWithAttributedString:attrStr];
	}
	return self;
}

- (id)initWithString:(NSString *)str
{
	self = [super init];
	if (self)
	{
		_storage = [[NSTextStorage alloc] initWithString:str];
	}
	return self;
}

- (id)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey,id> *)attrs
{
	self = [super init];
	if (self)
	{
		_storage = [[NSTextStorage alloc] initWithString:str attributes:attrs];
	}
	return self;
}

- (NSString *)string
{
	return [_storage string];
}

- (NSDictionary<NSAttributedStringKey, id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
	return [_storage attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
	[_storage replaceCharactersInRange:range withString:str];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attrs range:(NSRange)range
{
	[_storage setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)addAttribute:(NSAttributedStringKey)name value:(id)value range:(NSRange)range
{
	[_storage addAttribute:name value:value range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)removeAttribute:(NSAttributedStringKey)name range:(NSRange)range
{
	[_storage removeAttribute:name range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end
