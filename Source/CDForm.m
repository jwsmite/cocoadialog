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

- (void) createControlView {
    // Initialize arrays
    self.textFields = [NSMutableArray array];
    self.labels = [NSMutableArray array];
    
    // Get the accumulated label values (each --label adds one value)
    NSArray *labelTexts = self.options[@"label"].arrayValue;  // Changed from "labels" to "label"
    NSArray *initialValues = self.options[@"value"].arrayValue;  // Changed from "values" to "value"

    // Validate we have labels
    if (!labelTexts || labelTexts.count == 0) {
        return;
    }

    CGFloat viewWidth = self.controlView.frame.size.width;
    if (viewWidth == 0) {
        viewWidth = 400;
    }
    CGFloat yOffset = 0;
    CGFloat fieldHeight = 22;
    CGFloat labelHeight = 17;
    CGFloat spacing = 8;
    
    for (NSUInteger i = 0; i < labelTexts.count; i++) {
        // Get label text
        id labelObj = labelTexts[i];
        NSString *labelText = @"Field";
        if ([labelObj isKindOfClass:[NSString class]]) {
            labelText = (NSString *)labelObj;
        }

        // Create label
        NSTextField *label = [[NSTextField alloc] init];
        label.stringValue = labelText;
        label.editable = NO;
        label.selectable = NO;
        label.bordered = NO;
        label.drawsBackground = NO;
        label.backgroundColor = [NSColor clearColor];
        label.frame = NSMakeRect(0, yOffset, viewWidth, labelHeight);
        [self.labels addObject:label];
        [self.controlView addSubview:label];
        
        yOffset += labelHeight + 4;
        
        // Check if this specific field should be secure
        // Since --secure-field is a flag, check if it was provided i times
        // For now, just make it NOT secure (we'll handle this next)
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
        
        textField.frame = NSMakeRect(0, yOffset, viewWidth, fieldHeight);
        
        // Set initial value if provided
        if (initialValues && i < initialValues.count) {
            id initialObj = initialValues[i];
            if ([initialObj isKindOfClass:[NSString class]]) {
                NSString *initialValue = (NSString *)initialObj;
                if (initialValue.length > 0) {
                    textField.stringValue = initialValue;
                }
            }
        }
        
        // Select all text in first field if requested
        if (i == 0 && self.options[@"selected"].boolValue) {
            [textField selectAll:nil];
        }
        
        [self.textFields addObject:textField];
        [self.controlView addSubview:textField];
        
        yOffset += fieldHeight + spacing;
    }
    
    // Adjust control view height
    NSRect frame = self.controlView.frame;
    frame.size.height = yOffset;
    self.controlView.frame = frame;
}

@end
