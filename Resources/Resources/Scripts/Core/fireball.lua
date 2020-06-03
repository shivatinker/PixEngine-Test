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
    --[[if (game.time() - init_times[id]) > 60 then
        init_times[id] = game.time()
        local pid = scene.addProjectile('fireball')
        local p = projectile.getPos(id)
        
        projectile.setPos(pid, p)
        
    end]]
end

function module.onCollision(id, to, norm)

    projectile.setVelocity(id, vector_mul(projectile.getVelocity(id), -1))

    if (scene.isStatic(to) == 1) then
        projectile.destroy(id)
        return
    end
    
    if (scene.isCharacter(to) == 1) then
        -- projectile.destroy(id)
        character.recieveDamage(to, 1)
        game.incScore(1)
    end
end

function module.init(id)
    init_times[id] = game.time()
    projectile.setVelocity(id, vector_mul(random_norm(), 3))
end

function module.destroy(id)
    
end

function module.tabletest(t)
    return t
end

return module
