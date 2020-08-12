//
//  GameScene.swift
//  ShootingGalleryDay66
//
//  Created by Samat on 10.08.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var mosquitos: [String: (timer: Double, score: Int)] = ["big": (2.5, 1), "small": (1.8, 3), "medium": (2.1, 2), "butterfly": (2.5, -5)]
    
    
    var scoreLabel: SKLabelNode!
    var score = 0 { didSet { scoreLabel.text = "Score: \(score)" } }
    
    var secondsLabel: SKLabelNode!
    var secondsRemaining = 0 {
        didSet {
            secondsLabel.text = "Seconds: \(secondsRemaining)"
            if secondsRemaining < 6 {
                secondsLabel.fontColor = UIColor.systemRed
            }
        }
    }
    
    var bulletsLabel: SKLabelNode!
    var bullets = 0 {
        didSet {
            bulletsLabel.text = "Bullets: \(bullets)"
            if bullets == 0 {
                bulletsLabel.fontColor = UIColor.systemRed
            }
        }
    }
    
    var player = AVAudioPlayer()
    var backgroundSoundTimer: Timer?
    
    
    var targetTimer: Timer?
    var gameTimer: Timer?
    var gameOver = false
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        
        secondsLabel = SKLabelNode(fontNamed: "Chalkduster")
        secondsLabel.position = CGPoint(x: 512, y: 16)
        secondsLabel.horizontalAlignmentMode = .center
        addChild(secondsLabel)
        
        
        bulletsLabel = SKLabelNode(fontNamed: "Chalkduster")
        bulletsLabel.position = CGPoint(x: 1008, y: 16)
        bulletsLabel.horizontalAlignmentMode = .right
        addChild(bulletsLabel)
        
        startNewGame()
        
        playBackgroundSound()
        
        backgroundSoundTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: { [weak self] _ in
            self?.player.stop()
            self?.playBackgroundSound()
        })
        
    }
    
    
    func startNewGame() {
        score = 0
        secondsRemaining = 60
        bullets = 6
        
        secondsLabel.fontColor = .white
        
        targetTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(createTargets), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTiming), userInfo: nil, repeats: true)
    }
    
    
    func playBackgroundSound() {
        if let soundURL = Bundle.main.url(forResource: "locust", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                player.play()
            } catch {
                print("background sound error")
            }
        }
    }
    
    @objc func gameTiming() {
        secondsRemaining -= 1
        
        if secondsRemaining == 0 {
            gameOver = true
            targetTimer?.invalidate()
            gameTimer?.invalidate()
            
            let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.name = "gameover"
            gameOverLabel.position = CGPoint(x: 512, y: 384)
            gameOverLabel.numberOfLines = 0
            
            gameOverLabel.text = " GAME IS OVER \nSTART NEW GAME"
            gameOverLabel.verticalAlignmentMode = .center
            gameOverLabel.horizontalAlignmentMode = .center
            addChild(gameOverLabel)
            
        }
    }
    
    
    @objc func createTargets() {
        createTarget(at: Int.random(in: 600...700), fromLeftToRight: true)
        createTarget(at: Int.random(in: 400...500), fromLeftToRight: false)
        createTarget(at: Int.random(in: 200...300), fromLeftToRight: true)
    }
    
    
    func createTarget(at positionY: Int, fromLeftToRight: Bool) {
        
        let startX = fromLeftToRight ? -100 : 1100
        let endX = fromLeftToRight ? 1300 : -300
        
        let mosquito = mosquitos.randomElement()!
        let target = SKSpriteNode(imageNamed: mosquito.key)
        target.name = mosquito.key
        
        target.position = CGPoint(x: startX, y: positionY)
        if !fromLeftToRight { target.xScale = target.xScale * -1 }
        addChild(target)
        
        let move = SKAction.move(to: CGPoint(x: endX, y: positionY), duration: mosquito.value.timer)
        target.run(move)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        
        let location = touch.location(in: self)
        let items = nodes(at: location)
        
        for item in items {
            if item.name == "gameover" {
                item.removeFromParent()
                gameOver = false
                startNewGame()
                return
            } else if gameOver {
                return
            } else if let name = item.name, let mosquito = mosquitos[name] {
                if bullets > 0 {
                    score += mosquito.score
                    item.removeFromParent()
                    let bloodEffect = SKEmitterNode(fileNamed: "blood")!
                    bloodEffect.position = item.position
                    addChild(bloodEffect)
                    run(SKAction.playSoundFileNamed("slap.mp3", waitForCompletion: false))
                }
                break
            } else if bullets == 0 && item == items.last {
                bullets = 6
                bulletsLabel.fontColor = .white
                return
            }
        }
        
        if bullets > 0 { bullets -= 1 }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -200 || node.position.x > 1200 {
                node.removeFromParent()
            }
        }
        
    }
}
