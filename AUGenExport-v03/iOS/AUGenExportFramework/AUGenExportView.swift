/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View for the AUGenExport audio unit. It doesn't do anything.
*/

import UIKit

class AUGenExportView: UIView {
    
    var containerLayer = CALayer()
    
    override func awakeFromNib() {
        let scale = UIScreen.mainScreen().scale
        
        containerLayer.name = "container"
        containerLayer.anchorPoint = CGPoint.zero
        containerLayer.frame = CGRect(origin: CGPoint.zero, size: layer.bounds.size)
        containerLayer.bounds = containerLayer.frame
        containerLayer.contentsScale = scale
		containerLayer.backgroundColor = UIColor.blueColor().CGColor;
        layer.addSublayer(containerLayer)

        layer.contentsScale = scale
    }
	
	override func layoutSublayersOfLayer(layer: CALayer) {        
        if layer === self.layer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            containerLayer.bounds = layer.bounds
			
            CATransaction.commit()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		NSLog("Touch Down");
    }
}