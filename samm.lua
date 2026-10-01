-- ===================================================
-- BOT SAMM.NET - HỢP LỆ VỚI KEY MỚI (D<device>)
-- ===================================================

local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local KeyFrame = Instance.new("Frame")
local KeyTitle = Instance.new("TextLabel")
local KeyInput = Instance.new("TextBox")
local KeyBtn = Instance.new("TextButton")
local KeyStatus = Instance.new("TextLabel")
local IBBtn = Instance.new("TextButton")
local IBStroke = Instance.new("UIStroke")
local MainFrame = Instance.new("Frame")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local LogFrame = Instance.new("ScrollingFrame")
local LogLayout = Instance.new("UIListLayout")
local ChatBox = Instance.new("TextBox")
local FPSLabel = Instance.new("TextLabel")
local AntiLabel = Instance.new("TextLabel")
local ButtonFolder = Instance.new("Folder")
local espFolder = Instance.new("Folder")

ScreenGui.Name = "HackerChatBot"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

ButtonFolder.Name = "ButtonFolder"
ButtonFolder.Parent = ScreenGui

espFolder.Name = "ESP_Folder"
espFolder.Parent = ScreenGui

local homePosition = nil
local flySpeed = 8
local isFPSOn = false
local isESPOn = false
local isAntiOn = false
local isBayOn = false
local isXuyenTuongOn = false
local isBatTuOn = false
local isActivated = false
local currentKey = nil
local keyExpireTime = nil
local keyDeviceLimit = 0

-- ===================================================
-- HÀM KIỂM TRA KEY MỚI
-- Định dạng: SAMM-<duration>-D<device>-<random>-<random>
-- duration: 1P, 5P, 1H, 1D, 1W, 1M, VV
-- device: D1 đến D5000
-- ===================================================
local function parseKey(key)
    -- Pattern: SAMM-<duration>-D<device>-<rand4>-<rand4>
    local duration, device, r1, r2 = key:match("^SAMM%-(%w+)%-(D%d+)%-([A-Z0-9]+)%-([A-Z0-9]+)$")
    if not duration or not device or not r1 or not r2 then
        return nil
    end
    
    -- Kiểm tra duration hợp lệ
    local validDurations = {
        ["1P"] = 60,        -- 1 phút = 60 giây
        ["5P"] = 300,       -- 5 phút = 300 giây
        ["1H"] = 3600,      -- 1 giờ = 3600 giây
        ["1D"] = 86400,     -- 1 ngày = 86400 giây
        ["1W"] = 604800,    -- 1 tuần
        ["1M"] = 2592000,   -- 1 tháng (30 ngày)
        ["VV"] = -1,        -- Vĩnh viễn
    }
    
    if not validDurations[duration] then
        return nil
    end
    
    -- Lấy số thiết bị
    local deviceNum = tonumber(device:sub(2)) -- Bỏ chữ "D"
    if not deviceNum or deviceNum < 1 or deviceNum > 5000 then
        return nil
    end
    
    return {
        duration = duration,
        durationSeconds = validDurations[duration],
        device = deviceNum,
    }
end

local function isValidKey(key)
    return parseKey(key) ~= nil
end

-- ===================================================
-- HÀM GHI LOG
-- ===================================================
local function log(message, color)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Log"
    lbl.Parent = LogFrame
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Text = "[" .. os.date("%H:%M:%S") .. "] " .. message
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = #LogFrame:GetChildren()
    
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, #LogFrame:GetChildren() * 22)
    task.wait(0.05)
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.AbsoluteCanvasSize.Y)
end

local function botReply(msg, color)
    log("[BOT SAMM.NET] " .. msg, color or Color3.fromRGB(255, 50, 50))
end

-- ===================================================
-- HÀM CHUNG
-- ===================================================
local function saveHome()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        homePosition = char.HumanoidRootPart.Position
        botReply("Đã lưu vị trí nhà!")
    end
end

