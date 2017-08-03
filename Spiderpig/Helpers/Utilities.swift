//
//  Utilities.swift
//  Spiderpig
//
//  Created by Michael Thomas on 7/12/17.
//  Copyright © 2017 Biscuit Labs, LLC. All rights reserved.
//

/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 Utility functions and type extensions used throughout the projects.
 */

import Foundation
import ARKit

// MARK: - SCNMaterial extensions

extension SCNMaterial {

    static func material(withDiffuse diffuse: Any?, respondsToLighting: Bool = true) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = diffuse
        material.isDoubleSided = true
        if respondsToLighting {
            material.locksAmbientWithDiffuse = true
        } else {
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = diffuse
        }
        return material
    }
}

// MARK: - Simple geometries

func createAxesNode(quiverLength: CGFloat, quiverThickness: CGFloat) -> SCNNode {
    let quiverThickness = (quiverLength / 50.0) * quiverThickness
    let chamferRadius = quiverThickness / 2.0

    let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
    xQuiverBox.materials = [SCNMaterial.material(withDiffuse: UIColor.red, respondsToLighting: false)]
    let xQuiverNode = SCNNode(geometry: xQuiverBox)
    xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)

    let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
    yQuiverBox.materials = [SCNMaterial.material(withDiffuse: UIColor.green, respondsToLighting: false)]
    let yQuiverNode = SCNNode(geometry: yQuiverBox)
    yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)

    let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
    zQuiverBox.materials = [SCNMaterial.material(withDiffuse: UIColor.blue, respondsToLighting: false)]
    let zQuiverNode = SCNNode(geometry: zQuiverBox)
    zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))

    let quiverNode = SCNNode()
    quiverNode.addChildNode(xQuiverNode)
    quiverNode.addChildNode(yQuiverNode)
    quiverNode.addChildNode(zQuiverNode)
    quiverNode.name = "Axes"
    return quiverNode
}

func createPlane(size: CGSize, contents: AnyObject?) -> SCNPlane {
    let plane = SCNPlane(width: size.width, height: size.height)
    plane.materials = [SCNMaterial.material(withDiffuse: contents)]
    return plane
}


