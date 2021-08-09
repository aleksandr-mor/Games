//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Александр Морозов on 07.08.2021.
//

import SpriteKit
import GameplayKit


var player = SKSpriteNode()
var projecTile = SKSpriteNode()
var enemy = SKSpriteNode()
var star = SKSpriteNode()

var scoreLabel = SKLabelNode()
var mainLabel = SKLabelNode()

var playerSize = CGSize(width: 140, height: 140)
var projecTileSize = CGSize(width: 24, height: 24)
var enemySize = CGSize(width: 140, height: 140)
var starSize = CGSize()

var offBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
var offWhiteColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
var orangeCustorColor = UIColor.orange

var projecTileRate = 0.2
var projecTileSpeed = 0.9

var enemySpeed = 2.1
var enemySpawnRate = 0.6

var isAlive = true
var score = 0

var touchLocation = CGPoint()

struct physicsCategory {
    static let player: UInt32 = 0
    static let projecTile: UInt32 = 1
    static let enemy: UInt32 = 2
}




class GameScene: SKScene, SKPhysicsContactDelegate {

    override func didMove(to view: SKView) {
        self.backgroundColor = offBlackColor
        physicsWorld.contactDelegate = self
        
        resetGameVariableOnStart()
        
        leadPlayer()
        spawnMainLabel()
        spawnScoreLabel()
        fireprojecTile()
        timerSpawnEnemies()
        timerStarSpawn()
    
    }
    
