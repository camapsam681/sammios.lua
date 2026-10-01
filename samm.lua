-- ===================================================
-- BOT SAMM.NET - KEY CHẶT + IB SAMM TỰ ĐỘNG
-- ===================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("HackerChatBot")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerChatBot"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local ButtonFolder = Instance.new("Folder")
ButtonFolder.Name = "ButtonFolder"
ButtonFolder.Parent = ScreenGui

local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Folder"
espFolder.Parent = ScreenGui

local dvFolder = Instance.new("Folder")
dvFolder.Name = "DV_Folder"
dvFolder.Parent = ScreenGui

local isActivated = false
local keyExpireTime = nil
local keyTimerConnection = nil
local isFPSOn = false
local isESPOn = false
local isAntiOn = false
local isNoclipOn = false
local isNoclip2On = false
local isBayOn = false
local isXuyenTuongOn = false
local isDVOn = false
local flySpeed = 8
local homePosition = nil

-- ===================================================
-- LƯU/ĐỌC KEY
-- ===================================================
local function saveKeyToFile(key, expireTime)
    pcall(function()
        if writefile then writefile("samm_key.txt", key .. "|" .. tostring(expireTime or 0)) end
    end)
end

local function loadKeyFromFile()
    local success, data = pcall(function()
        if readfile and isfile and isfile("samm_key.txt") then return readfile("samm_key.txt") end
        return nil
    end)
    if success and data then
        local key, expireStr = data:match("^([^|]+)|(.+)$")
        if key then return key, tonumber(expireStr) or 0 end
    end
    return nil, nil
end

local function deleteKeyFile()
    pcall(function()
        if delfile and isfile and isfile("samm_key.txt") then delfile("samm_key.txt") end
    end)
end

-- Lưu Key đã hết hạn
local function saveExpiredKey(key)
    pcall(function()
        if appendfile then
            appendfile("samm_expired.txt", key .. "\n")
        end
    end)
end

-- Kiểm tra Key đã hết hạn trước đó chưa
local function isKeyExpiredBefore(key)
    local success, data = pcall(function()
        if readfile and isfile and isfile("samm_expired.txt") then return readfile("samm_expired.txt") end
        return nil
    end)
    if success and data then
        for line in data:gmatch("[^\n]+") do
            if line == key then return true end
        end
    end
    return false
end

-- ===================================================
-- PARSE KEY
-- ===================================================
local function parseKey(key)
    local duration, device = key:match("^SAMM%-(%w+)%-(D%d+)%-[A-Z0-9]+%-[A-Z0-9]+$")
    if not duration or not device then return nil end
    local valid = {["1P"]=60,["5P"]=300,["1H"]=3600,["1D"]=86400,["1W"]=604800,["1M"]=2592000,["VV"]=-1}
    if not valid[duration] then return nil end
    local d = tonumber(device:sub(2))
    if not d or d < 1 or d > 5000 then return nil end
    return { duration = duration, durationSeconds = valid[duration], device = d }
end

