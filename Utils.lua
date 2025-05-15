local Utilities = {}

function Utilities.safeGet(obj, ...)
    local current = obj
    for _, key in ipairs({...}) do
        if current == nil then return nil end
        current = current[key]
    end
    return current
end

function Utilities.waitForChild(parent, name, timeout)
    timeout = timeout or 10
    local start = tick()
    local obj
    repeat
        obj = parent:FindFirstChild(name)
        if not obj then wait(0.1) end
    until obj or (tick() - start) > timeout
    return obj
end

function Utilities.getAllChildren(instance)
    local children = {}
    for _, child in ipairs(instance:GetChildren()) do
        table.insert(children, child)
    end
    return children
end

function Utilities.getAllDescendants(instance)
    local descendants = {}
    for _, descendant in ipairs(instance:GetDescendants()) do
        table.insert(descendants, descendant)
    end
    return descendants
end

function Utilities.fireRemote(remote, ...)
    if typeof(remote) == "Instance" and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        else
            return remote:InvokeServer(...)
        end
    end
end

function Utilities.findFirstRemote()
    local remotes = {}
    for _, instance in ipairs(game:GetDescendants()) do
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            table.insert(remotes, instance)
        end
    end
    return remotes[1]
end

function Utilities.getAllRemotes()
    local remotes = {}
    for _, instance in ipairs(game:GetDescendants()) do
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            table.insert(remotes, instance)
        end
    end
    return remotes
end

function Utilities.getFullPath(instance)
    local path = instance.Name
    local current = instance.Parent
    while current ~= game do
        path = current.Name .. "/" .. path
        current = current.Parent
    end
    return path
end

function Utilities.destroyAllOfClass(className)
    for _, instance in ipairs(game:GetDescendants()) do
        if instance:IsA(className) then
            instance:Destroy()
        end
    end
end

return Utilities
