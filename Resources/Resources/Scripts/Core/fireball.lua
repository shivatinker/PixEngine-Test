local module = {}

function module.update(state, time)
    state.velocity.x = state.velocity.x + 2 * (math.random() - 0.5)
    state.velocity.y = state.velocity.y + 2 * (math.random() - 0.5)
    return state
end

function module.tabletest(t)
    return t
end

return module
