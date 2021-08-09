//
//  TitleScene.swift
//  SpaceShooter
//
//  Created by Александр Морозов on 09.08.2021.
//

import Foundation
import SpriteKit

var buttonPlay: UIButton!
var gameTitle: UILabel!
var ship = SKSpriteNode()

class TitleScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = offBlackColor
        
        leadShip()
        setUpText()
    }
    
    func leadShip() {
        ship = SKSpriteNode(imageNamed: "ship")
        ship.size = CGSize(width: 180, height: 180)
        ship.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(ship)
    }
    
    func setUpText() {
        let buttonMargin = CGFloat(50)
        let buttonSize = CGSize(width: 300, height: 100)
        
        buttonPlay = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height))
        
        buttonPlay.center = CGPoint(x: (view?.bounds.size.width)! / 2, y: ((view?.bounds.size.height)!) - buttonSize.height / 2 - buttonMargin)
        
        buttonPlay.titleLabel?.font = UIFont(name: "Futura", size: 40)
        buttonPlay.setTitle("PLAY", for: .normal)
        buttonPlay.setTitleColor(orangeCustorColor, for: .normal)
        buttonPlay.setTitleShadowColor(offBlackColor, for: .normal)
        
        buttonPlay.addTarget(self, action: #selector(playGame), for: .touchUpInside)
        self.view?.addSubview(buttonPlay)
        //Title
        
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: (view?.frame.width)!, height: 300))
        gameTitle.textColor = offWhiteColor
        gameTitle.font = UIFont(name: "Futura", size: 24)
        gameTitle.textAlignment = .center
        gameTitle.text = "SPACE SHOOTER"
        self.view?.addSubview(gameTitle)
    }
    
    @objc func playGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.doorway(withDuration: 0.4))
        buttonPlay.removeFromSuperview()
        gameTitle.removeFromSuperview()
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFit
            skView.presentScene(scene)
        }
    }
}
