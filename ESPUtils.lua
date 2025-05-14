local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESP = {}
local DefaultConfig = {
    Enabled = false,
    Color = Color3.new(1, 1, 1),
    FontSize = 14,
    Distance = 1000,
    UseWorldPivot = false,
    ShowDistance = true,
    TextOffset = Vector2.new(0, -50)
}
local ActiveESPs = {}

function ESP.Create(object)
    if not object or not object:IsA("BasePart") and not object:IsA("Model") then
        return nil
    end
    local config = table.clone(DefaultConfig)
    local textDrawing = Drawing.new("Text")
    textDrawing.Visible = false
    textDrawing.Size = config.FontSize
    textDrawing.Color = config.Color
    textDrawing.Outline = true
    textDrawing.Center = true
    
    local updateName = "ESP_Update_" .. object:GetDebugId()
    
    local function Update()
        if not object or not object.Parent or not config.Enabled then
            textDrawing.Visible = false
            return
        end
        
        local rootPart = object
        if object:IsA("Model") then
            rootPart = object:FindFirstChild(config.UseWorldPivot and "WorldPivot" or "HumanoidRootPart") or object:FindFirstChildWhichIsA("BasePart")
            if not rootPart then
                textDrawing.Visible = false
                return
            end
        end
        
        local player = Players.LocalPlayer
        local char = player.Character
        if not char then
            textDrawing.Visible = false
            return
        end
        
        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        if not playerRoot then
            textDrawing.Visible = false
            return
        end
        
        local distance = (rootPart.Position - playerRoot.Position).Magnitude
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if distance <= config.Distance and onScreen then
            local displayText = object.Name
            if config.ShowDistance then
                displayText = string.format("[%s][%.1f]", displayText, distance)
            end
            
            textDrawing.Text = displayText
            textDrawing.Position = Vector2.new(
                screenPos.X + config.TextOffset.X,
                screenPos.Y + config.TextOffset.Y
            )
            textDrawing.Visible = true
        else
            textDrawing.Visible = false
        end
    end
    
    RunService:BindToRenderStep(updateName, Enum.RenderPriority.Camera.Value + 1, Update)
    
    local function Unload()
        RunService:UnbindFromRenderStep(updateName)
        textDrawing:Remove()
        ActiveESPs[object] = nil
    end
    
    local ancestryConnection
    ancestryConnection = object.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Unload()
            ancestryConnection:Disconnect()
        end
    end)
    
    ActiveESPs[object] = true
    
    return {
        Enable = function(state)
            config.Enabled = state
        end,
        
        UseWorldPivot = function(state)
            config.UseWorldPivot = state
        end,
        
        UpdateFontSize = function(size)
            config.FontSize = size
            textDrawing.Size = size
        end,
        
        Unload = Unload
    }
end

function ESP.CleanupAll()
    for object, _ in pairs(ActiveESPs) do
        local esp = ActiveESPs[object]
        if esp and esp.Unload then
            esp:Unload()
        end
    end
end

return ESP