local function formatTime(seconds)
    if seconds <= 0 then return "00:00:00" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if d > 0 then return string.format("%dd %02d:%02d:%02d", d, h, m, s) end
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- ===================================================
-- KÍCH HOẠT KEY (CHẶT CHẼ)
-- ===================================================
local function activateKey(key, expireTime)
    local info = parseKey(key)
    if not info then return false, "Key không hợp lệ!" end
    
    -- Kiểm tra Key đã hết hạn trước đó
    if isKeyExpiredBefore(key) then
        return false, "Key này đã hết hạn, không thể kích hoạt lại!"
    end
    
    -- Nếu có expireTime cũ, kiểm tra còn hạn không
    if expireTime and expireTime > 0 and expireTime <= tick() then
        saveExpiredKey(key)
        return false, "Key này đã hết hạn, không thể kích hoạt lại!"
    end
    
    isActivated = true
    
    if info.durationSeconds == -1 then
        keyExpireTime = nil
    else
        if expireTime and expireTime > tick() then
            keyExpireTime = expireTime
        else
            keyExpireTime = tick() + info.durationSeconds
        end
        saveKeyToFile(key, keyExpireTime)
    end
    
    -- Hủy kết nối cũ
    if keyTimerConnection then keyTimerConnection:Disconnect() end
    
    -- Đếm ngược Key
    keyTimerConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not isActivated then return end
        if keyExpireTime then
            local remaining = keyExpireTime - tick()
            if remaining <= 0 then
                isActivated = false
                saveExpiredKey(key)
                deleteKeyFile()
                local MF = ScreenGui:FindFirstChild("MainFrame")
                local KF = ScreenGui:FindFirstChild("KeyFrame")
                if MF then MF.Visible = false end
                if KF then KF.Visible = false end
                if keyTimerConnection then keyTimerConnection:Disconnect() keyTimerConnection = nil end
                botReply("Key đã hết hạn! Vui lòng nhập Key mới.", Color3.fromRGB(255, 100, 100))
            end
        end
    end)
    
    -- Thông báo định kỳ
    task.spawn(function()
        while isActivated do
            local interval = 300
            if info.duration == "1H" then interval = 600
            elseif info.duration == "1D" then interval = 86400
            elseif info.duration == "1W" then interval = 604800
            elseif info.duration == "1M" then interval = 2592000
            elseif info.duration == "VV" then interval = 2592000
            end
            task.wait(interval)
            if not isActivated then break end
            if keyExpireTime then
                local remaining = keyExpireTime - tick()
                if remaining > 0 then
                    botReply("⏱️ Key còn lại: " .. formatTime(remaining), Color3.fromRGB(0, 255, 0))
                end
            else
                botReply("⏱️ Key vĩnh viễn - vẫn hoạt động!", Color3.fromRGB(255, 215, 0))
            end
        end
    end)
    
    return true, info
end

-- ===================================================
-- GHI LOG
-- ===================================================
local LogFrame

local function log(msg, color, isBot)
    if not LogFrame then return end
    local lbl = Instance.new("TextLabel")
    lbl.Parent = LogFrame
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 0, 22)
    lbl.Text = "[" .. os.date("%H:%M:%S") .. "] " .. msg
    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.LayoutOrder = #LogFrame:GetChildren()
    if isBot then
        task.spawn(function()
            local hue = 0
            while lbl.Parent do
                hue = (hue + 0.02) % 1
                lbl.TextColor3 = Color3.fromHSV(hue, 1, 1)
                task.wait(0.05)
            end
        end)
    end
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, #LogFrame:GetChildren() * 24)
    task.wait(0.05)
    LogFrame.CanvasPosition = Vector2.new(0, LogFrame.AbsoluteCanvasSize.Y)
end

local function botReply(msg, color)
    log("[BOT SAMM.NET] " .. msg, color or Color3.fromRGB(255, 50, 50), true)
end

-- ===================================================
-- CÁC HÀM CHỨC NĂNG
-- ===================================================

