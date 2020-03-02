//
//  ViewController.swift
//  AR Drawing
//
//  Created by Gene Mecija on 3/9/18.
//  Copyright © 2018 Gene Mecija. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    
    // Tracks position/orientation of device at all times.
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Running the session configuration in the sceneView.
        self.sceneView.session.run(configuration)
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.sceneView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var currentColor:UIColor = UIColor.red
    @IBAction func redButton(_ sender: Any) {
        currentColor = UIColor.red
    }
    @IBAction func blueButton(_ sender: Any) {
        currentColor = UIColor.blue
    }

    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // Tracking point of view of camera
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        // Orientation refers to how the phone is oriented (facing down, upside down, etc)
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        
        // Location refers to phones position in relation to sceneView
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let currentCameraPosition = orientation + location
        
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentCameraPosition
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = self.currentColor
                
            } else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                pointer.position = currentCameraPosition
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                    node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
                // pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
            
        }
    }
    
    @IBAction func resetButton(_ sender: Any) {
        reset()
    }
        
    func reset() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes{(node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options:[.resetTracking, .removeExistingAnchors])
    }

}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
