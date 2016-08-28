/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
 
	modified by Sam Tarakajian --- starakajian@gmail.com
	
	Abstract:
	View controller for the AUGenExport audio unit. Manages the interactions between an AUGenExport and the audio unit's parameters.
*/

#import <Cocoa/Cocoa.h>
#import <AUGenExportFramework/AUGenExport.h>
#import "AUGenExportViewController.h"
#import "AUGenExportViewController_Internal.h"
#import "AUGenExportView.h"

@interface AUGenExportViewController () <NSTableViewDelegate, NSTableViewDataSource> {
    __weak IBOutlet AUGenExportView  *auGenExportView;
	__weak IBOutlet NSTableView  *auGenExportParamView;
    AUParameterObserverToken parameterObserverToken;
	
	NSMutableArray<AUParameter *> *_parameters;
}

@end

@implementation AUGenExportViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    auGenExportView.delegate = self;
	_parameters = [NSMutableArray array];
    
    if (_audioUnit) {
        [self connectViewWithAU];
    }
    
    self.preferredContentSize = NSMakeSize(800, 500);
}

- (void)dealloc {
    auGenExportView.delegate = nil;
    [self disconnectViewWithAU];
}

#pragma mark-
- (AUv3GenExport *)getAudioUnit {
    return _audioUnit;
}

- (void)setAudioUnit:(AUv3GenExport *)audioUnit {
    _audioUnit = audioUnit;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isViewLoaded]) {
            [self connectViewWithAU];
        }
    });
}

#pragma mark-
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
    NSLog(@"AUGenExportViewControler allParameterValues key path changed: %s\n", keyPath.UTF8String);
    
    // Do nothing, because you don't have anything to change yet
}

- (void)updateViewForParameter:(AUParameter *)p {
	
}

- (void)connectViewWithAU {
    AUParameterTree *paramTree = _audioUnit.parameterTree;
    
    if (paramTree) {
		for (AUParameter *p in paramTree.allParameters) {
			[_parameters addObject:p];
		}
        
        // prevent retain cycle in parameter observer
        __weak AUGenExportViewController *weakSelf = self;
		__weak NSArray<AUParameter *> *weakParams = _parameters;
        parameterObserverToken = [paramTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
            __strong AUGenExportViewController *strongSelf = weakSelf;
			__strong NSArray<AUParameter *> *strongParams = weakParams;
			
			dispatch_async(dispatch_get_main_queue(), ^{
				for (AUParameter *p in strongParams) {
					if (address == p.address) {
						[strongSelf updateViewForParameter:p];
					}
				}
			});
        }];
		
        [_audioUnit addObserver:self forKeyPath:@"allParameterValues"
                            options:NSKeyValueObservingOptionNew
                            context:parameterObserverToken];
    } else {
        NSLog(@"paramTree is NULL!\n");
    }
	
	[auGenExportParamView reloadData];
}

- (void)disconnectViewWithAU {
	[_parameters removeAllObjects];
    if (parameterObserverToken) {
        [_audioUnit.parameterTree removeParameterObserver:parameterObserverToken];
        [_audioUnit removeObserver:self forKeyPath:@"allParameterValues" context:parameterObserverToken];
        parameterObserverToken = 0;
    }
}

#pragma mark NSTableViewDelegate

#pragma mark NSTableViewDataSource

- (NSInteger) numberOfRowsInTableView:(NSTableView *)view {
	return _parameters.count;
}

- (id) tableView:(NSTableView *)view objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier isEqualToString:@"paramName"]) {
		return [_parameters objectAtIndex:row].displayName;
	} else {
		return [NSString stringWithFormat:@"%.2f", [_parameters objectAtIndex:row].value];
	}
}

- (void) tableView:(NSTableView *)view setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([tableColumn.identifier isEqualToString:@"paramValue"]) {
		AUParameter *p = [_parameters objectAtIndex:row];
		p.value = [object floatValue];
	}
}

- (BOOL) tableView:(NSTableView *)view shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
	return [tableColumn.identifier isEqualToString:@"paramValue"];
}

@end