local function setNoclip(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = not state end
    end
end

local function startFPS()
    task.spawn(function()
        while isFPSOn do
            local hue = (tick() * 0.5) % 1
            local F = ScreenGui:FindFirstChild("FPSLabel")
            if F then
                F.Text = "FPS: 120"
                F.TextColor3 = Color3.fromHSV(hue, 1, 1)
            end
            task.wait(0.05)
        end
    end)
end

local function startESP()
    task.spawn(function()
        while isESPOn do
            task.wait(0.5)
            for _, c in pairs(espFolder:GetChildren()) do c:Destroy() end
            if isESPOn then
                for _, obj in pairs(game.Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:find("egg") or name:find("trung") or name:find("brainrot") then
                            local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if primary then
                                local hue = (tick() * 0.5) % 1
                                local bb = Instance.new("BillboardGui")
                                bb.Parent = espFolder
                                bb.Adornee = primary
                                bb.Size = UDim2.new(0, 200, 0, 40)
                                bb.StudsOffset = Vector3.new(0, 5, 0)
                                bb.AlwaysOnTop = true
                                local nl = Instance.new("TextLabel")
                                nl.Parent = bb
                                nl.BackgroundTransparency = 1
                                nl.Size = UDim2.new(1, 0, 1, 0)
                                nl.Text = obj.Name
                                nl.TextColor3 = Color3.fromHSV(hue, 1, 1)
                                nl.TextScaled = true
                                nl.Font = Enum.Font.Code
                                nl.TextStrokeTransparency = 0
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function startAnti()
    task.spawn(function()
        while isAntiOn do
            local hue = (tick() * 0.5) % 1
            local A = ScreenGui:FindFirstChild("AntiLabel")
            if A then
                A.Text = "ANTI-CHEAT 👑"
                A.TextColor3 = Color3.fromHSV(hue, 1, 1)
            end
            task.wait(0.05)
        end
    end)
end

local function startNoclip()
    task.spawn(function()
        while isNoclipOn do
            task.wait(0.1)
            setNoclip(true)
        end
    end)
end

local function startNoclip2()
    task.spawn(function()
        while isNoclip2On do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if char then
                setNoclip(true)
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in pairs(game.Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj ~= root then
                            if (obj.Position - root.Position).Magnitude < 20 then obj.CanCollide = false end
                        end
                    end
                end
            end
        end
    end)
end

local function startXuyenTuong()
    task.spawn(function()
        while isXuyenTuongOn do
            task.wait(0.1)
            setNoclip(true)
        end
    end)
end

local function startDV()
    task.spawn(function()
        local hue = 0
        while isDVOn do
            task.wait(0.1)
            hue = (hue + 0.03) % 1
            for _, c in pairs(dvFolder:GetChildren()) do c:Destroy() end
            local lc = LocalPlayer.Character
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local c = p.Character
                    if c and c ~= lc then
                        local r = c:FindFirstChild("HumanoidRootPart")
                        if r then
                            for _, part in pairs(c:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    pcall(function() part.Color = Color3.fromHSV(hue, 1, 1) end)
                                end
                            end
                            local bb = Instance.new("BillboardGui")
                            bb.Parent = dvFolder
                            bb.Adornee = r
                            bb.Size = UDim2.new(0, 150, 0, 60)
                            bb.StudsOffset = Vector3.new(0, 4, 0)
                            bb.AlwaysOnTop = true
                            local nl = Instance.new("TextLabel")
                            nl.Parent = bb
                            nl.BackgroundTransparency = 1
                            nl.Size = UDim2.new(1, 0, 0.6, 0)
                            nl.Text = p.Name
                            nl.TextColor3 = Color3.fromHSV((hue + 0.3) % 1, 1, 1)
                            nl.TextScaled = true
                            nl.Font = Enum.Font.GothamBold
                            nl.TextStrokeTransparency = 0
                        end
                    end
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
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root and homePosition then
                        setNoclip(true)
                        local t = 0
                        while isBayOn and t < 20 do
                            if root and root.Parent then
                                local tv = Vector3.new(homePosition.X, root.Position.Y, homePosition.Z)
                                local d = tv - root.Position
                                if d.Magnitude < 3 then break end
                                root.CFrame = CFrame.new(root.Position + d.Unit * flySpeed)
                            end
                            t = t + task.wait(0.03)
                        end
                        setNoclip(false)
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
        if child.Name == name then child:Destroy() end
    end
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = ButtonFolder
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 120, 0, 28)
    btn.Text = "BẬT " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Code
    btn.Active = true
    btn.Draggable = true
    local count = #ButtonFolder:GetChildren()
    btn.Position = UDim2.new(0, 10, 0, 260 + (count - 1) * 32)
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
        local state = not btn:GetAttribute("Active")
        btn:SetAttribute("Active", state)
        if name == "FPS" then
            isFPSOn = state; btn.Text = state and "TẮT FPS" or "BẬT FPS"
            local F = ScreenGui:FindFirstChild("FPSLabel")
            if F then F.Visible = state end
            if state then startFPS() end
        elseif name == "ESP" then
            isESPOn = state; btn.Text = state and "TẮT ESP" or "BẬT ESP"
            if state then startESP() end
        elseif name == "ANTI" then
            isAntiOn = state; btn.Text = state and "TẮT ANTI" or "BẬT ANTI"
            local A = ScreenGui:FindFirstChild("AntiLabel")
            if A then A.Visible = state end
            if state then startAnti() end
        elseif name == "NOCLIP" then
            isNoclipOn = state; btn.Text = state and "TẮT NOCLIP" or "BẬT NOCLIP"
            if state then startNoclip() else setNoclip(false) end
        elseif name == "NOCLIP 2" then
            isNoclip2On = state; btn.Text = state and "TẮT NOCLIP 2" or "BẬT NOCLIP 2"
            if state then startNoclip2() else setNoclip(false) end
        elseif name == "XUYÊN TƯỜNG" then
            isXuyenTuongOn = state; btn.Text = state and "TẮT XUYÊN TƯỜNG" or "BẬT XUYÊN TƯỜNG"
            if state then startXuyenTuong() else setNoclip(false) end
        elseif name == "ĐỊNH VỊ" then
            isDVOn = state; btn.Text = state and "TẮT ĐỊNH VỊ" or "BẬT ĐỊNH VỊ"
            if state then startDV() else
                for _, c in pairs(dvFolder:GetChildren()) do c:Destroy() end
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character then
                        for _, part in pairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                pcall(function() part.Material = Enum.Material.Plastic end)
                            end
                        end
                    end
                end
            end
        elseif name == "BAY" then
            isBayOn = state; btn.Text = state and "TẮT BAY" or "BẬT BAY"
            if state then startBay() end
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
    local cmd = msg:match("^(/%S+)")
    if not cmd then botReply("Lệnh phải bắt đầu bằng '/'!", Color3.fromRGB(255, 50, 50)) return end

    if cmd == "/help" then
        botReply("Lệnh: /dv /anti /noclip /noclip2 /fyy /xuyentuong /esp /fps")
    elseif cmd == "/dv" then createToggleButton("ĐỊNH VỊ") botReply("Đã tạo nút ĐỊNH VỊ!")
    elseif cmd == "/anti" then createToggleButton("ANTI") botReply("Đã tạo nút ANTI!")
    elseif cmd == "/noclip" then createToggleButton("NOCLIP") botReply("Đã tạo nút NOCLIP!")
    elseif cmd == "/noclip2" then createToggleButton("NOCLIP 2") botReply("Đã tạo nút NOCLIP 2!")
    elseif cmd == "/fyy" then createToggleButton("BAY") botReply("Đã tạo nút BAY!")
    elseif cmd == "/xuyentuong" then createToggleButton("XUYÊN TƯỜNG") botReply("Đã tạo nút XUYÊN TƯỜNG!")
    elseif cmd == "/esp" then createToggleButton("ESP") botReply("Đã tạo nút ESP!")
    elseif cmd == "/fps" then createToggleButton("FPS") botReply("Đã tạo nút FPS!")
    elseif cmd == "/reset" then
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("HumanoidRootPart") and homePosition then
            c.HumanoidRootPart.CFrame = CFrame.new(homePosition)
            botReply("Đã reset!")
        end
    else botReply("Lệnh không hợp lệ! Gõ /help.", Color3.fromRGB(255, 50, 50)) end
end

-- ===================================================
-- TẠO GIAO DIỆN
-- ===================================================

-- Nút SAMM.NET
local Btn = Instance.new("TextButton")
Btn.Parent = ScreenGui
Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Btn.BorderSizePixel = 0
Btn.Position = UDim2.new(0, 10, 0, 60)
Btn.Size = UDim2.new(0, 90, 0, 40)
Btn.Text = "SAMM.NET"
Btn.TextColor3 = Color3.fromRGB(0, 255, 0)
Btn.TextScaled = true
Btn.Font = Enum.Font.GothamBold
Btn.Active = true
Btn.Draggable = true
local C1 = Instance.new("UICorner", Btn)
C1.CornerRadius = UDim.new(0, 8)
local S1 = Instance.new("UIStroke", Btn)
S1.Color = Color3.fromRGB(0, 255, 0)
S1.Thickness = 2

-- Khung Key
local KF = Instance.new("Frame")
KF.Name = "KeyFrame"
KF.Parent = ScreenGui
KF.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
KF.Position = UDim2.new(0.5, -150, 0.5, -130)
KF.Size = UDim2.new(0, 300, 0, 240)
KF.Visible = false
KF.Active = true
KF.Draggable = true
local C2 = Instance.new("UICorner", KF)
C2.CornerRadius = UDim.new(0, 14)
local S2 = Instance.new("UIStroke", KF)
S2.Color = Color3.fromRGB(0, 255, 0)
S2.Thickness = 2

local KT = Instance.new("TextLabel")
KT.Parent = KF
KT.BackgroundTransparency = 1
KT.Position = UDim2.new(0, 0, 0, 15)
KT.Size = UDim2.new(1, 0, 0, 30)
KT.Text = "🔑 KÍCH HOẠT KEY"
KT.TextColor3 = Color3.fromRGB(0, 255, 0)
KT.TextScaled = true
KT.Font = Enum.Font.GothamBold

local KI = Instance.new("TextBox")
KI.Parent = KF
KI.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
KI.BorderSizePixel = 0
KI.Position = UDim2.new(0.08, 0, 0.28, 0)
KI.Size = UDim2.new(0.84, 0, 0, 40)
KI.PlaceholderText = ""
KI.Text = ""
KI.TextColor3 = Color3.fromRGB(0, 255, 0)
KI.TextScaled = true
KI.Font = Enum.Font.Code
KI.ClearTextOnFocus = false
local KC1 = Instance.new("UICorner", KI)
KC1.CornerRadius = UDim.new(0, 8)

local KB = Instance.new("TextButton")
KB.Parent = KF
KB.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
KB.BorderSizePixel = 0
KB.Position = UDim2.new(0.08, 0, 0.48, 0)
KB.Size = UDim2.new(0.84, 0, 0, 40)
KB.Text = "KÍCH HOẠT"
KB.TextColor3 = Color3.fromRGB(255, 255, 255)
KB.TextScaled = true
KB.Font = Enum.Font.GothamBold
local KC2 = Instance.new("UICorner", KB)
KC2.CornerRadius = UDim.new(0, 8)

local KS = Instance.new("TextLabel")
KS.Parent = KF
KS.BackgroundTransparency = 1
KS.Position = UDim2.new(0, 0, 0.68, 0)
KS.Size = UDim2.new(1, 0, 0, 22)
KS.Text = ""
KS.TextColor3 = Color3.fromRGB(255, 255, 0)
KS.TextScaled = true
KS.Font = Enum.Font.Code

local IB = Instance.new("TextButton")
IB.Parent = KF
IB.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IB.BorderSizePixel = 0
IB.Position = UDim2.new(0.08, 0, 0.8, 0)
IB.Size = UDim2.new(0.84, 0, 0, 35)
IB.Text = "📞 IB SAMM"
IB.TextColor3 = Color3.fromRGB(255, 255, 255)
IB.TextScaled = true
IB.Font = Enum.Font.GothamBold
local IC1 = Instance.new("UICorner", IB)
IC1.CornerRadius = UDim.new(0, 8)
local IBS = Instance.new("UIStroke", IB)
IBS.Thickness = 2

-- Nút IB SAMM tự động mở Zalo
IB.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard("0355757211") end
    task.wait(2)
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://zalo.me/0355757211")
    end)
    task.wait(1)
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://zalo.me/0355757211")
    end)
end)

task.spawn(function()
    local hue = 0
    while IB.Parent do
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        IB.TextColor3 = color
        IBS.Color = color
        task.wait(0.05)
    end
end)

-- Khung Chat
local MF = Instance.new("Frame")
MF.Name = "MainFrame"
MF.Parent = ScreenGui
MF.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
MF.Position = UDim2.new(0.5, -140, 0.5, -130)
MF.Size = UDim2.new(0, 280, 0, 260)
MF.Visible = false
MF.Active = true
MF.Draggable = true
local MC = Instance.new("UICorner", MF)
MC.CornerRadius = UDim.new(0, 12)
local MS = Instance.new("UIStroke", MF)
MS.Color = Color3.fromRGB(255, 50, 50)
MS.Thickness = 2

local MT = Instance.new("TextLabel")
MT.Parent = MF
MT.BackgroundTransparency = 1
MT.Position = UDim2.new(0, 10, 0, 0)
MT.Size = UDim2.new(1, -45, 0, 30)
MT.Text = ">> BOT SAMM.NET <<"
MT.TextColor3 = Color3.fromRGB(255, 100, 100)
MT.TextScaled = true
MT.Font = Enum.Font.Code
MT.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    local hue = 0
    while MT.Parent do
        hue = (hue + 0.02) % 1
        MT.TextColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.05)
    end
end)

