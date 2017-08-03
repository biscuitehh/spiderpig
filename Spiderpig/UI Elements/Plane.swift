//
//  Plane.swift
//  Don't Flinch
//
//  Created by Michael Thomas on 7/12/17.
//  Copyright © 2017 Biscuit Labs, LLC. All rights reserved.
//

/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 SceneKit node wrapper for plane geometry detected in AR.
 */

import Foundation
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var debugVisualization: PlaneDebugVisualization?
    
    init(_ anchor: ARPlaneAnchor, _ showDebugVisualization: Bool) {
        self.anchor = anchor
        
        super.init()
        
        self.showDebugVisualization(showDebugVisualization)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.anchor = anchor
        debugVisualization?.update(anchor)
    }
    
    func showDebugVisualization(_ show: Bool) {
        if show {
            if debugVisualization == nil {
                DispatchQueue.global().async {
                    self.debugVisualization = PlaneDebugVisualization(anchor: self.anchor)
                    DispatchQueue.main.async {
                        self.addChildNode(self.debugVisualization!)
                    }
                }
            }
        } else {
            debugVisualization?.removeFromParentNode()
            debugVisualization = nil
        }
    }

}
