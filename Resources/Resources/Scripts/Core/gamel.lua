local module = {}

local lt = 0
function module.onFrame()
    if (game.time() - lt) > 0 then
        local pid = scene.addProjectile('fireball')
        projectile.setPos(pid, {x = 100 * 16 * math.random(), y = 100 * 16 * math.random()})
        lt = game.time()
    end
end

return module
