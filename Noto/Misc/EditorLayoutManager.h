//
//  EditorLayoutManager.h
//  Noto
//
//  Created by Bruno Resende on 25/05/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EditorLayoutManager;

@protocol EditorLayoutManagerDelegate <NSObject>

- (void)layoutManagerDidProcessEdit:(nonnull EditorLayoutManager *)layoutManager;

@end

@protocol EditorLayoutManagerDataSource <NSObject>

/// Color to be used to draw the "invisible" characters.
- (nonnull NSColor *)invisiblesColor;

/// The point size for the "invisible" characters. Usually the same as the editor font point size.
- (CGFloat)invisiblesPointSize;

@end

@interface EditorLayoutManager : NSLayoutManager

@property (nullable, weak) id<EditorLayoutManagerDelegate> editorLayoutManagerDelegate;
@property (nullable, weak) id<EditorLayoutManagerDataSource> editorLayoutManagerDataSource;

@property BOOL isDrawingPaused;
@property NSSize textInset;

@property (atomic) BOOL drawsInvisibleCharacters;

- (NSUInteger)lineNumberForRange:(NSRange)charRange;

@end
