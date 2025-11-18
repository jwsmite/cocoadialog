// CDForm.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDForm.h"

@implementation CDForm

+ (NSString *) scope {
    return @"form";
}

+ (CDOptions *) availableOptions {
    CDOptions* options = super.availableOptions;

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDString,    @"label").require(YES).min(1).max(0),
    CDOption.create(CDString,    @"value").max(0),
    CDOption.create(CDBoolean,   @"secure-field"),  
    CDOption.create(CDBoolean,   @"selected"),
    ]);
}

- (BOOL)isReturnValueEmpty {
    for (NSTextField *field in self.textFields) {
        if (!field.stringValue.isBlank) {
            return NO;
        }
    }
    return YES;
}

- (NSString *) returnValueEmptyText {
    return @"At least one field must contain text.";
}

- (void) controlHasFinished:(NSUInteger)button {
    // Output button number
    [self.terminal writeLine:[NSString stringWithFormat:@"button: %lu", (unsigned long)button]];
    
    // Output each value on its own line
    for (NSTextField *field in self.textFields) {
        NSString *value = field.stringValue ?: @"";
        [self.terminal writeLine:[NSString stringWithFormat:@"value: %@", value]];
    }
    
    [self stopControl];
}

- (void) createControl {
    [super createControl];
    
    // After the control is created, adjust the panel height to fit all fields
    NSArray *labelTexts = self.options[@"label"].arrayValue;
    if (labelTexts && labelTexts.count > 0) {
        CGFloat fieldHeight = 22;
        CGFloat labelHeight = 17;
        CGFloat spacing = 8;
        CGFloat topPadding = 10;
        CGFloat bottomPadding = 10;
        
        // Calculate total height needed for all form fields
        CGFloat formHeight = topPadding + 
                            (labelTexts.count * (labelHeight + 4 + fieldHeight + spacing)) + 
                            bottomPadding;
        
        // Get current panel size
        NSSize currentSize = self.panel.frame.size;
        
        // Calculate additional height needed
        // Base dialog has header, message, buttons (roughly 150-200pt)
        CGFloat minDialogHeight = 180;  // Minimum for header/buttons/margins
        CGFloat desiredHeight = minDialogHeight + formHeight;
        
        // Only resize if we need more space
        if (desiredHeight > currentSize.height) {
            NSRect frame = self.panel.frame;
            CGFloat heightDiff = desiredHeight - frame.size.height;
            frame.size.height = desiredHeight;
            frame.origin.y -= heightDiff;  // Adjust Y to keep top-left position
            [self.panel setFrame:frame display:YES animate:NO];
        }
    }
}

- (void) createControlView {
    // Initialize arrays
    self.textFields = [NSMutableArray array];
    self.labels = [NSMutableArray array];
    
    // Get the accumulated label values (each --label adds one value)
    NSArray *labelTexts = self.options[@"label"].arrayValue;
    NSArray *initialValues = self.options[@"value"].arrayValue;

    // Validate we have labels
    if (!labelTexts || labelTexts.count == 0) {
        return;
    }

    CGFloat fieldHeight = 22;
    CGFloat labelHeight = 17;
    CGFloat spacing = 8;
    CGFloat topPadding = 10;
    
    NSView *previousView = nil;
    
    for (NSUInteger i = 0; i < labelTexts.count; i++) {
        // Get label text
        NSString *labelText = labelTexts[i];
        if (![labelText isKindOfClass:[NSString class]]) {
            labelText = @"Field";
        }

        // Create label
        NSTextField *label = [[NSTextField alloc] init];
        label.stringValue = labelText;
        label.editable = NO;
        label.selectable = NO;
        label.bordered = NO;
        label.drawsBackground = NO;
        label.backgroundColor = [NSColor clearColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.labels addObject:label];
        [self.controlView addSubview:label];
        
        // Label constraints - CHANGED: Use fixed width instead of trailing anchor
        [label.leadingAnchor constraintEqualToAnchor:self.controlView.leadingAnchor].active = YES;
        [label.widthAnchor constraintEqualToConstant:350].active = YES;  // ← CHANGED
        [label.heightAnchor constraintEqualToConstant:labelHeight].active = YES;
        
        if (previousView == nil) {
            [label.topAnchor constraintEqualToAnchor:self.controlView.topAnchor constant:topPadding].active = YES;
        } else {
            [label.topAnchor constraintEqualToAnchor:previousView.bottomAnchor constant:spacing].active = YES;
        }
        
        // Check if this field should be secure
        BOOL isSecure = NO;
        NSString *lowerLabel = [labelText lowercaseString];
        if ([lowerLabel containsString:@"password"] || 
            [lowerLabel containsString:@"secret"] ||
            [lowerLabel containsString:@"pin"] ||
            [lowerLabel containsString:@"passphrase"]) {
            isSecure = YES;
        }

        // Create text field
        NSTextField *textField;
        if (isSecure) {
            textField = [[NSSecureTextField alloc] init];
        } else {
            textField = [[NSTextField alloc] init];
        }
        
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Set initial value if provided
        if (initialValues && i < initialValues.count) {
            NSString *initialValue = initialValues[i];
            if ([initialValue isKindOfClass:[NSString class]] && initialValue.length > 0) {
                textField.stringValue = initialValue;
            }
        }
        
        // Select all text in first field if requested
        if (i == 0 && self.options[@"selected"].boolValue) {
            [textField selectAll:nil];
        }
        
        [self.textFields addObject:textField];
        [self.controlView addSubview:textField];
        
        // Text field constraints - CHANGED: Use fixed width instead of trailing anchor
        [textField.leadingAnchor constraintEqualToAnchor:self.controlView.leadingAnchor].active = YES;
        [textField.widthAnchor constraintEqualToConstant:350].active = YES;  // ← CHANGED
        [textField.heightAnchor constraintEqualToConstant:fieldHeight].active = YES;
        [textField.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:4].active = YES;
        
        previousView = textField;
    }
    
    // Set the control view's height based on last field
    if (previousView) {
        // Add a flexible spacer view instead of constraining the last field's bottom
        NSView *spacer = [[NSView alloc] init];
        spacer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.controlView addSubview:spacer];
        
        [spacer.topAnchor constraintEqualToAnchor:previousView.bottomAnchor constant:spacing].active = YES;
        [spacer.leadingAnchor constraintEqualToAnchor:self.controlView.leadingAnchor].active = YES;
        [spacer.widthAnchor constraintEqualToConstant:1].active = YES;
        [spacer.bottomAnchor constraintEqualToAnchor:self.controlView.bottomAnchor constant:-10].active = YES;
        [spacer.heightAnchor constraintGreaterThanOrEqualToConstant:10].active = YES;  // Minimum bottom padding
        
        // Calculate and set minimum height
        CGFloat totalHeight = topPadding + (labelTexts.count * (labelHeight + 4 + fieldHeight + spacing)) + 10;
        [self.controlView.heightAnchor constraintGreaterThanOrEqualToConstant:totalHeight].active = YES;
    }
}

@end
