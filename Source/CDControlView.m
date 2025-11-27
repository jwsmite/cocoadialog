// CDView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControlView.h"

@implementation CDControlView

+ (instancetype) initWithDialog:(CDDialog *)dialog {
    return [[super alloc] initWithDialog:dialog];
}

- (instancetype) initWithDialog:(CDDialog *)dialog {
    self = [super initWithFrame:NSMakeRect(0, 0, dialog.controlView.frame.size.width, dialog.controlView.frame.size.height)];
    if (self) {
        self.dialog = dialog;

        // Attempt to load a XIB for this view.
        if (![[NSBundle mainBundle] loadNibNamed:[self className] owner:self topLevelObjects:nil]) {
            dialog.terminal.error(@"Control view does not contain a XIB named: %@", [self className].doubleQuote.white.bold, nil).exit(CDTerminalExitCodeControlFailure);
        }

        // Use Auto Layout instead of autoresizing masks
        self.translatesAutoresizingMaskIntoConstraints = NO;

        // Initialize the view.
        [self initView];

        // Handle two patterns:
        // 1. New pattern: XIB has a contentView outlet (CDSliderView, CDTextView)
        //    - Add contentView directly to controlView to avoid extra wrapper layer blocking events
        // 2. Old pattern: XIB uses the customView itself as content (CDProgressbarView)
        //    - Add self to controlView
        if (self.contentView != nil) {
            self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.dialog.controlView addSubview:self.contentView];
            
            // Pin contentView to fill the controlView
            [self.contentView.leadingAnchor constraintEqualToAnchor:self.dialog.controlView.leadingAnchor].active = YES;
            [self.contentView.trailingAnchor constraintEqualToAnchor:self.dialog.controlView.trailingAnchor].active = YES;
            [self.contentView.topAnchor constraintEqualToAnchor:self.dialog.controlView.topAnchor].active = YES;
            [self.contentView.bottomAnchor constraintEqualToAnchor:self.dialog.controlView.bottomAnchor].active = YES;
        } else {
            // Old pattern: add self to controlView
            [self.dialog.controlView addSubview:self];
            
            // Pin self to fill the controlView
            [self.leadingAnchor constraintEqualToAnchor:self.dialog.controlView.leadingAnchor].active = YES;
            [self.trailingAnchor constraintEqualToAnchor:self.dialog.controlView.trailingAnchor].active = YES;
            [self.topAnchor constraintEqualToAnchor:self.dialog.controlView.topAnchor].active = YES;
            [self.bottomAnchor constraintEqualToAnchor:self.dialog.controlView.bottomAnchor].active = YES;
        }
    }
    return self;
}

- (void) initView {
}

@end