local XB = Instance.new("TextButton")
XB.Parent = MF
XB.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
XB.BorderSizePixel = 0
XB.Position = UDim2.new(1, -28, 0, 4)
XB.Size = UDim2.new(0, 22, 0, 22)
XB.Text = "X"
XB.TextColor3 = Color3.fromRGB(255, 255, 255)
XB.TextScaled = true
XB.Font = Enum.Font.Code
local XC = Instance.new("UICorner", XB)
XC.CornerRadius = UDim.new(0, 6)

LogFrame = Instance.new("ScrollingFrame")
LogFrame.Name = "LogFrame"
LogFrame.Parent = MF
LogFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
LogFrame.BackgroundTransparency = 0.2
LogFrame.BorderSizePixel = 0
LogFrame.Position = UDim2.new(0.03, 0, 0.13, 0)
LogFrame.Size = UDim2.new(0.94, 0, 0, 150)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 3
local LC = Instance.new("UICorner", LogFrame)
LC.CornerRadius = UDim.new(0, 6)
local LL = Instance.new("UIListLayout", LogFrame)
LL.SortOrder = Enum.SortOrder.LayoutOrder

local CB = Instance.new("TextBox")
CB.Parent = MF
CB.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
CB.BorderSizePixel = 0
CB.Position = UDim2.new(0.03, 0, 0.78, 0)
CB.Size = UDim2.new(0.94, 0, 0, 35)
CB.PlaceholderText = "Nhập lệnh... (/help)"
CB.TextColor3 = Color3.fromRGB(255, 255, 255)
CB.TextScaled = true
CB.Font = Enum.Font.Code
CB.ClearTextOnFocus = false
local CC = Instance.new("UICorner", CB)
CC.CornerRadius = UDim.new(0, 8)

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSLabel"
FPSLabel.Parent = ScreenGui
FPSLabel.BackgroundTransparency = 1
FPSLabel.Position = UDim2.new(1, -130, 0, 70)
FPSLabel.Size = UDim2.new(0, 120, 0, 25)
FPSLabel.Text = "FPS: 120"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextScaled = true
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Visible = false

