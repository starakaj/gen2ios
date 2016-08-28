/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller for the AUGenExport audio unit. Manages the interactions between an AUGenExportView and the audio unit's parameters.
*/

#ifndef AUGenExportViewController_h
#define AUGenExportViewController_h

#import <CoreAudioKit/AUViewController.h>

@class AUv3GenExport;

@interface AUGenExportViewController : AUViewController

@property (nonatomic)AUv3GenExport *audioUnit;

@end

#endif /* AUGenExportViewController_h */
