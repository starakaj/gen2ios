/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller which registers an AUAudioUnit subclass in-process for easy development, connects sliders and text fields to its parameters, and embeds the audio unit's view into a subview. Uses SimplePlayEngine to audition the effect.
*/

import UIKit
import AudioToolbox
import AUGenExportFramework

class ViewController: UIViewController {
    // MARK: Properties

	@IBOutlet var playButton: UIButton!

    /// Container for our custom view.
    @IBOutlet var auContainerView: UIView!

	/// The audio playback engine.
	var playEngine: SimplePlayEngine!

	/// The audio unit's filter cutoff frequency parameter object.
	var cutoffParameter: AUParameter!

	/// The audio unit's filter resonance parameter object.
	var resonanceParameter: AUParameter!

	/// A token for our registration to observe parameter value changes.
	var parameterObserverToken: AUParameterObserverToken!

	/// Our plug-in's custom view controller. We embed its view into `viewContainer`.
	var auGenExportViewController: AUGenExportViewController!

    // MARK: View Life Cycle
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set up the plug-in's custom view.
		embedPlugInView()
		
		// Create an audio file playback engine.
		playEngine = SimplePlayEngine(componentType: kAudioUnitType_Effect)
		
		/*
			Register the AU in-process for development/debugging.
			First, build an AudioComponentDescription matching the one in our 
            .appex's Info.plist.
		*/
        // MARK: AudioComponentDescription Important!
        // Ensure that you update the AudioComponentDescription for your AudioUnit type, manufacturer and creator type.
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x65787074 /*'fltr'*/
        componentDescription.componentManufacturer = 0x44656d6f /*'Demo'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
		
		/*
			Register our `AUAudioUnit` subclass, `AUv3FilterDemo`, to make it able 
            to be instantiated via its component description.
			
			Note that this registration is local to this process.
		*/
        AUAudioUnit.registerSubclass(AUv3GenExport.self, asComponentDescription: componentDescription, name:"Demo: Local AUGenExport Demo", version: UInt32.max)

		// Instantiate and insert our audio unit effect into the chain.
		playEngine.selectAudioUnitWithComponentDescription(componentDescription) {
			// This is an asynchronous callback when complete. Finish audio unit setup.
			self.connectParametersToControls()
		}
	}
	
	/// Called from `viewDidLoad(_:)` to embed the plug-in's view into the app's view.
	func embedPlugInView() {
        /*
			Locate the app extension's bundle, in the app bundle's PlugIns
			subdirectory. Load its MainInterface storyboard, and obtain the
            `FilterDemoViewController` from that.
        */
        let builtInPlugInsURL = NSBundle.mainBundle().builtInPlugInsURL!
        let pluginURL = builtInPlugInsURL.URLByAppendingPathComponent("AUGenExportAppExtension.appex")
		let appExtensionBundle = NSBundle(URL: pluginURL)

        let storyboard = UIStoryboard(name: "MainInterface", bundle: appExtensionBundle)
		auGenExportViewController = storyboard.instantiateInitialViewController() as! AUGenExportViewController
        
        // Present the view controller's view.
        if let view = auGenExportViewController.view {
            addChildViewController(auGenExportViewController)
            view.frame = auContainerView.bounds
            
            auContainerView.addSubview(view)
            auGenExportViewController.didMoveToParentViewController(self)
        }
	}
	
	/**
        Called after instantiating our audio unit, to find the AU's parameters and
        connect them to our controls.
    */
	func connectParametersToControls() { }


    // MARK: IBActions

	/// Handles Play/Stop button touches.
    @IBAction func togglePlay(sender: AnyObject?) {
		let isPlaying = playEngine.togglePlay()

        let titleText = isPlaying ? "Stop" : "Play"

		playButton.setTitle(titleText, forState: .Normal)
	}
}