local function setNoclip(state)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- ===================================================
-- LẤY GIÁ TRỊ TRỨNG
-- ===================================================
local function getEggValue(obj)
    local value = 0
    for _, attr in pairs(obj:GetAttributes()) do
        if type(attr) == "number" then value = math.max(value, attr) end
    end
    for _, child in pairs(obj:GetDescendants()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            local n = child.Name:lower()
            if n:find("price") or n:find("cost") or n:find("value") or n:find("money") or n:find("income") or n:find("rate") then
                value = math.max(value, child.Value)
            end
        end
    end
    return value
end

local function findBestEgg()
    local best = nil
    local bestValue = -1
    local keywords = {"egg", "trung", "trứng", "trex", "dragon", "rong", "phoenix", "balrog", "brainrot", "pet", "scorpion", "gorilla", "yeti", "shark", "tiger", "fire", "ice", "crystal", "rock"}
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            local isEgg = false
            for _, kw in pairs(keywords) do
                if name:find(kw) then isEgg = true break end
            end
            
            if isEgg then
                local primary = nil
                if obj:IsA("Model") then
                    primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                else
                    primary = obj
                end
                
                if primary then
                    local eggValue = getEggValue(obj)
                    local score = eggValue
                    if score == 0 then score = 1 end
                    if score > bestValue then
                        bestValue = score
                        best = obj
                    end
                end
            end
        end
    end
    return best, bestValue
end

-- ===================================================
-- CÁC HÀM CHỨC NĂNG
-- ===================================================

local function startBatTu()
    task.spawn(function()
        while isBatTuOn do
            task.wait(0.1)
            local char = game.Players.LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                end
            end
        end
    end)
end

local function startESP()
    task.spawn(function()
        while isESPOn do
            task.wait(0.5)
            for _, child in pairs(espFolder:GetChildren()) do child:Destroy() end
            if isESPOn then
                local bestEgg, bestValue = findBestEgg()
                if bestEgg then
                    local primary = nil
                    if bestEgg:IsA("Model") then
                        primary = bestEgg.PrimaryPart or bestEgg:FindFirstChildWhichIsA("BasePart")
                    else
                        primary = bestEgg
                    end
                    
                    if primary then
                        local hue = (tick() * 0.5) % 1
                        local billboard = Instance.new("BillboardGui")
                        billboard.Parent = espFolder
                        billboard.Adornee = primary
                        billboard.Size = UDim2.new(0, 250, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 5, 0)
                        billboard.AlwaysOnTop = true
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Parent = billboard
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        nameLabel.Text = bestEgg.Name
                        nameLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        nameLabel.TextScaled = true
                        nameLabel.Font = Enum.Font.Code
                        nameLabel.TextStrokeTransparency = 0
                        
                        local valueLabel = Instance.new("TextLabel")
                        valueLabel.Parent = billboard
                        valueLabel.BackgroundTransparency = 1
                        valueLabel.Position = UDim2.new(0, 0, 0.5, 0)
                        valueLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        valueLabel.Text = "$" .. bestValue
                        valueLabel.TextColor3 = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
                        valueLabel.TextScaled = true
                        valueLabel.Font = Enum.Font.Code
                        valueLabel.TextStrokeTransparency = 0
                    end
                end
            end
        end
    end)
end

local function startFPS()
    task.spawn(function()
        while isFPSOn do
            local hue = (tick() * 0.5) % 1
            FPSLabel.Text = "FPS: 120"
            FPSLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end)
end

local function startAnti()
    task.spawn(function()
        while isAntiOn do
            local hue = (tick() * 0.5) % 1
            AntiLabel.Text = "ANTI-CHEAT 👑"
            AntiLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end)
end

local function startXuyenTuong()
    task.spawn(function()
        while isXuyenTuongOn do
            task.wait(0.1)
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end

local function startBay()
    task.spawn(function()
        while isBayOn do
            task.wait(1)
            if isBayOn then
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local target, value = findBestEgg()
                        if target then
                            local targetPos = nil
                            if target:IsA("BasePart") then targetPos = target.Position
                            elseif target:IsA("Model") then
                                local primary = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                                if primary then targetPos = primary.Position end
                            end
                            
                            if targetPos then
                                setNoclip(true)
                                local startTime = tick()
                                while isBayOn and tick() - startTime < 15 do
                                    if root and root.Parent then
                                        local highY = targetPos.Y + 50
                                        local diff = highY - root.Position.Y
                                        if math.abs(diff) < 3 then break end
                                        local step = math.min(5, math.abs(diff))
                                        if diff > 0 then root.CFrame = CFrame.new(root.Position + Vector3.new(0, step, 0))
                                        else root.CFrame = CFrame.new(root.Position - Vector3.new(0, step, 0)) end
                                    end
                                    task.wait(0.03)
                                end
                                
                                startTime = tick()
                                while isBayOn and tick() - startTime < 20 do
                                    if root and root.Parent then
                                        local targetXZ = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                                        local direction = targetXZ - root.Position
                                        if direction.Magnitude < 3 then break end
                                        root.CFrame = CFrame.new(root.Position + direction.Unit * flySpeed)
                                    end
                                    task.wait(0.03)
                                end
                                
                                local targetY = targetPos.Y + 5
                                startTime = tick()
                                while isBayOn and tick() - startTime < 10 do
                                    if root and root.Parent then
                                        local diff = root.Position.Y - targetY
                                        if math.abs(diff) < 2 then break end
                                        local step = math.min(2, math.abs(diff))
                                        if diff > 0 then root.CFrame = CFrame.new(root.Position - Vector3.new(0, step, 0))
                                        else root.CFrame = CFrame.new(root.Position + Vector3.new(0, step, 0)) end
                                    end
                                    task.wait(0.05)
                                end
                                setNoclip(false)
                                
                                for _, d in pairs(game.Workspace:GetDescendants()) do
                                    if d:IsA("ProximityPrompt") and d.Parent then
                                        local pPos = d.Parent:IsA("BasePart") and d.Parent.Position or nil
                                        if pPos and (pPos - root.Position).Magnitude < 15 then
                                            fireproximityprompt(d) break
                                        end
                                    end
                                end
                                
                                if homePosition then
                                    setNoclip(true)
                                    startTime = tick()
                                    while isBayOn and tick() - startTime < 20 do
                                        if root and root.Parent then
                                            local targetVec = Vector3.new(homePosition.X, root.Position.Y, homePosition.Z)
                                            local direction = targetVec - root.Position
                                            if direction.Magnitude < 3 then break end
                                            root.CFrame = CFrame.new(root.Position + direction.Unit * flySpeed)
                                        end
                                        task.wait(0.03)
                                    end
                                    setNoclip(false)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===================================================
-- TẠO NÚT BẬT/TẮT
-- ===================================================
local function createToggleButton(name)
    for _, child in pairs(ButtonFolder:GetChildren()) do
        if child:IsA("TextButton") and child.Name == name then child:Destroy() end
    end
    
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = ButtonFolder
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 130, 0, 30)
    btn.Text = "BẬT " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Code
    btn.Active = true
    btn.Draggable = true
    
    local count = #ButtonFolder:GetChildren()
    btn.Position = UDim2.new(0, 10, 0, 240 + (count - 1) * 35)
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 2
    
    task.spawn(function()
        local hue = 0
        while btn.Parent do
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            btn.TextColor3 = color
            stroke.Color = color
            task.wait(0.05)
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        local newState = not btn:GetAttribute("Active")
        btn:SetAttribute("Active", newState)
        
        if name == "BAY" then
            isBayOn = newState
            btn.Text = newState and "TẮT BAY" or "BẬT BAY"
            if newState then startBay() end
        elseif name == "FPS" then
            isFPSOn = newState
            btn.Text = newState and "TẮT FPS" or "BẬT FPS"
            FPSLabel.Visible = newState
            if newState then startFPS() end
        elseif name == "ESP" then
            isESPOn = newState
            btn.Text = newState and "TẮT ESP" or "BẬT ESP"
            if newState then startESP() end
        elseif name == "ANTI-CHEAT 👑" then
            isAntiOn = newState
            btn.Text = newState and "TẮT ANTI-CHEAT 👑" or "BẬT ANTI-CHEAT 👑"
            AntiLabel.Visible = newState
            if newState then startAnti() end
        elseif name == "XUYÊN TƯỜNG" then
            isXuyenTuongOn = newState
            btn.Text = newState and "TẮT XUYÊN TƯỜNG" or "BẬT XUYÊN TƯỜNG"
            if newState then startXuyenTuong() else setNoclip(false) end
        elseif name == "BẤT TỬ" then
            isBatTuOn = newState
            btn.Text = newState and "TẮT BẤT TỬ" or "BẬT BẤT TỬ"
            if newState then startBatTu() end
        end
    end)
end

-- ===================================================
-- XỬ LÝ LỆNH
-- ===================================================
local function processCommand(input)
    local msg = input:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "" then return end
    
    log("[BẠN] " .. input, Color3.fromRGB(0, 255, 0))
    
    local cmd, args = msg:match("^(/%S+)%s*(.*)$")
    if not cmd then
        botReply("Lệnh phải bắt đầu bằng '/'. Gõ /help!", Color3.fromRGB(255, 50, 50))
        return
    end
    
    if cmd == "/help" then
        botReply("=== DANH SÁCH LỆNH ===", Color3.fromRGB(255, 50, 50))
        botReply("/bay /fps /esp /anti /xuyentuong /battu", Color3.fromRGB(255, 50, 50))
        botReply("/tocdo [số] /qr /reset /home", Color3.fromRGB(255, 50, 50))
    elseif cmd == "/bay" then createToggleButton("BAY") botReply("Đã tạo nút BẬT/TẮT BAY!")
    elseif cmd == "/fps" then createToggleButton("FPS") botReply("Đã tạo nút BẬT/TẮT FPS!")
    elseif cmd == "/esp" then createToggleButton("ESP") botReply("Đã tạo nút BẬT/TẮT ESP!")
    elseif cmd == "/anti" then createToggleButton("ANTI-CHEAT 👑") botReply("Đã tạo nút BẬT/TẮT ANTI-CHEAT 👑!")
    elseif cmd == "/xuyentuong" then createToggleButton("XUYÊN TƯỜNG") botReply("Đã tạo nút BẬT/TẮT XUYÊN TƯỜNG!")
    elseif cmd == "/battu" then createToggleButton("BẤT TỬ") botReply("Đã tạo nút BẬT/TẮT BẤT TỬ!")
    elseif cmd == "/tocdo" then
        local num = tonumber(args)
        if num and num > 0 then
            flySpeed = num
            botReply("Đã đặt tốc độ bay: " .. num)
        else
            botReply("Nhập số! Ví dụ: /tocdo 100", Color3.fromRGB(255, 50, 50))
        end
    elseif cmd == "/qr" then botReply("Ảnh QR: https://files.catbox.moe/7e2kkm.png")
    elseif cmd == "/reset" then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and homePosition then
            char.HumanoidRootPart.CFrame = CFrame.new(homePosition)
            botReply("Đã reset về nhà!")
        else
            botReply("Chưa lưu nhà! Gõ /home.", Color3.fromRGB(255, 50, 50))
        end
    elseif cmd == "/home" then saveHome()
    else botReply("Lệnh không hợp lệ! Gõ /help.", Color3.fromRGB(255, 50, 50)) end
end

-- ===================================================
-- GIAO DIỆN KÍCH HOẠT KEY
-- ===================================================

KeyFrame.Name = "KeyFrame"
KeyFrame.Parent = ScreenGui
KeyFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
KeyFrame.BackgroundTransparency = 0.05
KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
KeyFrame.Size = UDim2.new(0, 320, 0, 300)
KeyFrame.Visible = false
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.BorderSizePixel = 0

local KeyCorner = Instance.new("UICorner", KeyFrame)
KeyCorner.CornerRadius = UDim.new(0, 10)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Color = Color3.fromRGB(0, 255, 0)
KeyStroke.Thickness = 2

KeyTitle.Name = "KeyTitle"
KeyTitle.Parent = KeyFrame
KeyTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyTitle.BackgroundTransparency = 0.5
KeyTitle.BorderSizePixel = 0
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.Text = "🔑 KÍCH HOẠT KEY 🔑"
KeyTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
KeyTitle.TextScaled = true
KeyTitle.Font = Enum.Font.GothamBold

local KeyTitleCorner = Instance.new("UICorner", KeyTitle)
KeyTitleCorner.CornerRadius = UDim.new(0, 10)

KeyInput.Name = "KeyInput"
KeyInput.Parent = KeyFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
KeyInput.BorderSizePixel = 0
KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
KeyInput.Text = ""
KeyInput.PlaceholderText = "Nhập Key (SAMM-1H-D10-XXXX-XXXX)"
KeyInput.TextColor3 = Color3.fromRGB(0, 255, 0)
KeyInput.TextScaled = true
KeyInput.Font = Enum.Font.Code

local KeyInputCorner = Instance.new("UICorner", KeyInput)
KeyInputCorner.CornerRadius = UDim.new(0, 6)
local KeyInputStroke = Instance.new("UIStroke", KeyInput)
KeyInputStroke.Color = Color3.fromRGB(0, 200, 100)
KeyInputStroke.Thickness = 1

KeyBtn.Name = "KeyBtn"
KeyBtn.Parent = KeyFrame
KeyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
KeyBtn.BorderSizePixel = 0
KeyBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyBtn.Size = UDim2.new(0.8, 0, 0, 40)
KeyBtn.Text = "KÍCH HOẠT"
KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBtn.TextScaled = true
KeyBtn.Font = Enum.Font.GothamBold

local KeyBtnCorner = Instance.new("UICorner", KeyBtn)
KeyBtnCorner.CornerRadius = UDim.new(0, 6)

KeyStatus.Name = "KeyStatus"
KeyStatus.Parent = KeyFrame
KeyStatus.BackgroundTransparency = 1
KeyStatus.Position = UDim2.new(0, 0, 0.55, 0)
KeyStatus.Size = UDim2.new(1, 0, 0, 30)
KeyStatus.Text = "Nhập Key để mở khóa Bot"
KeyStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
KeyStatus.TextScaled = true
KeyStatus.Font = Enum.Font.Code

local IBFrame = Instance.new("Frame")
IBFrame.Name = "IBFrame"
IBFrame.Parent = KeyFrame
IBFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IBFrame.BackgroundTransparency = 0.3
IBFrame.BorderSizePixel = 0
IBFrame.Position = UDim2.new(0.1, 0, 0.72, 0)
IBFrame.Size = UDim2.new(0.8, 0, 0, 45)

local IBCorner = Instance.new("UICorner", IBFrame)
IBCorner.CornerRadius = UDim.new(0, 8)
IBStroke.Parent = IBFrame
IBStroke.Thickness = 2

IBBtn.Name = "IBBtn"
IBBtn.Parent = IBFrame
IBBtn.BackgroundTransparency = 1
IBBtn.Size = UDim2.new(1, 0, 1, 0)
IBBtn.Text = "📞 IB SAMM"
IBBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
IBBtn.TextScaled = true
IBBtn.Font = Enum.Font.GothamBold

IBBtn.MouseButton1Click:Connect(function()
    KeyStatus.Text = "Đang mở Zalo..."
    KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    if setclipboard then
        setclipboard("0355757211")
    end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://zalo.me/0355757211")
    end)
end)

task.spawn(function()
    local hue = 0
    while IBBtn.Parent do
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        IBBtn.TextColor3 = color
        IBStroke.Color = color
        task.wait(0.05)
    end
end)

KeyBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text:upper():gsub("%s+", "")
    local info = parseKey(key)
    
    if info then
        isActivated = true
        currentKey = key
        keyDeviceLimit = info.device
        
        if info.durationSeconds == -1 then
            keyExpireTime = nil -- Vĩnh viễn
            KeyStatus.Text = "✅ KEY VĨNH VIỄN - " .. keyDeviceLimit .. " thiết bị!"
        else
            keyExpireTime = tick() + info.durationSeconds
            KeyStatus.Text = "✅ KEY " .. info.duration .. " - " .. keyDeviceLimit .. " thiết bị!"
        end
        
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        botReply("Key hợp lệ! (" .. info.duration .. ", " .. keyDeviceLimit .. " thiết bị)")
    else
        KeyStatus.Text = "❌ KEY KHÔNG HỢP LỆ! (VD: SAMM-1H-D10-AB12-CD34)"
        KeyStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- ===================================================
-- NÚT SAMM.NET
-- ===================================================
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Position = UDim2.new(0, 10, 0, 200)
ToggleBtn.Size = UDim2.new(0, 90, 0, 40)
ToggleBtn.Text = "SAMM.NET"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(0, 8)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 255, 0)
ToggleStroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function()
    if isActivated then
        MainFrame.Visible = not MainFrame.Visible
    else
        KeyFrame.Visible = not KeyFrame.Visible
    end
