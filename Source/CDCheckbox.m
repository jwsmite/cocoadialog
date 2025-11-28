// CDCheckbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDCheckbox.h"
#import "CDCheckboxView.h"

@implementation CDCheckbox

+ (NSString *) scope {
    return @"checkbox";
}

+ (CDOptions *) availableOptions {
    CDOptions *options = super.availableOptions;

    // Require at least one button.
    options[@"button1"].require(YES).min(1);

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDNumber,   @"checked").max(-1),
    CDOption.create(CDNumber,   @"disabled").max(-1),
    CDOption.create(CDString,   @"items").max(-1).require(YES),
    CDOption.create(CDNumber,   @"mixed").max(-1),
    ]);
}

- (void) createControl {
    // Set properties first
    self.checked = self.options[@"checked"].arrayValue ?: [NSArray array];
    self.items = self.options[@"items"].arrayValue ?: [NSArray array];
    self.mixed = self.options[@"mixed"].arrayValue ?: [NSArray array];
    self.disabled = self.options[@"disabled"].arrayValue ?: [NSArray array];
    
    // Call super to set up the basic dialog
    [super createControl];
}

- (void) createControlView {
    // Create checkboxes programmatically instead of using NSMatrix
    self.checkboxes = [NSMutableArray array];
    
    NSView *containerView = [[NSView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlView addSubview:containerView];
    
    // Pin container to controlView
    [containerView.leadingAnchor constraintEqualToAnchor:self.controlView.leadingAnchor].active = YES;
    [containerView.trailingAnchor constraintEqualToAnchor:self.controlView.trailingAnchor].active = YES;
    [containerView.topAnchor constraintEqualToAnchor:self.controlView.topAnchor].active = YES;
    [containerView.bottomAnchor constraintEqualToAnchor:self.controlView.bottomAnchor].active = YES;
    
    // Create a checkbox for each item
    NSView *previousCheckbox = nil;
    for (NSUInteger i = 0; i < self.items.count; i++) {
        NSButton *checkbox = [[NSButton alloc] init];
        checkbox.buttonType = NSButtonTypeSwitch;
        checkbox.title = self.items[i];
        checkbox.tag = i;
        checkbox.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Set initial state
        if ([self.checked containsObject:[NSString stringWithFormat:@"%lu", i]]) {
            checkbox.state = NSControlStateValueOn;
        }
        if ([self.mixed containsObject:[NSString stringWithFormat:@"%lu", i]]) {
            checkbox.allowsMixedState = YES;
            checkbox.state = NSControlStateValueMixed;
        }
        if ([self.disabled containsObject:[NSString stringWithFormat:@"%lu", i]]) {
            checkbox.enabled = NO;
        }
        
        [containerView addSubview:checkbox];
        [self.checkboxes addObject:checkbox];
        
        // Position constraints
        [checkbox.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20].active = YES;
        [checkbox.trailingAnchor constraintLessThanOrEqualToAnchor:containerView.trailingAnchor constant:-20].active = YES;
        
        if (previousCheckbox == nil) {
            // First checkbox - pin to top
            [checkbox.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10].active = YES;
        } else {
            // Subsequent checkboxes - stack below previous
            [checkbox.topAnchor constraintEqualToAnchor:previousCheckbox.bottomAnchor constant:8].active = YES;
        }
        
        // Last checkbox pins to bottom
        if (i == self.items.count - 1) {
            [checkbox.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10].active = YES;
        }
        
        previousCheckbox = checkbox;
    }
    
    // Set minimum width
    [self.controlView.widthAnchor constraintGreaterThanOrEqualToConstant:300].active = YES;
}


- (void) controlHasFinished:(NSUInteger)button {
    NSMutableArray *checkboxesArray = [NSMutableArray array];
    NSEnumerator *en = [self.checkboxes objectEnumerator];
    id obj;
    if (self.options[@"return-labels"].wasProvided) {
        if (self.checkboxes != nil && self.checkboxes.count) {
            unsigned long state;
            while (obj = [en nextObject]) {
                state = [obj state];
                switch (state) {
                    case NSControlStateValueOff: [checkboxesArray addObject: @"off"]; break;
                    case NSControlStateValueOn: [checkboxesArray addObject: @"on"]; break;
                    case NSControlStateValueMixed: [checkboxesArray addObject: @"mixed"]; break;
                }
            }
        }
    } else {
        if (self.checkboxes != nil && self.checkboxes.count) {
            while (obj = [en nextObject]) {
                [checkboxesArray addObject:[NSNumber numberWithInteger:[obj state]]];
            }
        }
    }

    self.returnValues[@"value"] = checkboxesArray;

    [super controlHasFinished:button];
}

- (BOOL) isReturnValueEmpty {
    if (self.checkboxes.count > 0) {
        NSEnumerator *en = [self.checkboxes objectEnumerator];
        BOOL hasChecked = NO;
        id obj;
        while (obj = [en nextObject]) {
            if ([obj state] == NSControlStateValueOn){
                hasChecked = YES;
                break;
            }
        }
        return !hasChecked;
    }
    else {
        return NO;
    }
}

- (NSString *) returnValueEmptyText {
    if (self.checkboxes.count > 1) {
        return @"You must check at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must check the item \"%@\" before continuing.", [self.checkboxes[0] title]];
    }
}

@end
