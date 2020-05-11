//
//  Projectile.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine
import UIKit

// MARK: Lua extensions

extension ProjectileState: LuaObject {
    public var luaValue: LuaValue {
        LuaTable(rows: [
            "velocity": velocity.luaValue
        ])
    }

    public static func fromLua(_ v: LuaValue) -> ProjectileState {
        let t = v as! LuaTable
        return ProjectileState(velocity: PXv2f.fromLua(t["velocity"]))
    }
}

public class LuaProjectileController: ProjectileController {

    private static let functions: [LuaFunction] = [
        LuaFunction(name: "update", args: 2, res: 1),
        LuaFunction(name: "tabletest", args: 1, res: 1)
    ]
    private let luaModule: LuaLModule

    public func update(context: GameContext, projectile: Projectile) {
        let ret = luaModule.call("update", projectile.state.luaValue, context.time)![0]
        projectile.state = ProjectileState.fromLua(ret)
    }

    init(vm: LuaVM, moduleName: String) {
        luaModule = LuaLModule(vm: vm, name: moduleName, functions: Self.functions)
    }
}


// MARK: Projectile

public protocol ProjectileController {
    func update(context: GameContext, projectile: Projectile)
}

public struct ProjectileState {
    public var velocity: PXv2f = .zero
}

public class Projectile: PXEntity {
    private var context: GameContext
    public override var dimensions: PXv2f {
        drawable.dimensions
    }
    // MARK: Components
    public var drawable = PXSpriteDrawable()
    public var collider = BasicCollider()
    public var state = ProjectileState()
    public var controller: ProjectileController?

    // MARK: Update methods
    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    public override func update() {
        controller?.update(context: context, projectile: self)
        pos = pos + state.velocity
        if collider.fixCollision(context: context) {
            onCollision()
        }
    }

    private func onCollision() {
        state.velocity = state.velocity.abs * (context.player.center - self.center).normalize()
    }


    public init(name: String, context: GameContext) {
        self.context = context
        super.init(name: name)
        collider.parent = self
    }

    public convenience init(descriptor: ProjectileDescriptor, context: GameContext) {
        self.init(name: descriptor.id, context: context)
        if let script = descriptor.controllerScript {
            controller = LuaProjectileController(vm: context.luaVM, moduleName: script)
        }
        if let lightD = descriptor.light {
            let light = PXFollowLight(lightD)
            
            light.color = PXColor(UIColor(hue: CGFloat.random(in: 0...1), saturation: 1.0, brightness: 1.0, alpha: 1.0))
            
            light.target = self
            self.subentities.append(light)
        }
        drawable.sprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: descriptor.spriteId))
        
        state.velocity = Float.random(in: 2...5) * PXv2f(Float.random(in: -1...1), Float.random(in: -1...1)).normalize()
    }
}

// MARK: Projectile descriptor

public struct ProjectileDescriptor: Codable {
    public var id: String
    public var controllerScript: String?
    public var spriteId: String
    public var light: PXLightDescriptor?
}
