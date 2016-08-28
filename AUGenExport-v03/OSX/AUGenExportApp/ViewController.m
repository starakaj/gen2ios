/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller which registers an AUAudioUnit subclass in-process for easy development, connects sliders and text fields to its parameters, and embeds the audio unit's view into a subview. Uses SimplePlayEngine to audition the effect.
*/

#import "ViewController.h"
#import "AppDelegate.h"

#import "AUGenExportFramework.h"
#import "AUGenExportDemo-Swift.h"
#import <CoreAudioKit/AUViewController.h>
#import "AUGenExportViewController.h"

static int version = 0;

@interface ViewController () {
    IBOutlet NSButton *playButton;
    
    AUGenExportViewController *auV3ViewController;
	NSDocument *appexDocument;
    
    SimplePlayEngine *playEngine;
    
    AUParameterObserverToken parameterObserverToken;
    NSArray<AUAudioUnitPreset *> *factoryPresets;
}
@property (weak) IBOutlet NSView *containerView;

-(IBAction)togglePlay:(id)sender;

-(void)handleMenuSelection:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self startAppexDocumentWatcher];
	
//	NSURL *builtInPlugInURL = [[NSBundle mainBundle] builtInPlugInsURL];
//	NSURL *pluginURL = [builtInPlugInURL URLByAppendingPathComponent: @"AUGenExportAppExtension.appex"];
	NSURL *pluginURL = [NSURL fileURLWithPath:APPEX_DOC_PATH];
	NSBundle *appExtensionBundle = [NSBundle bundleWithURL: pluginURL];
	NSString* plistPath = [appExtensionBundle pathForResource:@"info" ofType:@"plist"];
	NSDictionary *contentArray = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [self embedPlugInAtURL:pluginURL];
    
    AudioComponentDescription desc;
    /*  Supply the correct AudioComponentDescription based on your AudioUnit type, manufacturer and creator.
     
        You need to supply matching settings in the AUAppExtension info.plist under:
         
        NSExtension
            NSExtensionAttributes
                AudioComponents
                    Item 0
                        type
                        subtype
                        manufacturer
         
         If you do not do this step, your AudioUnit will not work!!!
     */
    // MARK: AudioComponentDescription Important!
    // Ensure that you update the AudioComponentDescription for your AudioUnit type, manufacturer and creator type.
    desc.componentType = 'aufx';
    desc.componentSubType = 'fltr';
    desc.componentManufacturer = 'Demo';
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
//    [AUAudioUnit registerSubclass: AUv3GenExport.class
//           asComponentDescription: desc
//                             name: @"Demo: Local AUv3"
//                          version: ++version];
	
    playEngine = [[SimplePlayEngine alloc] initWithComponentType: desc.componentType componentsFoundCallback: nil];
    [playEngine selectAudioUnitWithComponentDescription2:desc completionHandler:^{
        [self connectParametersToControls];
    }];

    [self populatePresetMenu];
}

#pragma mark -

- (void)startAppexDocumentWatcher {
	NSURL *appexDocURL = [NSURL fileURLWithPath:APPEX_DOC_PATH];
	
	const char *path = [APPEX_DOC_PATH cStringUsingEncoding:NSUTF8StringEncoding];
	int fdes = open(path, O_RDONLY);
	dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
	void (^eventHandler)(void), (^cancelHandler)(void);
	unsigned long mask = DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE;
	__block dispatch_source_t source;
		
	eventHandler = ^{
	  unsigned long l = dispatch_source_get_data(source);
	  if (l & DISPATCH_VNODE_DELETE) {
		  printf("watched file deleted!  cancelling source\n");
		  dispatch_source_cancel(source);
	  }
	  else {
		  
		  printf("watched file has data\n");
		  dispatch_async(dispatch_get_main_queue(), ^{
			  
			  // TODO: Figure out whether capturing self here is evil somehow
			  [self embedPlugInAtURL:appexDocURL];
			  [self selectNewAudioUnit];
		  });
	  }
	};
	cancelHandler = ^{
	  int fdes = (int) dispatch_source_get_handle(source);
	  close(fdes);
	  // Wait for new file to exist.
	  while ((fdes = open(path, O_RDONLY)) == -1)
		  sleep(1);
	  printf("re-opened target file in cancel handler\n");
	  source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fdes, mask, queue);
	  dispatch_source_set_event_handler(source, eventHandler);
	  dispatch_source_set_cancel_handler(source, cancelHandler);
	  dispatch_resume(source);
	};
	
	source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fdes, mask, queue);
	dispatch_source_set_event_handler(source, eventHandler);
	dispatch_source_set_cancel_handler(source, cancelHandler);
	dispatch_resume(source);
}

