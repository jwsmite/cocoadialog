// CDForm.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDForm;

#import "CDDialog.h"

@interface CDForm : CDDialog

@property (retain) NSMutableArray<NSTextField *> *textFields;
@property (retain) NSMutableArray<NSTextField *> *labels;

@end

