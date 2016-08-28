/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Modified by Sam Tarakajian --- starakajian@gmail.com
	
	Abstract:
	View for the AUGenExport audio unit.
*/

#import "AUGenExportView.h"

@interface AUGenExportView () {
    CALayer         *containerLayer;
}
@end

@implementation AUGenExportView

-(void)dealloc
{
    NSLog(@"Dealloc called on AUGenExportView\n");
}

-(void)awakeFromNib {
    
    containerLayer = [CALayer layer];
    containerLayer.name = @"container";
    containerLayer.anchorPoint = CGPointZero;
    containerLayer.frame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    containerLayer.bounds = containerLayer.frame;
	containerLayer.backgroundColor = [NSColor greenColor].CGColor;
    [self.layer addSublayer: containerLayer];
}

@synthesize delegate;

@end
