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

// MARK: Lua
public class LuaProjectileController: ProjectileController {
    
    // Lua module
    public static let lModule: LuaLModule = LuaLModule(functions: [
        LuaFunction(name: "update", args: 1, res: 0),
        LuaFunction(name: "init", args: 1, res: 0),
        LuaFunction(name: "destroy", args: 1, res: 0),
        LuaFunction(name: "onCollision", args: 3, res: 0),
    ])
    private let script: String

    public func update(context: GameContext, projectile: Projectile) {
        context.lua.vm.call(module: Self.lModule, script: script, f: "update", projectile.id)
    }
    
    public func onInit(context: GameContext, projectile: Projectile) {
        context.lua.vm.call(module: Self.lModule, script: script, f: "init", projectile.id)
    }
    
    public func onDestroy(context: GameContext, projectile: Projectile) {
        context.lua.vm.call(module: Self.lModule, script: script, f: "destroy", projectile.id)
    }
    
    public func onCollisionResolved(context: GameContext, projectile: Projectile, with: PXEntity, normal: PXv2f) {
        context.lua.vm.call(module: Self.lModule, script: script,
                            f: "onCollision", projectile.id, with.id, normal.luaValue)
    }
    
    init(moduleName: String) {
        script = moduleName
    }
}


// MARK: Projectile

public protocol ProjectileController {
    func update(context: GameContext, projectile: Projectile)
    func onInit(context: GameContext, projectile: Projectile)
    func onDestroy(context: GameContext, projectile: Projectile)
    func onCollisionResolved(context: GameContext, projectile: Projectile, with: PXEntity, normal: PXv2f)
}

extension Projectile: PXPhysicsDelegate{
    public func onCollisionResolved(entity: PXEntity, with: PXEntity, normal: PXv2f) {
        controller?.onCollisionResolved(context: context, projectile: self, with: with, normal: normal)
    }
}

public class Projectile: PXEntity {
    private var context: GameContext
    public override var dimensions: PXv2f {
        drawable.dimensions
    }
    // MARK: Components
    public var drawable = PXSpriteDrawable()
    public var controller: ProjectileController?

    // MARK: Update methods
    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    public override func update() {
        controller?.update(context: context, projectile: self)
        super.update()
    }

    public init(name: String, context: GameContext) {
        self.context = context
        super.init(name: name)
    }

    public convenience init(descriptor: ProjectileDescriptor, context: GameContext) {
        self.init(name: descriptor.id, context: context)
        if let script = descriptor.controllerScript {
            controller = LuaProjectileController(moduleName: script)
        }
        if let lightD = descriptor.light {
            let light = PXFollowLight(lightD)
            light.target = self
            self.subentities.append(light)
        }
        drawable.sprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: descriptor.spriteId))
        
        let physics = PXPhysics(shape: .rect(width: width, height: height))
        physics.delegate = self
        
        self.physics = physics
        
        controller?.onInit(context: context, projectile: self)
    }
    
    deinit {
        controller?.onDestroy(context: context, projectile: self)
    }
}

// MARK: Projectile descriptor

public struct ProjectileDescriptor: Codable {
    public var id: String
    public var controllerScript: String?
    public var spriteId: String
    public var light: PXLightDescriptor?
}
