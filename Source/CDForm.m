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

    // Required at least one button.
    options[@"buttons"].require(YES).min(1);

    return options.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDArray,    @"labels").require(YES).min(1),
    CDOption.create(CDArray,    @"values"),
    CDOption.create(CDArray,    @"secure"),
    CDOption.create(CDBoolean,  @"selected"),
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
    NSMutableArray *values = [NSMutableArray array];
    for (NSTextField *field in self.textFields) {
        [values addObject:field.stringValue];
    }
    self.returnValues[@"values"] = values;
    [super controlHasFinished:button];
}

- (void) setControl:(id)sender {
    self.textFields = [NSMutableArray array];
    self.labels = [NSMutableArray array];
    
    NSArray *labelTexts = self.options[@"labels"].arrayValue;
    NSArray *initialValues = self.options[@"values"].arrayValue;
    NSArray *secureFields = self.options[@"secure"].arrayValue;
    
    CGFloat yOffset = 0;
    CGFloat fieldHeight = 22;
    CGFloat labelHeight = 17;
    CGFloat spacing = 8;
    
    for (NSUInteger i = 0; i < labelTexts.count; i++) {
        // Create label
        NSTextField *label = [[NSTextField alloc] init];
        label.stringValue = labelTexts[i];
        label.editable = NO;
        label.selectable = NO;
        label.bordered = NO;
        label.backgroundColor = [NSColor clearColor];
        label.frame = NSMakeRect(0, yOffset, self.controlView.frame.size.width, labelHeight);
        [self.labels addObject:label];
        [self.controlView addSubview:label];
        
        yOffset += labelHeight + 4;
        
        // Create text field
        NSTextField *textField;
        BOOL isSecure = i < secureFields.count && [secureFields[i] boolValue];
        
        if (isSecure) {
            textField = [[NSSecureTextField alloc] init];
        } else {
            textField = [[NSTextField alloc] init];
        }
        
        textField.frame = NSMakeRect(0, yOffset, self.controlView.frame.size.width, fieldHeight);
        
        // Set initial value if provided
        if (i < initialValues.count && initialValues[i] != nil) {
            textField.stringValue = initialValues[i];
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
    CGRect frame = self.controlView.frame;
    frame.size.height = yOffset;
    self.controlView.frame = frame;
}

@end