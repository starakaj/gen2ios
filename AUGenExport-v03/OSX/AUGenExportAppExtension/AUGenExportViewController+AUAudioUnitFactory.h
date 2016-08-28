/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
 
	modified by Sam Tarakajian --- starakajian@gmail.com
	
	Abstract:
	`AUGenExportViewController` is the app extension's principal class, responsible for creating both the audio unit and its view.
*/

#import <CoreAudioKit/AUViewController.h>
#import "AUGenExportFramework.h"

@interface AUGenExportViewController (AUAudioUnitFactory) <AUAudioUnitFactory>

@end
