//
//  Projectile.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

// MARK: Lua extensions

extension ProjectileState: LuaCompatible, LuaCodable {
    public static func fromLua(_ v: LuaValue?) -> Self? {
        if case let .table(kv) = v,
            let velocity = PXv2f.fromLua(kv["velocity"] ?? nil) {
            return ProjectileState(velocity: velocity)
        } else {
            return nil
        }
    }

    public var luaValue: LuaValue {
        return LuaEncoder.encode(self)
    }
}

public class LuaProjectileController: ProjectileController {

    private static let functions: [LuaFunction] = [
        LuaFunction(name: "update", args: 2, res: 1),
        LuaFunction(name: "tabletest", args: 1, res: 1)
    ]
    private let luaModule: LuaLModule

    public func update(context: GameContext, projectile: Projectile) {
        if let newState = ProjectileState.fromLua(luaModule.call("update", projectile.state, context.time)?[0]) {
            projectile.state = newState
        } else {
            fatalError("Error in lua script \(luaModule.moduleName)")
        }
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
        shouldBeRemoved = true
    }

    public var velocity: PXv2f {
        get {
            state.velocity
        }
        set {
            state.velocity = newValue
        }
    }

    public init(name: String, context: GameContext) {
        self.context = context
        super.init(name: name)
        collider.parent = self
    }
}
