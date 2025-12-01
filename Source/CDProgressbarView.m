// CDProgressbarView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDProgressbarView.h"

@implementation CDProgressbarView

- (void) initView {
    // Initialization if needed
}

- (void) setLabels:(NSArray <NSString *> *)labels {
    _labels = labels;
    if (labels.count > 0 && labels[0].length > 0) {
        self.primaryLabel.stringValue = labels[0];
        self.primaryLabel.hidden = NO;
    } else {
        self.primaryLabel.stringValue = @"";
        self.primaryLabel.hidden = YES;
    }
    
    if (labels.count > 1 && labels[1].length > 0) {
        self.secondaryLabel.stringValue = labels[1];
        self.secondaryLabel.hidden = NO;
    } else {
        self.secondaryLabel.stringValue = @"";
        self.secondaryLabel.hidden = YES;
    }
}

- (void) setValue:(double)value {
    _value = value;
    self.progressbar.doubleValue = value;
}

- (void) setIndeterminate:(BOOL)indeterminate {
    _indeterminate = indeterminate;
    [self.progressbar setIndeterminate:indeterminate];
    if (indeterminate) {
        [self.progressbar startAnimation:self];
    }
    else {
        [self.progressbar stopAnimation:self];
    }
}

@end