local AntiLabel = Instance.new("TextLabel")
AntiLabel.Name = "AntiLabel"
AntiLabel.Parent = ScreenGui
AntiLabel.BackgroundTransparency = 1
AntiLabel.Position = UDim2.new(0.5, -120, 0.78, 0)
AntiLabel.Size = UDim2.new(0, 240, 0, 40)
AntiLabel.Text = "ANTI-CHEAT 👑"
AntiLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
AntiLabel.TextScaled = true
AntiLabel.Font = Enum.Font.GothamBold
AntiLabel.Visible = false

-- ===================================================
-- SỰ KIỆN
-- ===================================================

XB.MouseButton1Click:Connect(function() MF.Visible = false end)

KB.MouseButton1Click:Connect(function()
    local key = KI.Text:upper():gsub("%s+", "")
    local success, info = activateKey(key, nil)
    
    if success then
        if keyExpireTime then
            KS.Text = "✅ KEY " .. info.duration .. " - " .. info.device .. " thiết bị!"
        else
            KS.Text = "✅ KEY VĨNH VIỄN - " .. info.device .. " thiết bị!"
        end
        KS.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)
        KF.Visible = false
        MF.Visible = true
        botReply("Key hợp lệ!")
    else
        KS.Text = "❌ " .. info
        KS.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

