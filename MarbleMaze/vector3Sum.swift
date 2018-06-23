//
//  vector3Sum.swift
//  MarbleMaze
//
//  Created by Vincenzo Pugliese on 23/06/2018.
//  Copyright © 2018 Vincenzo Pugliese. All rights reserved.
//

import UIKit
import SceneKit

class vector3Sum {

    static func sum3 (left: SCNVector3, right: SCNVector3) -> SCNVector3 { //per sommare 2 vettori SCNVector3
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)

    }
}
