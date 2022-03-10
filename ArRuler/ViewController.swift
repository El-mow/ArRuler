//
//  ViewController.swift
//  ArRuler
//
//  Created by mobin on 3/7/22.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var nodes:[SCNNode] = []
    let textNode = SCNNode ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
        

    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocations = touches.first?.location(in: sceneView){
            let hitTestResult = sceneView.hitTest(touchLocations, types: .featurePoint)
            
            if let hitResult = hitTestResult.first {
                if nodes.count >= 2 {
                    nodes.map{
                        $0.removeFromParentNode()
                    }
                }
                addDot(at: hitResult)

            }
            
        }
        
        
            
    }
    
    func addDot(at hitResult:ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents =  UIColor.green
        dotGeometry.materials  = [material]
        let ScnNode = SCNNode(geometry: dotGeometry)
        ScnNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(ScnNode)
        nodes.append(ScnNode)
        
        
        if nodes.count == 2 {
            print(nodes[1].position.x - nodes[0].position.x )
            print(nodes[1].position.y - nodes[0].position.y )
            print(nodes[1].position.y - nodes[0].position.z )

            let line = SCNGeometry.line(from: nodes[0].position, to: nodes[1].position)
            let lineNode = SCNNode(geometry: line)
            lineNode.position = SCNVector3Zero
            sceneView.scene.rootNode.addChildNode(lineNode)
            updateText(text: String(calculateDistance(spotNo1: nodes[0], spotNo2: nodes[1])) , position:nodes[0])
        }
        
        
        
        
    }
    
    func calculateDistance(spotNo1 :SCNNode , spotNo2 : SCNNode ) -> Float{
        return abs(sqrt(pow((spotNo2.position.x) - (spotNo1.position.x), 2) + pow((spotNo2.position.y) - (spotNo1.position.y), 2) +
                    pow((spotNo2.position.z) - (spotNo1.position.z), 2)))
    }
    
    func updateText(text : String , position : SCNNode){
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.position.x, position.position.y, position.position.z)
        textNode.scale = SCNVector3(0.1 , 0.1 , 0.1)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}
extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType:.line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
