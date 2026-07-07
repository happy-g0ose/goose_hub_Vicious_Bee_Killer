local function decrypt(bytes, key)
    local chars = {}
    for i = 1, #bytes do
        local k = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(chars, string.char(bit32.bxor(bytes[i], k)))
    end
    return table.concat(chars)
end

local player = game.Players.LocalPlayer
local current_id = tostring(player.UserId)

local Whitelist = {
    ["4707106144"] = {
        crypto_data = {92, 67, 68, 71, 66, 10, 25, 30, 70, 85, 48, 65, 8, 26, 17, 47, 20, 15, 16, 1, 58, 69, 84, 23, 90, 67, 85, 89, 69, 30, 85, 94, 89, 27, 32, 0, 0, 0, 0, 52, 12, 2, 1, 95, 44, 67, 86, 27, 95, 24, 95, 88, 86, 67, 83, 89, 86, 65, 45, 28, 11, 31, 13, 45, 9, 6, 9, 22, 44, 81, 104, 73, 0, 2, 5, 6, 85, 86, 69, 87, 27, 70, 34, 9, 28, 92, 13, 34, 0, 9, 22, 93, 50, 86, 94, 22, 27, 80, 89, 66, 68, 92, 92, 66, 83, 92, 33, 11, 5, 20, 7, 35, 7, 6, 4, 1, 44, 104, 91, 19, 94, 93, 90, 68, 31, 92, 67, 80}
    },
    ["3830323163"] = {
        crypto_data = {91, 76, 71, 64, 64, 8, 28, 30, 68, 82, 33, 71, 4, 0, 27, 29, 6, 32, 16, 22, 58, 75, 90, 92, 86, 71, 85, 93, 70, 29, 82, 89, 94, 121, 14, 12, 6, 28, 16, 0, 47, 10, 1, 114, 74, 77, 82, 91, 88, 31, 92, 93, 84, 66, 83, 91, 52, 28, 9, 26, 11, 25, 27, 40, 13, 14, 51, 93, 74, 85, 103, 2, 4, 6, 7, 2, 85, 80, 64, 48, 70, 17, 12, 9, 6, 92, 42, 0, 4, 59, 74, 22, 94, 89, 90, 94, 28, 85, 90, 68, 67, 95, 60, 26, 4, 1, 9, 17, 25, 37, 7, 1, 57, 82, 88, 64, 75, 108, 92, 88, 88, 89, 91, 69, 29, 58, 28, 2}
    },
    ["3019399462"] = {
        crypto_data = {91, 68, 69, 73, 64, 3, 22, 27, 68, 83, 63, 65, 9, 12, 13, 59, 29, 11, 16, 31, 1, 45, 87, 91, 93, 68, 84, 87, 71, 23, 90, 91, 91, 29, 47, 0, 1, 22, 28, 32, 5, 6, 1, 65, 23, 43, 85, 87, 88, 31, 94, 86, 84, 74, 92, 92, 84, 71, 34, 28, 10, 9, 17, 57, 0, 2, 9, 8, 23, 57, 107, 5, 7, 5, 4, 8, 87, 95, 74, 82, 25, 64, 45, 9, 29, 74, 17, 54, 9, 13, 22, 67, 9, 62, 93, 90, 28, 87, 88, 76, 70, 85, 83, 71, 81, 90, 46, 11, 4, 2, 27, 55, 14, 2, 4, 31, 23, 0, 88, 95, 89, 90, 91, 74, 29, 85, 76, 85}
    }
}

if not Whitelist[current_id] then
    player:Kick("🔒 Access Denied.")
    return
end

local user_data = Whitelist[current_id]
local HttpService = game:GetService("HttpService")
local cache_file = "sys_session_data.json"

local function try_auth(pass)
    local input_key = current_id .. pass
    local success, decrypted_url = pcall(function()
        return decrypt(user_data.crypto_data, input_key)
    end)
    if success and decrypted_url:match("^https?://") then
        return true, decrypted_url
    end
    return false, nil
end

local autologin = false
local cached_url = nil

if isfile and isfile(cache_file) then
    local ok, content = pcall(readfile, cache_file)
    if ok then
        local json_ok, data = pcall(function() return HttpService:JSONDecode(content) end)
        if json_ok and data.password and data.expires then
            if os.time() < data.expires then
                local auth_ok, url = try_auth(data.password)
                if auth_ok then
                    autologin = true
                    cached_url = url
                end
            end
        end
    end
end

if autologin and cached_url then
    loadstring(game:HttpGet(cached_url))()
    return
end

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("GooseAuthUI") then CoreGui.GooseAuthUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GooseAuthUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "GOOSE HUB v0.4 — SECURITY"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -30, 0, 35)
TextBox.Position = UDim2.new(0, 15, 0, 50)
TextBox.PlaceholderText = "Enter security key..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.BorderSizePixel = 0
TextBox.Parent = MainFrame

local TextCorner = Instance.new("UICorner")
TextCorner.CornerRadius = UDim.new(0, 6)
TextCorner.Parent = TextBox

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -30, 0, 40)
Button.Position = UDim2.new(0, 15, 0, 100)
Button.Text = "LOG IN"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.BackgroundColor3 = Color3.fromRGB(215, 30, 30)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.BorderSizePixel = 0
Button.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = Button

MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local openTween = TweenService:Create(MainFrame, tweenInfo, {
    Size = UDim2.new(0, 340, 0, 160),
    Position = UDim2.new(0.5, -170, 0.4, -80)
})
openTween:Play()

Button.MouseButton1Click:Connect(function()
    local entered_password = TextBox.Text
    local auth_ok, decrypted_url = try_auth(entered_password)

    if auth_ok then
        Title.Text = "Loading..."
        Button.Text = "Please wait..."
        
        if writefile then
            pcall(writefile, cache_file, HttpService:JSONEncode({
                password = entered_password,
                expires = os.time() + 86400
            }))
        end

        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.4, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            ScreenGui:Destroy()
            loadstring(game:HttpGet(decrypted_url))()
        end)
    else
        TextBox.Text = ""
        TextBox.PlaceholderText = "Invalid security key."
        TextBox.PlaceholderColor3 = Color3.fromRGB(215, 30, 30)
    end
end)
