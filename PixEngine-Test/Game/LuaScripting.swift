//
//  LuaScripting.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 12.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

public class LuaScripting {
    public let vm: LuaVM
    private weak var context: GameContext!

    // MARK: Lua C modules

    private func getEntityByID<T: PXEntity>(_ id: LuaValue, as: T.Type) -> T {
        return PXEntity.byID(id as! Int64) as! T
    }

    private lazy var cModules: [LuaCModule] = [
        LuaCModule(name: "projectile", functions: [
            LuaCFunction(name: "setVelocity", args: 2, res: 0, body: {
                self.getEntityByID($0[0], as: Projectile.self).physics?.velocity = PXv2f.fromLua($0[1])
                return []
            }),
            LuaCFunction(name: "getVelocity", args: 1, res: 1, body: {
                [self.getEntityByID($0[0], as: Projectile.self).physics?.velocity.luaValue ?? 0]
            }),
            LuaCFunction(name: "setPos", args: 2, res: 0, body: {
                self.getEntityByID($0[0], as: Projectile.self).pos = PXv2f.fromLua($0[1])
                return []
            }),
            LuaCFunction(name: "getPos", args: 1, res: 1, body: {
                [self.getEntityByID($0[0], as: Projectile.self).pos.luaValue]
            }),
            LuaCFunction(name: "destroy", args: 1, res: 0, body: {
                self.getEntityByID($0[0], as: Projectile.self).shouldBeRemoved = true
                return []
            }),
        ]),

        LuaCModule(name: "game", functions: [
            LuaCFunction(name: "time", args: 0, res: 1) { args in
                return [self.context.time]
            },
            LuaCFunction(name: "incScore", args: 1, res: 0) { args in
                self.context.score += Int(args[0] as! Int64)
                self.context.scoreText.text = String(self.context.score)
                return []
            },
            LuaCFunction(name: "decScore", args: 1, res: 0) { args in
                self.context.score -= Int(args[0] as! Int64)
                self.context.scoreText.text = String(self.context.score)
                return []
            },
        ]),

        LuaCModule(name: "scene", functions: [
            // addProjectile(descriptor) -> id
            LuaCFunction(name: "addProjectile", args: 1, res: 1) { args in
                let e = Projectile(
                    descriptor: PXConfig.resourceManager.loadFile(
                        ProjectileDescriptor.self,
                        file: Bundle.main.url(forResource: "fireball", withExtension: "json", subdirectory: "Descriptors/Projectiles")!),
                    context: self.context)
                self.context.currentScene.addEntity(e)
                return [e.id]
            },
            LuaCFunction(name: "isSolid", args: 1, res: 1) { args in
                let e = PXEntity.byID(args[0] as! Int64)
                return [(e?.physics?.solid ?? false) ? 1 : 0]
            },
            LuaCFunction(name: "isStatic", args: 1, res: 1) { args in
                let e = PXEntity.byID(args[0] as! Int64)
                return [(e?.physics?.dynamic ?? false) ? 0 : 1]
            },
            LuaCFunction(name: "isCharacter", args: 1, res: 1) { args in
                let e = PXEntity.byID(args[0] as! Int64)
                return [e as? Character != nil ? 1 : 0]
            },
        ]),

        LuaCModule(name: "character", functions: [
            LuaCFunction(name: "recieveDamage", args: 2, res: 0) { (args) -> [LuaValue] in
                let c = self.getEntityByID(args[0], as: Character.self)
                c.recieveDamage(damage: Int(args[1] as! Int64))
                return []
            }
        ])
    ]

    init(context: GameContext) {
        self.context = context

        vm = LuaVM()
        cModules.forEach({ self.vm.registerCModule($0) })

        let urls = Bundle.main.urls(forResourcesWithExtension: "lua", subdirectory: "Scripts/Core")!
        for url in urls {
            vm.loadLModule(url, name: url.deletingPathExtension().lastPathComponent)
        }
    }
}