Btn.MouseButton1Click:Connect(function()
    if isActivated then MF.Visible = not MF.Visible
    else KF.Visible = not KF.Visible end
end)

CB.FocusLost:Connect(function(enter)
    if enter and CB.Text ~= "" then
        processCommand(CB.Text)
        CB.Text = ""
    end
end)

LocalPlayer.Chatted:Connect(function(message)
    processCommand(message)
end)

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        homePosition = char.HumanoidRootPart.Position
    end
end)

-- Tự động đăng nhập nếu Key còn hạn
task.spawn(function()
    task.wait(3)
    local savedKey, savedExpire = loadKeyFromFile()
    if savedKey then
        local info = parseKey(savedKey)
        if info then
            local isValid = false
            if info.durationSeconds == -1 then isValid = true
            elseif savedExpire and savedExpire > tick() then isValid = true end
            
            if isValid then
                local success = activateKey(savedKey, savedExpire)
                if success then
                    MF.Visible = true
                    botReply("Tự động đăng nhập bằng Key đã lưu!")
                end
            else
                saveExpiredKey(savedKey)
                deleteKeyFile()
                botReply("Key đã hết hạn! Vui lòng nhập Key mới.", Color3.fromRGB(255, 100, 100))
            end
        end
    end
end)

task.wait(2)
local char = LocalPlayer.Character
if char and char:FindFirstChild("HumanoidRootPart") then
    homePosition = char.HumanoidRootPart.Position
end

botReply("Chào bạn! Gõ /help để xem lệnh.")
print("=== BOT SAMM.NET ĐÃ KÍCH HOẠT ===")
