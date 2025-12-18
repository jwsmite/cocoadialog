// CDInputbox.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDInputbox.h"

@implementation CDInputbox

+ (NSString *) scope {
    return @"input";
}

+ (CDOptions *) availableOptions {
    CDOptions* options = super.availableOptions;

    // Required at least one button.
    options[@"buttons"].require(YES).min(1);

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDBoolean,  @"secure").deprecates(@[CDOption.create(CDBoolean, @"no-show")]),
    CDOption.create(CDBoolean,  @"selected").deprecates(@[CDOption.create(CDBoolean, @"not-selected")]),
    // For inputbox, --text maps to the default input value
    CDOption.create(CDString,   @"value").deprecates(@[CDOption.create(CDString, @"text")]),
    ]);
}

- (BOOL)isReturnValueEmpty {
    return self.input.stringValue.isBlank;
}

- (NSString *) returnValueEmptyText {
    return @"The text field can cannot be empty, please enter some text.";
}

- (void) createControlView {
    // Determine if it should be secure
    if (self.options[@"secure"].boolValue) {
        self.input = [[NSSecureTextField alloc] init];
    }
    else {
        self.input = [[NSTextField alloc] init];
    }
    
    self.input.refusesFirstResponder = NO;

   // Get default value
    NSString *defaultValue = self.options[@"value"].stringValue;

    // Legacy compatibility
    if ((defaultValue == nil || defaultValue.length == 0) && 
        self.options[@"header"].wasProvided && 
        !self.options[@"value"].wasProvided) {
        defaultValue = self.options[@"header"].stringValue;
    }

    if (defaultValue == nil || defaultValue.length == 0) {
        defaultValue = @"";
    }
    [self.input setStringValue:defaultValue];

    // Select all the text if requested
    if (self.options[@"selected"].wasProvided || self.options[@"selected"].boolValue) {
        [self.input selectAll:nil];
    }

    // Add it to the control view
    [self.controlView addSubview:self.input];

    // Set constraints for proper layout with 20pt left/right padding
    // Position input at top of controlView with padding
    self.input.translatesAutoresizingMaskIntoConstraints = NO;
    [self.input.leadingAnchor constraintEqualToAnchor:self.controlView.leadingAnchor constant:20].active = YES;
    [self.input.trailingAnchor constraintEqualToAnchor:self.controlView.trailingAnchor constant:-20].active = YES;
    [self.input.topAnchor constraintEqualToAnchor:self.controlView.topAnchor constant:12].active = YES;
    
    // Set input field height (don't pin to bottom - let it float at top)
    [self.input.heightAnchor constraintEqualToConstant:22].active = YES;
    
    // Remove the weak XIB height constraint and replace with our own
    for (NSLayoutConstraint *constraint in self.controlView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.active = NO;
        }
    }
    
    // Set controlView height with high priority: input (22) + top padding (12) + bottom padding (40 for spacing from buttons)
    NSLayoutConstraint *heightConstraint = [self.controlView.heightAnchor constraintEqualToConstant:74];
    heightConstraint.priority = NSLayoutPriorityRequired;
    heightConstraint.active = YES;
}

- (void) createHeader {
    // Check if this is legacy format (--text used for input value, not header)
    NSString *headerText = self.options[@"header"].stringValue;
    BOOL isLegacyFormat = (headerText != nil && headerText.length > 0 && 
                           !self.options[@"value"].wasProvided && 
                           self.options[@"header"].wasProvided);
    
    if (isLegacyFormat) {
        // Don't create header - the text will be used as input default value
        self.header.hidden = YES;
        return;
    }
    
    // Normal header creation
    [super createHeader];
}

- (void) controlHasFinished:(NSUInteger)button {
    // Check for cancel
    if (self.cancelButton && button == self.cancelButton.unsignedIntegerValue) {
        self.exitStatus = CDTerminalExitCodeCancel;
    }
    else {
        if (![self allowEmptyReturn] && [self isReturnValueEmpty]) {
            [self returnValueEmptySheet];
            return;
        }
    }
    
    // Output directly to terminal in simple format (no "value: " prefix)
    // This maintains backward compatibility with original cocoaDialog
    [self.terminal writeLine:[NSString stringWithFormat:@"%lu", (unsigned long)button]];
    [self.terminal writeLine:self.input.stringValue ?: @""];
    
    // Stop the control (skip parent's controlHasFinished to avoid double output)
    [self stopControl];
}

@end
