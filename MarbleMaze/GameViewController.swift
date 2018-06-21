import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var scnView:SCNView!
    var scnScene:SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    // 2
    func setupScene() {
        scnView = self.view as! SCNView
        scnView.delegate = self   //collegato con Extension gvC: SCNSCeneRenderDelegate
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        
        scnScene = SCNScene(named: "art.scnassets/game.scn")
        // 2 casting da view a scene
        scnView.scene = scnScene
    }
    
    func setupNodes() {
    }
    
    func setupSounds() {
    }
    
    override var shouldAutorotate : Bool { return false }
    override var prefersStatusBarHidden : Bool { return true }
}

// 3
extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer,  //“ stub that is called on every frame update.
                  updateAtTime time: TimeInterval) {
    }
}
