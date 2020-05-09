local controller_test = {}

function controller_test.test1(x)
    return x + 1
end

function controller_test.test2(x, y)
    return x + y, x * y
end

return controller_test
