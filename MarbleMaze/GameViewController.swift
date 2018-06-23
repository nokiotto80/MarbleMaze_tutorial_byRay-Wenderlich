import UIKit
import SceneKit

import CoreMotion



class GameViewController: UIViewController {
    
    var scnView:SCNView!
    var scnScene:SCNScene!
    
    var ballNode:SCNNode!
    var cameraNode:SCNNode!

    
    let CollisionCategoryBall = 1  //categories for collisions
    let CollisionCategoryStone = 2
    let CollisionCategoryPillar = 4
    let CollisionCategoryCrate = 8
    let CollisionCategoryPearl = 16
    
    var game = GameHelper.sharedInstance
    var motion = CoreMotionHelper() // “a simple way to poll the Core Motion engine for motion data at set intervals.”
      
    var motionForce = SCNVector3(x:0 , y:0, z:0)
    
    var cameraFollowNode:SCNNode!
    var lightFollowNode:SCNNode!
    
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
//        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        
        scnScene = SCNScene(named: "art.scnassets/game.scn")
        // 2 casting da view a scene
        scnView.scene = scnScene
    }
    
    func setupNodes() {
        ballNode = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        ballNode.physicsBody?.contactTestBitMask = CollisionCategoryPillar | CollisionCategoryCrate | CollisionCategoryPearl
        
        cameraNode = scnScene.rootNode.childNode(withName: "camera", //attach the cameraNode to the actual existing camera
        recursively: true)!
        // 2
        let constraint = SCNLookAtConstraint(target: ballNode)
        cameraNode.constraints = [constraint]
        constraint.isGimbalLockEnabled = true //blocks the camera horizontally to prevent unw. rotations “keep the camera aligned horizontally”
        
       // 1
        cameraFollowNode = scnScene.rootNode.childNode(
            withName: "follow_camera", recursively: true)!
        // 2
        cameraNode.addChildNode(game.hudNode)
        // 3
        lightFollowNode = scnScene.rootNode.childNode(
            withName: "follow_light", recursively: true)!
        
    }
    
    func setupSounds() {  //loads sounds into memory only
        game.loadSound(name: "GameOver", fileNamed: "GameOver.wav")
        game.loadSound(name: "Powerup", fileNamed: "Powerup.wav")
        game.loadSound(name: "Reset", fileNamed: "Reset.wav")
        game.loadSound(name: "Bump", fileNamed: "Bump.wav")
        
    }
    
    override var shouldAutorotate : Bool { return false }
    override var prefersStatusBarHidden : Bool { return true }
    
  func replenishLife() { //ripristina la "salute" della palla dopo che aveva perso luminaosita
        // 1
        let material = ballNode.geometry!.firstMaterial!
        // 2
        SCNTransaction.begin()   // Istruz alternative a SCNaction() per una sequenza di azioni
        SCNTransaction.animationDuration = 1.0
        // 3
        material.emission.intensity = 1.0
        // 4
        SCNTransaction.commit()
        // 5
        game.score += 1
        game.playSound(node: ballNode, name: "Powerup")
    }
    
//    function DUal to the precedent
 func diminishLife() {
        // 1
        let material = ballNode.geometry!.firstMaterial!
        // 2
        if material.emission.intensity > 0 {
            material.emission.intensity -= 0.001
        } else {
            resetGame()
        }
    }
    
 func updateCameraAndLights() {  //camera and light follow the ball, like a selfie sticky in a hand
        // 1
        let lerpX = (ballNode.presentation.position.x -
            cameraFollowNode.position.x) * 0.01
        let lerpY = (ballNode.presentation.position.y -
            cameraFollowNode.position.y) * 0.01
        let lerpZ = (ballNode.presentation.position.z -
            cameraFollowNode.position.z) * 0.01
        cameraFollowNode.position.x += lerpX
        cameraFollowNode.position.y += lerpY
        cameraFollowNode.position.z += lerpZ
        // 2
        lightFollowNode.position = cameraFollowNode.position
        // 3
        if game.state == GameStateType.tapToPlay {
            cameraFollowNode.eulerAngles.y += 0.005
        }  ////scnView.allowsCameraControl = true must be disabled
    }
    
    func updateHUD() {
        switch game.state {
        case .playing:
            game.updateHUD()
        case .gameOver:
            game.updateHUD(s: "-GAME OVER-")
        case .tapToPlay:
            game.updateHUD(s: "-TAP TO PLAY-")
        }
    }

//GAME functions of STATES

// 1
func playGame() {
    game.state = GameStateType.playing
    cameraFollowNode.eulerAngles.y = 0
    cameraFollowNode.position = SCNVector3Zero
    replenishLife()
}
// 2
func resetGame() {
    game.state = GameStateType.tapToPlay
    game.playSound(node: ballNode, name: "Reset")
    ballNode.physicsBody!.velocity = SCNVector3Zero
    ballNode.position = SCNVector3(x:0, y:10, z:0)
    cameraFollowNode.position = ballNode.position
    lightFollowNode.position = ballNode.position
    scnView.isPlaying = true
    game.reset()
}
// 3
func testForGameOver() {
    if ballNode.presentation.position.y < -5 {
        game.state = GameStateType.gameOver
        game.playSound(node: ballNode, name: "GameOver")
     
        
        
        var attesa: Double
        attesa = 30
        
      
        ballNode.runAction(SCNAction.wait(duration: attesa)) {  //by Adriano corrected
            self.resetGame()
        }
 
    }
}
    
//  wait for user touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == GameStateType.tapToPlay {
            playGame()
        }
    }
   
    func updateMotionControl() {
        // 1
        if game.state == GameStateType.playing {
            motion.getAccelerometerData(interval: 0.1) { (x,y,z) in
                self.motionForce = SCNVector3(x: Float(x) * 0.05, y:0,
                                              z: Float(y+0.8) * -0.05)
            }
            // 2
            ballNode.physicsBody!.velocity = vector3Sum.sum3(left: ballNode.physicsBody!.velocity, right: motionForce)
//
        }
    }
}
// 3
extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer,  //“ stub called on every frame update (60 fr/sec)
                  updateAtTime time: TimeInterval) {
        updateMotionControl()
        updateCameraAndLights()
        updateHUD()
        
        if game.state == GameStateType.playing { //controllar SEMPRE
            testForGameOver()                //se la palla non cade e
            diminishLife()
        }
    }
}

extension GameViewController : SCNPhysicsContactDelegate { // “code that will handle the actual collision events.”
    
    
    func physicsWorld(_ world: SCNPhysicsWorld,
                      didBegin contact: SCNPhysicsContact) {
        // 1
        var contactNode:SCNNode!
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        // 2
        if contactNode.physicsBody?.categoryBitMask ==
            CollisionCategoryPearl {
            contactNode.isHidden = true
            
            replenishLife()  //se veniamo in contatt con una perla ,il colore si ravviva
            
    
            var attesa: Double
            attesa = 30
            
            contactNode.isHidden = true
            scnScene.rootNode.runAction(SCNAction.wait(duration: attesa)) {  //by Adriano corrected
                contactNode.isHidden = false
            }
      
//            contactNode.runAction(
//                SCNAction.waitForDurationThenRunBlock(
//                duration: 30) { (node:SCNNode!) -> Void in
//                    node.isHidden = false
//            })
        }
        
        // 3
        if contactNode.physicsBody?.categoryBitMask ==
            CollisionCategoryPillar ||
            contactNode.physicsBody?.categoryBitMask ==
            CollisionCategoryCrate {
            
            game.playSound(node: ballNode, name: "Bump")
    }
}
}
