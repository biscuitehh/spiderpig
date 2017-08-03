//
//  ViewController.swift
//  Spiderpig
//
//  Created by Michael Thomas on 7/26/17.
//  Copyright © 2017 Biscuit Labs, LLC. All rights reserved.
//

import UIKit
import SceneKit
import FLEX
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var imageSensor: ARImageSensor?
    var planes = [ARPlaneAnchor: Plane]()

    // Property flags
    var enabledAutofocus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debugging Tools
        FLEXManager.shared().showExplorer()
        UserDefaults.swizzle()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup ARSession & get the ball rolling
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.relocalizationEnabled = false
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.removePlane(anchor: planeAnchor)
            }
        }
    }
    
    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // TODO: See if we can get the ARImageSensor before this point
        if let sensor = self.imageSensor,
            let device = sensor.captureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                print("Failure to lock initial device configuration")
                return
            }
            
            device.unlockForConfiguration()
        }
        
        if self.enabledAutofocus {
            return
        }
        
        guard let sensors = session.availableSensors() else {
            return
        }
        
        self.enabledAutofocus = true
        
        for sensor in sensors {
            if let sensor = sensor as? ARImageSensor {
                if let device = sensor.captureDevice {
                    do {
                        try device.lockForConfiguration()
                    } catch {
                        print("Whoops!")
                    }
                    
                    // Play with camera options via ARImageSensor
                    sensor.autoFocusEnabled = true
                    sensor.configureCaptureDevice()
                    sensor._configureCameraExposure(for: device)

                    // You can also directly access the AVCaptureDevice/AVCaptureSession here
                    device.focusMode = .continuousAutoFocus
                    
                    // Unlock the device once we're finished with it
                    device.unlockForConfiguration()
                    
                    self.imageSensor = sensor
                }
            }
        }
    }

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print(camera.trackingState)
    }

    // MARK: - Plane Management

    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor, true)
        
        planes[anchor] = plane
        node.addChildNode(plane)
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    
}

// MARK: - Swizzle UserDefaults to hunt for AR Keys

extension UserDefaults {
    
    static func swizzle() {
        _ = _swizzle
    }
    
    static let _swizzle: Void = {
        // Start with read methods
        UserDefaults.ud_swizzle(#selector(UserDefaults.value(forKey:)), with: #selector(UserDefaults.ud_value(forKey:)))
        UserDefaults.ud_swizzle(#selector(UserDefaults.value(forKeyPath:)), with: #selector(UserDefaults.ud_value(forKeyPath:)))
        UserDefaults.ud_swizzle(#selector(UserDefaults.object(forKey:)), with: #selector(UserDefaults.ud_object(forKey:)))
    }()
    
    static func ud_swizzle(_ original: Selector, with swizzled: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, original),
            let swizzledMethod = class_getInstanceMethod(self, swizzled) else {
            return
        }
        
        let didAddMethod = class_addMethod(self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // MARK: Listen closely ...
    
    @objc func ud_value(forKey key: String) -> Any? {
        print("value(forKey:) - Key: \(key)")
        let value = self.ud_value(forKey: key)
        print("value(forKey:) - Value: \(value ?? "nil")")
        return value
    }
    
    @objc func ud_value(forKeyPath keyPath: String) -> Any? {
        print("value(forKeyPath:) - Key: \(keyPath)")
        let value = self.ud_value(forKeyPath: keyPath)
        print("value(forKeyPath:) - Value: \(value ?? "nil")")
        return value
    }
    
    @objc func ud_object(forKey key: String) -> Any? {
        print("object(forKey:) - Key: \(key)")
        let value = self.ud_object(forKey: key)
        print("object(forKey:) - Value: \(value ?? "nil")")
        return value
    }
    
}
