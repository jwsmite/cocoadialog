// CDRadio.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDRadio.h"

@implementation CDRadio

+ (NSString *) scope {
    return @"radio";
}

+ (CDOptions *) availableOptions {
    CDOptions* options = super.availableOptions;

    // Require at least one button.
    options[@"button1"].require(YES).min(1);

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDBoolean,  @"allow-mixed"),
    CDOption.create(CDNumber,   @"disabled").max(-1),
    CDOption.create(CDString,   @"items").min(2).max(-1).require(YES),
    CDOption.create(CDNumber,   @"mixed").max(-1),
    CDOption.create(CDNumber,   @"selected"),
    ]);
}

- (void) controlHasFinished:(NSUInteger)button {
    // Find the selected radio button
    NSButton *selectedButton = nil;
    for (NSButton *radio in self.radios) {
        if (radio.state == NSControlStateValueOn) {
            selectedButton = radio;
            break;
        }
    }
    
    if (selectedButton != nil) {
        if (self.options[@"return-labels"].wasProvided) {
            self.returnValues[@"value"] = selectedButton.title;
        }
        else {
            self.returnValues[@"value"] = [NSNumber numberWithInteger:selectedButton.tag];
        }
    }
    else {
        self.returnValues[@"value"] = @-1;
    }
    
    [super controlHasFinished:button];
}

- (void) createControl {
    // Set properties first
    self.items = self.options[@"items"].arrayValue ?: [NSArray array];
    self.mixed = self.options[@"mixed"].arrayValue ?: [NSArray array];
    self.disabled = self.options[@"disabled"].arrayValue ?: [NSArray array];
    
    // Call super to set up the basic dialog
    [super createControl];
}

- (void) createControlView {
    // Create radio buttons programmatically
    self.radios = [NSMutableArray array];
    
    NSView *containerView = [[NSView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.controlView addSubview:containerView];
    
    // Pin container to controlView
    [containerView.leadingAnchor constraintEqualToAnchor:self.controlView.leadingAnchor].active = YES;
    [containerView.trailingAnchor constraintEqualToAnchor:self.controlView.trailingAnchor].active = YES;
    [containerView.topAnchor constraintEqualToAnchor:self.controlView.topAnchor].active = YES;
    [containerView.bottomAnchor constraintEqualToAnchor:self.controlView.bottomAnchor].active = YES;
    
    // Create a radio button for each item
    NSView *previousRadio = nil;
    NSUInteger selectedIndex = self.options[@"selected"].wasProvided ? self.options[@"selected"].unsignedIntValue : NSNotFound;
    
    for (NSUInteger i = 0; i < self.items.count; i++) {
        NSButton *radio = [[NSButton alloc] init];
        radio.buttonType = NSButtonTypeRadio;
        radio.title = self.items[i];
        radio.tag = i;
        radio.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Set target and action to handle radio button grouping
        radio.target = self;
        radio.action = @selector(radioButtonClicked:);
        
        // Set initial state
        if (i == selectedIndex) {
            radio.state = NSControlStateValueOn;
        }
        if ([self.disabled containsObject:[NSString stringWithFormat:@"%lu", i]]) {
            radio.enabled = NO;
        }
        
        [containerView addSubview:radio];
        [self.radios addObject:radio];
        
        // Position constraints
        [radio.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:20].active = YES;
        [radio.trailingAnchor constraintLessThanOrEqualToAnchor:containerView.trailingAnchor constant:-20].active = YES;
        
        if (previousRadio == nil) {
            // First radio - pin to top
            [radio.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10].active = YES;
        } else {
            // Subsequent radios - stack below previous
            [radio.topAnchor constraintEqualToAnchor:previousRadio.bottomAnchor constant:8].active = YES;
        }
        
        // Last radio pins to bottom
        if (i == self.items.count - 1) {
            [radio.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-10].active = YES;
        }
        
        previousRadio = radio;
    }
    
    // Set minimum width
    [self.controlView.widthAnchor constraintGreaterThanOrEqualToConstant:300].active = YES;
}

- (void) radioButtonClicked:(NSButton *)sender {
    // Deselect all other radio buttons when one is clicked
    for (NSButton *radio in self.radios) {
        if (radio != sender) {
            radio.state = NSControlStateValueOff;
        }
    }
    // Ensure the clicked one is selected
    sender.state = NSControlStateValueOn;
}

- (BOOL) isReturnValueEmpty {
    // Check if any radio is selected
    for (NSButton *radio in self.radios) {
        if (radio.state == NSControlStateValueOn) {
            return NO;
        }
    }
    return YES;
}

- (NSString *) returnValueEmptyText {
    if (self.items.count > 1) {
        return @"You must select at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must select the item \"%@\" before continuing.", self.items[0]];
    }
}

@end