end)

-- ===================================================
-- GIAO DIỆN CHAT
-- ===================================================

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -180)
MainFrame.Size = UDim2.new(0, 320, 0, 360)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 0)
MainStroke.Thickness = 2

Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 35)

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Text = ">> BOT SAMM.NET <<"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextScaled = true
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = Header
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.Size = UDim2.new(0, 26, 0, 25)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.Code

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

LogFrame.Name = "LogFrame"
LogFrame.Parent = MainFrame
LogFrame.BackgroundColor3 = Color3.fromRGB(0, 5, 0)
LogFrame.BackgroundTransparency = 0.2
LogFrame.BorderSizePixel = 0
LogFrame.Position = UDim2.new(0.03, 0, 0.13, 0)
LogFrame.Size = UDim2.new(0.94, 0, 0, 250)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 0)

local LogCorner = Instance.new("UICorner", LogFrame)
LogCorner.CornerRadius = UDim.new(0, 6)
local LogStroke = Instance.new("UIStroke", LogFrame)
LogStroke.Color = Color3.fromRGB(0, 150, 50)
LogStroke.Thickness = 1

LogLayout.Parent = LogFrame
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder

ChatBox.Name = "ChatBox"
ChatBox.Parent = MainFrame
ChatBox.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
ChatBox.BorderSizePixel = 0
ChatBox.Position = UDim2.new(0.03, 0, 0.87, 0)
ChatBox.Size = UDim2.new(0.94, 0, 0, 35)
ChatBox.Text = ""
ChatBox.PlaceholderText = "Nhập lệnh... (/help)"
ChatBox.TextColor3 = Color3.fromRGB(0, 255, 0)
ChatBox.TextScaled = true
ChatBox.Font = Enum.Font.Code
ChatBox.ClearTextOnFocus = false

