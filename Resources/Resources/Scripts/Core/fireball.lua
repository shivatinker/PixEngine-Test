local module = {}
local init_times = {}

local function random_norm()
    local th = 2 * math.pi * math.random()
    return {x = math.cos(th), y = math.sin(th)}
end

local function vector_mul(v, c)
    return {x = c * v.x, y = c * v.y}
end

function module.update(id)
    if (game.time() - init_times[id]) > 60 then
        init_times[id] = game.time()
        local pid = scene.addProjectile('fireball')
        local p = projectile.getPos(id)
        
        projectile.setPos(pid, p)
        
    end
end

function module.init(id)
    init_times[id] = game.time()
    projectile.setVelocity(id, vector_mul(random_norm(), 7))
    game.incScore()
end

function module.destroy(id)
    game.decScore()
end

function module.tabletest(t)
    return t
end

return module