    func leadPlayer() {
        player = SKSpriteNode(imageNamed: "ship")
        player.size = playerSize
        player.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 250)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false
        player.name = "playerName"
        self.addChild(player)
    }
    func resetGameVariableOnStart() {
        isAlive = true
        score = 0
    }
    
    func leadprojecTile() {
        projecTile = SKSpriteNode(imageNamed: "projectile")
        projecTile.size = projecTileSize
        projecTile.position = CGPoint(x: player.position.x, y: player.position.y)
        
        projecTile.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        projecTile.physicsBody?.affectedByGravity = false
        projecTile.physicsBody?.categoryBitMask = physicsCategory.projecTile
        projecTile.physicsBody?.contactTestBitMask = physicsCategory.enemy
        projecTile.physicsBody?.allowsRotation = false
        projecTile.physicsBody?.isDynamic = true
        projecTile.name = "projecTileName"
        projecTile.zPosition = -1
        
        moveProjecTileToTop()
        
        self.addChild(projecTile)
    }

    func moveProjecTileToTop() {
        let moveForward = SKAction.moveTo(y: 600, duration: projecTileSpeed)
        let destroy = SKAction.removeFromParent()
        
        projecTile.run(SKAction.sequence([moveForward, destroy]))
    }
    
    func spawnEnemy() {
        enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = enemySize
        let xPos = randombetweenNumbers(firstNum: 0, secondNum: frame.width)
        enemy.position = CGPoint(x: xPos - 500, y: self.frame.size.height/2)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = physicsCategory.projecTile
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.isDynamic = true
        enemy.name = "enemyName"
        
        moveEnemyToFloor()
        self.addChild(enemy)
    }
    
    func randombetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func moveEnemyToFloor() {
        let moveTo = SKAction.moveTo(y: -600, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([moveTo, destroy]))
    }
    
    func spawnStars() {
        let randomSize = Int(arc4random_uniform(12) + 12)
        starSize = CGSize(width: randomSize, height: randomSize)
        star = SKSpriteNode(imageNamed: "bokeh")
        star.size = starSize
        
        let xPos = randombetweenNumbers(firstNum: 0, secondNum: frame.width)
        star.position = CGPoint(x: CGFloat(xPos - 500), y: self.frame.size.height/2)
        
        startsMove()
        self.addChild(star)
        
    }
    
    func startsMove() {
        let randdomTime = Int(arc4random_uniform(10))
        let doubelRandomTime: Double = Double((randdomTime) / 10) + 1
        
        let moveTo = SKAction.moveTo(y: -600, duration: doubelRandomTime)
        let destroy = SKAction.removeFromParent()
        
        star.run(SKAction.sequence([moveTo, destroy]))
        
    }
    
    func spawnMainLabel() {
        mainLabel = SKLabelNode(fontNamed: "futura")
        mainLabel.fontSize = 80
        mainLabel.fontColor = offWhiteColor
        mainLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 600)
        mainLabel.text = "START"
        self.addChild(mainLabel)
    
    }
    
    func spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "futura")
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = offWhiteColor
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 130)
        scoreLabel.text = "Score: \(score)"
        self.addChild(scoreLabel)
    }
    func fireprojecTile() {
        let timer = SKAction.wait(forDuration: projecTileRate)
        let spawn = SKAction.run {
            self.leadprojecTile()
        }
        
        let sequence = SKAction.sequence([timer, spawn])
        self.run(SKAction.repeatForever(sequence))
        
    }
    
    func timerSpawnEnemies () {
        let wait = SKAction.wait(forDuration: enemySpawnRate)
        let spawn = SKAction.run {
            self.spawnEnemy()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
        
    }
    
    func timerStarSpawn() {
        let wait = SKAction.wait(forDuration: 0.2)
        let spawn = SKAction.run {
            if isAlive == true {
                self.spawnStars()
                self.spawnStars()
                self.spawnStars()
            }
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.projecTile) || (firstBody.categoryBitMask == physicsCategory.projecTile) && (secondBody.categoryBitMask == physicsCategory.enemy) {
            //
            spawnExplosion(bodyTemp: firstBody.node as! SKSpriteNode)
            enemyProjecTileCollision(contactA: firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
        }
        
        if (firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.player) || (firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy) {
            //
            playerEnemyCollision(contactA: firstBody.node as! SKSpriteNode, contactB: secondBody.node as! SKSpriteNode)
        }
    }
    
    func enemyProjecTileCollision(contactA: SKSpriteNode, contactB: SKSpriteNode) {
        if contactA.name == "enemyName" && contactB.name == "projecTileName" {
            score = score + 1
            
            let destroy = SKAction.removeFromParent()
            
            contactA.run(SKAction.sequence([destroy]))
            contactB.removeFromParent()
            updateScore()
            
        }
        
        if contactA.name == "enemyName" && contactB.name == "projecTileName" {
            score = score + 1
            
            let destroy = SKAction.removeFromParent()
            
            contactA.run(SKAction.sequence([destroy]))
            contactB.removeFromParent()
            updateScore()
        }
    }
    
        func playerEnemyCollision(contactA: SKSpriteNode, contactB: SKSpriteNode) {
           
            if contactA.name == "enemyName" && contactB.name == "playerName" {
                isAlive = false
                gameOverLogic()
            }
            
            if contactA.name == "enemyName" && contactB.name == "playerName" {
                isAlive = false
                gameOverLogic()
            }
        }
        
        func gameOverLogic() {
            mainLabel.fontSize = 60
            mainLabel.text = "GAME OVER!"
            
            resetTheGame()
        }
        
    func updateScore() {
        scoreLabel.text = "Score: \(score)"
    }
    
        func spawnExplosion(bodyTemp: SKSpriteNode) {
            let explosionEmitterPath = Bundle.main.path(forResource: "explosionParticle", ofType: "sks")
            let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath! as String) as! SKEmitterNode
            explosion.position = CGPoint(x: bodyTemp.position.x, y: bodyTemp.position.y)
            explosion.zPosition = 1
            explosion.targetNode = self
            self.addChild(explosion)
            
            let wait = SKAction.wait(forDuration: 0.5)
            let removeExplosion = SKAction.run {
                explosion.removeFromParent()
            }
            
            self.run(SKAction.sequence([wait, removeExplosion]))
        }
    
    func resetTheGame() {
        let wait = SKAction.wait(forDuration: 3.0)
        let titleScene = TitleScene(fileNamed: "TitleScene")
        titleScene?.scaleMode = SKSceneScaleMode.aspectFill
        let transition = SKTransition.doorway(withDuration: 0.4)
        
        let changeScene = SKAction.run {
            self.scene!.view?.presentScene(titleScene!, transition: transition)
        }
        
        let sequence = SKAction.sequence([wait, changeScene])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func movePlayerOffScreen() {
        projecTile.removeFromParent()
        spawnExplosion(bodyTemp: player)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isAlive == false {
            movePlayerOffScreen()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
       
        }
    
    
    func touchMoved(toPoint pos : CGPoint) {
       
        }
    
    func touchUp(atPoint pos : CGPoint) {
      
        }
    
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: player)
        }
    }

    func movePlayerOnTouch() {
        player.position.x = (touchLocation.x)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: player)
            movePlayerOnTouch()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