local ChatCorner = Instance.new("UICorner", ChatBox)
ChatCorner.CornerRadius = UDim.new(0, 6)
local ChatStroke = Instance.new("UIStroke", ChatBox)
ChatStroke.Color = Color3.fromRGB(0, 200, 100)
ChatStroke.Thickness = 1

FPSLabel.Name = "FPSLabel"
FPSLabel.Parent = ScreenGui
FPSLabel.BackgroundTransparency = 1
FPSLabel.Position = UDim2.new(1, -150, 0, 80)
FPSLabel.Size = UDim2.new(0, 140, 0, 30)
FPSLabel.Text = "FPS: 120"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextScaled = true
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
FPSLabel.Visible = false

AntiLabel.Name = "AntiLabel"
AntiLabel.Parent = ScreenGui
AntiLabel.BackgroundTransparency = 1
AntiLabel.Position = UDim2.new(0.5, -120, 0.78, 0)
AntiLabel.Size = UDim2.new(0, 240, 0, 40)
AntiLabel.Text = "ANTI-CHEAT 👑"
AntiLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
AntiLabel.TextScaled = true
AntiLabel.Font = Enum.Font.GothamBold
AntiLabel.TextXAlignment = Enum.TextXAlignment.Center
AntiLabel.Visible = false

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

ChatBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local input = ChatBox.Text
        if input and input ~= "" then
            processCommand(input)
            ChatBox.Text = ""
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        homePosition = char.HumanoidRootPart.Position
    end
end)

-- Kiểm tra hết hạn Key
task.spawn(function()
    while true do
        task.wait(1)
        if isActivated and keyExpireTime and tick() > keyExpireTime then
            isActivated = false
            MainFrame.Visible = false
            KeyFrame.Visible = false
            botReply("Key đã hết hạn! Vui lòng nhập Key mới.", Color3.fromRGB(255, 100, 100))
        end
    end
end)

task.wait(2)
saveHome()
print("=== BOT SAMM.NET ĐÃ KÍCH HOẠT ===")
