-- ============================================
-- DOXA ROBLOX SCRIPT
-- Features: Fly, Noclip, Infinite Jump, ESP
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- GUI SETUP
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DOXA"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainBox = Instance.new("Frame")
mainBox.Name = "MainBox"
mainBox.Size = UDim2.new(0, 250, 0, 400)
mainBox.Position = UDim2.new(0, 20, 0, 20)
mainBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainBox.BorderSizePixel = 3
mainBox.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
title.TextColor3 = Color3.fromRGB(0, 0, 0)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Text = "DOXA"
title.Parent = mainBox

-- ============================================
-- FEATURES STATE
-- ============================================

local flyEnabled = false
local noclipEnabled = false
local infiniteJumpEnabled = false
local espEnabled = false

local flySpeed = 50
local flyDirection = Vector3.new(0, 0, 0)

-- ============================================
-- FLY FEATURE
-- ============================================

local function startFly()
    if flyEnabled then return end
    flyEnabled = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = rootPart
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.Parent = rootPart
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then
            bodyVelocity:Destroy()
            bodyGyro:Destroy()
            connection:Disconnect()
            return
        end
        
        if not character or not humanoid or humanoid.Health <= 0 then
            flyEnabled = false
            return
        end
        
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- WASD Controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + (Camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - (Camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        
        -- Space to go up, Ctrl to go down
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        bodyVelocity.Velocity = moveDirection * flySpeed
        bodyGyro.CFrame = Camera.CFrame
    end)
end

local function stopFly()
    flyEnabled = false
end

-- ============================================
-- NOCLIP FEATURE
-- ============================================

local function startNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    
    local connection
    connection = RunService.Stepped:Connect(function()
        if not noclipEnabled then
            connection:Disconnect()
            return
        end
        
        if not character then return end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    noclipEnabled = false
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ============================================
-- INFINITE JUMP FEATURE
-- ============================================

local function startInfiniteJump()
    if infiniteJumpEnabled then return end
    infiniteJumpEnabled = true
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if infiniteJumpEnabled and input.KeyCode == Enum.KeyCode.Space and character and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    infiniteJumpEnabled = false
end

-- ============================================
-- ESP FEATURE
-- ============================================

local espPlayers = {}

local function startESP()
    if espEnabled then return end
    espEnabled = true
    
    local function createESP(targetPlayer)
        if targetPlayer == player or espPlayers[targetPlayer] then return end
        
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end
        
        local humanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(4, 0, 2, 0)
        billboard.MaxDistance = math.huge
        billboard.Parent = humanoidRootPart
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Text = targetPlayer.Name
        textLabel.Parent = billboard
        
        espPlayers[targetPlayer] = billboard
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        createESP(targetPlayer)
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        if espEnabled then
            createESP(newPlayer)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(removedPlayer)
        if espPlayers[removedPlayer] then
            espPlayers[removedPlayer]:Destroy()
            espPlayers[removedPlayer] = nil
        end
    end)
end

local function stopESP()
    espEnabled = false
    for targetPlayer, billboard in pairs(espPlayers) do
        billboard:Destroy()
    end
    espPlayers = {}
end

-- ============================================
-- UI BUTTONS
-- ============================================

local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Text = text .. " [OFF]"
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    button.Parent = mainBox
    
    local toggled = false
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.Text = text .. (toggled and " [ON]" or " [OFF]")
        button.BackgroundColor3 = toggled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 0, 0)
        button.TextColor3 = toggled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 0)
        callback(toggled)
    end)
    
    return button
end

-- Create buttons
createButton("FLY", UDim2.new(0, 5, 0, 50), function(toggled)
    if toggled then startFly() else stopFly() end
end)

createButton("NOCLIP", UDim2.new(0, 5, 0, 100), function(toggled)
    if toggled then startNoclip() else stopNoclip() end
end)

createButton("INFINITE JUMP", UDim2.new(0, 5, 0, 150), function(toggled)
    if toggled then startInfiniteJump() else stopInfiniteJump() end
end)

createButton("ESP", UDim2.new(0, 5, 0, 200), function(toggled)
    if toggled then startESP() else stopESP() end
end)

-- ============================================
-- SPEED SLIDER
-- ============================================

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, -10, 0, 20)
speedLabel.Position = UDim2.new(0, 5, 0, 260)
speedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.Text = "Fly Speed: 50"
speedLabel.BorderSizePixel = 0
speedLabel.Parent = mainBox

-- ============================================
-- CLEANUP ON CHARACTER RESPAWN
-- ============================================

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    flyEnabled = false
    noclipEnabled = false
    infiniteJumpEnabled = false
end)

print("DOXA Script Loaded! Use the GUI to toggle features.")
print("Fly Speed: Hold W/A/S/D to move, Space to ascend, Ctrl to descend")