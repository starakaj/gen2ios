/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
 
	Modified by Sam Tarakajian --- starakajian@gmail.com
	
	Abstract:
	View for the AUGenExport audio unit.
*/

#import <Cocoa/Cocoa.h>

@class AUGenExportView;

@protocol AUGenExportViewDelegate <NSObject>
// Nothing for now, but that will change
@end

@interface AUGenExportView : NSView
@property (weak)NSObject<AUGenExportViewDelegate> *delegate;

@end
