//
//  GameScene.swift
//  Breakout
//
//  Created by Reagan W. Davenport on 3/13/17.
//  Copyright © 2017 Reagan W. Davenport. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var label : SKLabelNode!
    var lives : Int = 0
    var livesLabel : SKLabelNode!
    var level : Int = 0
    
    override func didMove(to view: SKView)
    {
        startButton()
        makePaddle()
        makeLoseZone()
        createLivesLabel()
        createBackground()
        reset()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            if label.contains(location) && label.name == "start"
            {
                label.alpha = 0
                ball.physicsBody?.isDynamic = true
                ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 3))
                label.name = "default"
            }
            if label.contains(location) && label.name == "restart"
            {
                reset()
            }
            paddle.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            paddle.position.x = location.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if contact.bodyA.node!.name == "brick" || contact.bodyB.node!.name == "brick"
        {
            if contact.bodyA.node!.name == "brick"
            {
                let node = contact.bodyA.node
                for (index, entry) in bricks.enumerated()
                {
                    if entry.isEqual(to: node!)
                    {
                        contact.bodyA.node!.removeFromParent()
                        bricks.remove(at: index)
                    }
                }
            }
            if contact.bodyB.node!.name == "brick"
            {
                let node = contact.bodyB.node
                for (index, entry) in bricks.enumerated()
                {
                    if entry.isEqual(to: node!)
                    {
                        contact.bodyB.node!.removeFromParent()
                        bricks.remove(at: index)
                    }
                }
            }
            if bricks.count == 0
            {
                ball.removeFromParent()
                level = level + 1
                winner()
            }
        }
        if contact.bodyA.node?.name == "loseZone" || contact.bodyB.node?.name == "loseZone"
        {
            ball.removeFromParent()
            lives = lives - 1
            updateLives()
            if(lives == 0)
            {
                label.text = "Game Over"
                label.name = "restart"
                label.alpha = 1
                return
            }
            makeBall()
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 3))
        }
    }
    
    func createBackground()
    {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1
        {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall()
    {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        //physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        //ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        //use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        //no loss of energy from friction
        ball.physicsBody?.friction = 0
        //gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        //bounces full off of other objects
        ball.physicsBody?.restitution = 1
        //does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) //add ball object to the view
    }
    
    func makePaddle()
    {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width / 4, height: frame.height / 25))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick()
    {
        let brick : SKSpriteNode!
        brick = SKSpriteNode(color: UIColor.blue, size: CGSize(width: frame.width / 5, height: frame.height / 25))
        brick.position = CGPoint(x: frame.midX, y: frame.maxY - 30)
        brick.name = "brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
    }
    
    func makeBricks(lvl : Int)
    {
        let xInt = (Int)(frame.maxX / 5)
        let yInt = (Int)(frame.height / 25)
        for i in 0 ... 4
        {
            for j in 0 ... 4
            {
                let brick = SKSpriteNode(color: UIColor.blue, size: CGSize(width: Int(1.75 * Double(xInt)), height: (Int)(yInt - 5)))
                brick.position = CGPoint(x: Int(frame.minX) + 2 * xInt * j + xInt, y: (Int)(frame.maxY) - 30 * i - yInt / 2)
                brick.name = "brick"
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
                brick.physicsBody?.isDynamic = false
                addChild(brick)
                bricks.append(brick)
            }
        }
    }
    
    func makeLoseZone()
    {
        let loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    func startButton()
    {
        label = SKLabelNode(fontNamed: "Marker Felt")
        label.fontColor = UIColor.red
        label.text = "Press to Start"
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        label.name = "start"
        addChild(label)
    }
    
    func createLivesLabel()
    {
        livesLabel = SKLabelNode(fontNamed: "Marker Felt")
        livesLabel.fontColor = UIColor.blue
        livesLabel.text = ""
        livesLabel.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.minY + 25)
        livesLabel.fontSize = 18
        addChild(livesLabel)
    }
    
    func updateLives()
    {
        livesLabel.text = "Lives: \(lives)"
    }
    
    func reset()
    {
        lives = 3
        level = 0
        updateLives()
        makeBall()
        makeBricks(lvl: level)
        labelToStart()
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func winner()
    {
        if(level > 0)
        {
            label.text = "You Beat All the Levels! Congrats!"
            label.alpha = 1
            label.name = "restart"
        }
        else
        {
            label.text = "You Win! Tap to Play Next Level."
            label.name = "nextLevel"
            label.alpha = 1
        }
    }
    
    func labelToStart()
    {
        label.text = "Press to Start"
        label.name = "start"
    }
}