- (void)embedPlugInAtURL:(NSURL *)pluginURL {
    NSBundle *appExtensionBundle = [NSBundle bundleWithURL: pluginURL];
    
    auV3ViewController = [[AUGenExportViewController alloc] initWithNibName: @"AUGenExportViewController"
                                                                    bundle: appExtensionBundle];
    
    NSView *view = auV3ViewController.view;
    view.frame = _containerView.bounds;
	
	if (_containerView.subviews.count > 0) {
		[_containerView replaceSubview:_containerView.subviews[0] with:view];
		view.translatesAutoresizingMaskIntoConstraints = NO;
		
		NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[view]-|"
																	   options:0 metrics:nil
																		 views:NSDictionaryOfVariableBindings(view)];
		[_containerView addConstraints: constraints];
		
		constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[view]-|"
															  options:0 metrics:nil
																views:NSDictionaryOfVariableBindings(view)];
		[_containerView addConstraints: constraints];
	} else {
		[_containerView addSubview: view];
		view.translatesAutoresizingMaskIntoConstraints = NO;
		
		NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[view]-|"
																	   options:0 metrics:nil
																		 views:NSDictionaryOfVariableBindings(view)];
		[_containerView addConstraints: constraints];
		
		constraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-[view]-|"
															  options:0 metrics:nil
																views:NSDictionaryOfVariableBindings(view)];
		[_containerView addConstraints: constraints];
	}
}

- (void)selectNewAudioUnit {
//	u_int32_t rando = arc4random();
	AudioComponentDescription desc;
	desc.componentType = 'aufx';
	desc.componentSubType = 'fltr';
	desc.componentManufacturer = 'Demo';
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	
//	[AUAudioUnit registerSubclass: AUv3GenExport.class
//		   asComponentDescription: desc
//							 name: [NSString stringWithFormat:@"Demo: Local AUv3"]
//						  version: UINT32_MAX];
	
	[playEngine selectAudioUnitWithComponentDescription2:desc completionHandler:^{
		[self connectParametersToControls];
	}];
	
	[self populatePresetMenu];
}

-(void) connectParametersToControls {
    AUParameterTree *parameterTree = playEngine.testAudioUnit.parameterTree;
	
    auV3ViewController.audioUnit = (AUv3GenExport *)playEngine.testAudioUnit;
    
    __weak ViewController *weakSelf = self;
    parameterObserverToken = [parameterTree tokenByAddingParameterObserver:^(AUParameterAddress address, AUValue value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong ViewController *strongSelf = weakSelf;
        });
    }];
}

#pragma mark-
#pragma mark: <NSWindowDelegate>

- (void)windowWillClose:(NSNotification *)notification {
    // Main applicaiton window closing, we're done
    [playEngine stopPlaying];
    [playEngine.testAudioUnit.parameterTree removeParameterObserver:parameterObserverToken];
    
    playEngine = nil;
    auV3ViewController = nil;
}

#pragma mark-
#pragma mark: Actions

-(IBAction)togglePlay:(id)sender {
    BOOL isPlaying = [playEngine togglePlay];
    
    [playButton setTitle: isPlaying ? @"Stop" : @"Play"];
}

#pragma mark-
#pragma mark Application Preset Menu

-(void)populatePresetMenu {
    NSApplication *app = [NSApplication sharedApplication];
    NSMenu *presetMenu = [[app.mainMenu itemWithTag:666] submenu];
	if (presetMenu == nil)
		return;
    
    factoryPresets = auV3ViewController.audioUnit.factoryPresets;
    
    for (AUAudioUnitPreset *thePreset in factoryPresets) {
        NSString *keyEquivalent = @"";
        
        if (thePreset.number <= 10) {
            long keyValue = ((thePreset.number < 10) ? (long)(thePreset.number + 1) : 0);
            keyEquivalent =[NSString stringWithFormat: @"%ld", keyValue];
        }
        
        NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:thePreset.name
                                                         action:@selector(handleMenuSelection:)
                                                  keyEquivalent:keyEquivalent];
        newItem.tag = thePreset.number;
        [presetMenu addItem:newItem];
    }
    
    AUAudioUnitPreset *currentPreset = auV3ViewController.audioUnit.currentPreset;
    [presetMenu itemAtIndex: currentPreset.number].state = NSOnState;
}

-(void)handleMenuSelection:(NSMenuItem *)sender {
    
    for (NSMenuItem *menuItem in [sender.menu itemArray]) {
        menuItem.state = NSOffState;
    }
    
    sender.state = NSOnState;
    auV3ViewController.audioUnit.currentPreset = [factoryPresets objectAtIndex:sender.tag];
}

@end