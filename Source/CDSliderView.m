// CDSliderView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDSliderView.h"
#import "CDSlider.h"

IB_DESIGNABLE

@implementation CDSliderView

// Override value getter to read from the actual slider control
- (double) value {
    return self.slider.doubleValue;
}

// Override value setter to update the slider control
- (void) setValue:(double)value {
    self.slider.doubleValue = value;
}

- (void) initView {
    [super initView];

    // Get the dialog (which is actually a CDSlider)
    CDSlider *sliderDialog = (CDSlider *)self.dialog;
    
    // Set the label text (or hide if not provided)
    if (sliderDialog.options[@"slider-label"].wasProvided && ![sliderDialog.options[@"slider-label"].stringValue isBlank]) {
        self.label.stringValue = sliderDialog.options[@"slider-label"].stringValue;
    } else {
        self.label.stringValue = @"";
    }
    
    // Initialize value label
    self.valueLabel.stringValue = [NSString stringWithFormat:@"%d", (int)self.slider.doubleValue];
    
    // Show/hide value label based on option
    if (sliderDialog.options[@"always-show-value"].boolValue) {
        self.valueLabel.hidden = NO;
    } else {
        self.valueLabel.hidden = YES;
    }
    
    // Set up slider to call sliderChanged when moved
    self.slider.target = self;
    self.slider.action = @selector(sliderChanged);
    self.slider.continuous = YES;
    
    // Hide ticks label for now (would need tick label generation code)
    self.ticksLabel.hidden = YES;

    [self sliderChanged];
}

- (void) sliderChanged {
    // Update the value label when slider moves
    if (!self.valueLabel.hidden) {
        CDSlider *sliderDialog = (CDSlider *)self.dialog;
        if (sliderDialog.options[@"return-float"].boolValue) {
            self.valueLabel.stringValue = [NSString stringWithFormat:@"%.2f", self.slider.doubleValue];
        } else {
            self.valueLabel.stringValue = [NSString stringWithFormat:@"%d", (int)self.slider.doubleValue];
        }
    }
}

@end



@implementation CDSliderCell

- (BOOL) trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    if (!self.alwaysShowValue)
        [self.valueLabel setHidden:NO];
    return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];
}

- (BOOL) startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    if (self.numberOfTickMarks > 0)
        self.tracking = YES;
    return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL) continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint
                  inView:(NSView *)controlView {
    if (self.tracking && self.sticky) {
        NSUInteger count = self.numberOfTickMarks;
        CGFloat snapFlexibility = (100 / count) / 2;
        for (NSUInteger i = 0; i < count; i++) {
            NSRect tickMarkRect = [self rectOfTickMarkAtIndex:i];
            if (ABS(tickMarkRect.origin.x - currentPoint.x) <= snapFlexibility) {
                [self setAllowsTickMarkValuesOnly:YES];

            } else if (ABS(tickMarkRect.origin.x - currentPoint.x) >= snapFlexibility &&
                       ABS(tickMarkRect.origin.x - currentPoint.x) <= snapFlexibility * 2) {
                [self setAllowsTickMarkValuesOnly:NO];
            }
        }
    }
    else {
        [self setAllowsTickMarkValuesOnly:NO];
    }

    // Fix "may cause leak" warning.
    // @see http://stackoverflow.com/a/20058585/1226717
    if (self.delegate) {
        IMP imp = [self.delegate methodForSelector:self.action];
        void (*func)(id, SEL) = (void *)imp;
        func(self.delegate, self.action);
    }

    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void) stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
    if (!self.alwaysShowValue)
        [self.valueLabel setHidden:YES];
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}


@end
