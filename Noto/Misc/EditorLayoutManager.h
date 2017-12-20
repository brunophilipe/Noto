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

- (void)layoutManagerDidProcessEdit:(EditorLayoutManager *)layoutManager;

@end

@interface EditorLayoutManager : NSLayoutManager

@property (weak) id<EditorLayoutManagerDelegate> editorLayoutManagerDelegate;
@property BOOL isDrawingPaused;

@property (atomic) BOOL drawsInvisibleCharacters;

- (NSUInteger)lineNumberForRange:(NSRange)charRange;

@end
