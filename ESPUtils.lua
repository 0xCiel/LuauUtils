local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local Config = {
    FontSize = 18,
    Color = Color3.new(1, 1, 1),
    TextOffset = Vector2.new(0, 0),
    Outline = false,
    ShowDistance = true,
    ShowHealth = true
}

local ESP = {
    ActiveESPs = {},
    HumanESPs = {}
}

function ESP.Create(object)
    if not object or not (object:IsA("BasePart") or object:IsA("Model")) then
        return nil
    end

    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = Config.FontSize
    text.Color = Config.Color
    text.Outline = Config.Outline
    text.Center = true

    local updateName = "ESP_Update_" .. object:GetDebugId()
    local settings = {
        Enabled = false,
        UseWorldPivot = false,
        ShowDistance = Config.ShowDistance
    }

    local function Update()
        if not object or not object.Parent or not settings.Enabled then
            text.Visible = false
            return
        end

        local player = Players.LocalPlayer
        local character = player.Character
        if not character then return end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        local rootPos
        if object:IsA("BasePart") then
            rootPos = object.Position
        else
            if settings.UseWorldPivot then
                rootPos = object:GetPivot().Position
            else
                local hrp = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChildWhichIsA("BasePart")
                if not hrp then return end
                rootPos = hrp.Position
            end
        end

        local distance = (humanoidRootPart.Position - rootPos).Magnitude
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)

        if onScreen then
            local displayText = settings.ShowDistance and string.format("%s [%.1fm]", object.Name, distance) or object.Name
            text.Text = displayText
            text.Position = Vector2.new(screenPos.X + Config.TextOffset.X, screenPos.Y + Config.TextOffset.Y)
            text.Visible = true
        else
            text.Visible = false
        end
    end

    RunService:BindToRenderStep(updateName, Enum.RenderPriority.Camera.Value + 1, Update)

    local function Unload()
        RunService:UnbindFromRenderStep(updateName)
        text:Remove()
        ESP.ActiveESPs[object] = nil
    end

    object.AncestryChanged:Connect(function(_, parent)
        if not parent then Unload() end
    end)

    local espObject = {
        Enable = function(state)
            settings.Enabled = state
        end,
        
        UseWorldPivot = function(state)
            settings.UseWorldPivot = state
        end,
        
        UpdateFontSize = function(size)
            text.Size = size
        end,
        
        ShowDistance = function(state)
            settings.ShowDistance = state
        end,
        
        Unload = Unload
    }

    ESP.ActiveESPs[object] = espObject
    return espObject
end

function ESP.CreateHumanESP(humanoid)
    if not humanoid or not humanoid:IsA("Humanoid") then
        return nil
    end

    local character = humanoid.Parent
    if not character then return nil end

    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = Config.FontSize
    text.Color = Config.Color
    text.Outline = Config.Outline
    text.Center = true

    local updateName = "HumanESP_Update_" .. humanoid:GetDebugId()
    local settings = {
        Enabled = false,
        ShowDistance = Config.ShowDistance,
        ShowHealth = Config.ShowHealth
    }

    local function Update()
        if not humanoid or not humanoid.Parent or not settings.Enabled then
            text.Visible = false
            return
        end

        local player = Players.LocalPlayer
        local playerChar = player.Character
        if not playerChar then return end

        local playerHrp = playerChar:FindFirstChild("HumanoidRootPart")
        if not playerHrp then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local distance = (playerHrp.Position - hrp.Position).Magnitude
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

        if onScreen then
            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            local displayText = string.format("%s [%.1fm][%d%%]", 
                character.Name, 
                distance, 
                healthPercent
            )
            text.Text = displayText
            text.Position = Vector2.new(screenPos.X + Config.TextOffset.X, screenPos.Y + Config.TextOffset.Y)
            text.Visible = true
        else
            text.Visible = false
        end
    end

    RunService:BindToRenderStep(updateName, Enum.RenderPriority.Camera.Value + 1, Update)

    local function Unload()
        RunService:UnbindFromRenderStep(updateName)
        text:Remove()
        ESP.HumanESPs[humanoid] = nil
    end

    humanoid.Destroying:Connect(Unload)
    humanoid.AncestryChanged:Connect(function(_, parent)
        if not parent then Unload() end
    end)

    local espObject = {
        Enable = function(state)
            settings.Enabled = state
        end,
        
        UpdateFontSize = function(size)
            text.Size = size
        end,
        
        ShowDistance = function(state)
            settings.ShowDistance = state
        end,
        
        ShowHealth = function(state)
            settings.ShowHealth = state
        end,
        
        Unload = Unload
    }

    ESP.HumanESPs[humanoid] = espObject
    return espObject
end

function ESP.CleanupAll()
    for object, esp in pairs(ESP.ActiveESPs) do
        if esp.Unload then
            esp:Unload()
        end
    end
    for humanoid, esp in pairs(ESP.HumanESPs) do
        if esp.Unload then
            esp:Unload()
        end
    end
end

return ESP
