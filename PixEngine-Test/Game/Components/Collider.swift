//
//  Collider.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

public class BasicCollider: PXComponent {
    public weak var parent: PXEntity!
    private var prev: PXv2f?
    public func fixCollision(context: GameContext) {
        if let prev = prev {
//            let velocity = parent.pos - prev
//            if PXRect.isColliding(parent.rect, )
            let borderxy = context.currentScene.borderTiles(entity: parent)
            borderxy.forEach({ xy in
                if let tile = context.currentScene.getBackgroundTile(x: xy.x, y: xy.y),
                    tile.solid,
                    let cside = PXRect.isColliding(self.parent.rect, tile.rect) {
                    print(cside)
                    switch cside {
                    case .bottom:
                        parent.pos = PXv2f(parent.pos.x, tile.rect.y1 - parent.height)
                    case .top:
                        parent.pos = PXv2f(parent.pos.x, tile.rect.y2)
                    case .left:
                        parent.pos = PXv2f(tile.rect.x2, parent.pos.y)
                    case .right:
                        parent.pos = PXv2f(tile.rect.x1 - parent.width, parent.pos.y)
                    }
                }
            })
        }
        prev = parent.pos
    }
}
