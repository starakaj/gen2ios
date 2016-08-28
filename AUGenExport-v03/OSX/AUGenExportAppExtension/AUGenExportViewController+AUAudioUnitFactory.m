/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	`AUGenExportViewController` is the app extension's principal class, responsible for creating both the audio unit and its view.
*/

#import "AUGenExportViewController+AUAudioUnitFactory.h"

@implementation AUGenExportViewController (AUAudioUnitFactory)

- (AUv3GenExport *) createAudioUnitWithComponentDescription:(AudioComponentDescription) desc error:(NSError **)error {
    self.audioUnit = [[AUv3GenExport alloc] initWithComponentDescription:desc error:error];
    return self.audioUnit;
}

@end
