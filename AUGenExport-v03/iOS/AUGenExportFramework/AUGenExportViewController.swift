/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller for the AUGenExport audio unit. Manages the interactions between an AUGenExportView and the audio unit's parameters.
*/

import UIKit
import CoreAudioKit

public class AUGenExportViewController: AUViewController {
    // MARK: Properties

    @IBOutlet weak var auGenExportView: AUGenExportView!
	
    /*
		When this view controller is instantiated within the DemoApp, its
        audio unit is created independently, and passed to the view controller here.
	*/
    public var audioUnit: AUv3GenExport? {
        didSet {
			/*
				We may be on a dispatch worker queue processing an XPC request at 
                this time, and quite possibly the main queue is busy creating the 
                view. To be thread-safe, dispatch onto the main queue.
				
				It's also possible that we are already on the main queue, so to
                protect against deadlock in that case, dispatch asynchronously.
			*/
			dispatch_async(dispatch_get_main_queue()) {
				if self.isViewLoaded() {
					self.connectViewWithAU()
				}
			}
        }
    }

	public override func viewDidLoad() {
		super.viewDidLoad()
		
        guard audioUnit != nil else { return }

        connectViewWithAU()
	}
	
	/*
		We can't assume anything about whether the view or the AU is created first.
		This gets called when either is being created and the other has already 
        been created.
	*/
	func connectViewWithAU() {
		guard let paramTree = audioUnit?.parameterTree else { return }
	}
}