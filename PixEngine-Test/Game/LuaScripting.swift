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
                self.getEntityByID($0[0], as: Projectile.self).physics.velocity = PXv2f.fromLua($0[1])
                return []
            }),
            LuaCFunction(name: "getVelocity", args: 1, res: 1, body: {
                [self.getEntityByID($0[0], as: Projectile.self).physics.velocity.luaValue]
            }),
            LuaCFunction(name: "setPos", args: 2, res: 0, body: {
                self.getEntityByID($0[0], as: Projectile.self).pos = PXv2f.fromLua($0[1])
                return []
            }),
            LuaCFunction(name: "getPos", args: 1, res: 1, body: {
                [self.getEntityByID($0[0], as: Projectile.self).pos.luaValue]
            })
        ]),

        LuaCModule(name: "game", functions: [
            LuaCFunction(name: "time", args: 0, res: 1) { args in
                return [self.context.time]
            },
            LuaCFunction(name: "incScore", args: 0, res: 0) { args in
                self.context.score += 1
                self.context.scoreText.text = String(self.context.score)
                return []
            },
            LuaCFunction(name: "decScore", args: 0, res: 0) { args in
                self.context.score -= 1
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
            }
        ]),
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
