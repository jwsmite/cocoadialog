// CDForm.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDForm;

#import "CDDialog.h"

@interface CDForm : CDDialog

@property (strong, nonatomic) NSMutableArray<NSTextField *> *textFields;
@property (strong, nonatomic) NSMutableArray<NSTextField *> *labels;

@end
