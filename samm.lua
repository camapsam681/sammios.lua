--// SCRIPT TỐC ĐỘ + NHẢY - DELTA (MAX 100.000.000)
--// Đi bộ bình thường khi để tốc độ mặc định (16)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local MAX_SPEED = 100000000
local MAX_JUMP = 100000000
local DEFAULT_SPEED = 16
local CustomSpeed = 16   -- Bắt đầu bằng tốc độ bình thường
local CustomJump = 50

local bodyVelocity = nil
local bodyGyro = nil
local speedEnabled = false

-- Xóa BodyVelocity (trả về đi bộ bình thường)
local function clearMovement()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    speedEnabled = false
end

-- Khởi tạo BodyVelocity (chỉ khi tốc độ > 16)
local function setupMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    clearMovement()

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 0, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 1000
    bodyGyro.D = 50
    bodyGyro.Parent = hrp

    speedEnabled = true
end

-- Áp dụng lực nhảy
local function applyJump(power)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = power
        end
    end
end

-- Cập nhật tốc độ
local function applySpeed(val)
    CustomSpeed = val
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if val <= DEFAULT_SPEED then
        hum.WalkSpeed = val
        clearMovement()
    else
        hum.WalkSpeed = DEFAULT_SPEED
        setupMovement()
    end
end

-- Khởi tạo ban đầu
applySpeed(CustomSpeed)
applyJump(CustomJump)

-- Tự động setup lại khi hồi sinh
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed(CustomSpeed)
    applyJump(CustomJump)
end)

-- Vòng lặp chính
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if speedEnabled and bodyVelocity and bodyGyro then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir * CustomSpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end
        bodyGyro.CFrame = hrp.CFrame
    end

    -- Chống reset lực nhảy
    if hum.UseJumpPower == false or hum.JumpPower ~= CustomJump then
        hum.UseJumpPower = true
        hum.JumpPower = CustomJump
    end
end)

-- ==========================================
-- GIAO DIỆN
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedJumpUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 210, 0, 110)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "⚡ TỐC ĐỘ & NHẢY"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

-- Ô tốc độ
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.55, 0, 0, 30)
SpeedInput.Position = UDim2.new(0.05, 0, 0.28, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.PlaceholderText = "Tốc độ (16)..."
SpeedInput.Text = tostring(CustomSpeed)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 12
SpeedInput.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = SpeedInput

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.35, 0, 0, 30)
SpeedBtn.Position = UDim2.new(0.62, 0, 0.28, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SpeedBtn.Text = "Đặt"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 13
SpeedBtn.Parent = Frame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = SpeedBtn

-- Ô nhảy
local JumpInput = Instance.new("TextBox")
JumpInput.Size = UDim2.new(0.55, 0, 0, 30)
JumpInput.Position = UDim2.new(0.05, 0, 0.62, 0)
JumpInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpInput.PlaceholderText = "Lực nhảy (50)..."
JumpInput.Text = tostring(CustomJump)
JumpInput.Font = Enum.Font.Gotham
JumpInput.TextSize = 12
JumpInput.Parent = Frame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 6)
UICorner4.Parent = JumpInput

local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(0.35, 0, 0, 30)
JumpBtn.Position = UDim2.new(0.62, 0, 0.62, 0)
JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
JumpBtn.Text = "Đặt"
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Font = Enum.Font.GothamBold
JumpBtn.TextSize = 13
JumpBtn.Parent = Frame

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(0, 6)
UICorner5.Parent = JumpBtn

-- Xử lý nhập tốc độ
local function processSpeed()
    local val = tonumber(SpeedInput.Text)
    if val then
        if val < 1 then val = 1 end
        if val > MAX_SPEED then val = MAX_SPEED end
        SpeedInput.Text = tostring(val)
        applySpeed(val)
    else
        SpeedInput.Text = tostring(CustomSpeed)
    end
end

-- Xử lý nhập nhảy
local function processJump()
    local val = tonumber(JumpInput.Text)
    if val then
        if val < 1 then val = 1 end
        if val > MAX_JUMP then val = MAX_JUMP end
        CustomJump = val
        JumpInput.Text = tostring(val)
        applyJump(val)
    else
        JumpInput.Text = tostring(CustomJump)
    end
end

SpeedInput.FocusLost:Connect(processSpeed)
SpeedBtn.MouseButton1Click:Connect(processSpeed)
JumpInput.FocusLost:Connect(processJump)
JumpBtn.MouseButton1Click:Connect(processJump)

print("✅ Script đã chạy! Tốc độ: " .. CustomSpeed .. " | Nhảy: " .. CustomJump)
