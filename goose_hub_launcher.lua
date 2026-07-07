local function decrypt(bytes, key)
    local chars = {}
    for i = 1, #bytes do
        local k = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(chars, string.char(bit32.bxor(bytes[i], k)))
    end
    local decrypted = table.concat(chars)
    return decrypted:sub(17) 
end

local player = game.Players.LocalPlayer
local current_id = tostring(player.UserId)

local Whitelist = {
    ["4707106144"] = {
        crypto_data = {65.0, 79.0, 86.0, 78.0, 94.0, 67.0, 90.0, 70.0, 95.0, 68.0, 47.0, 83.0, 85.0, 18.0, 95.0, 45.0, 35.0, 69.0, 24.0, 28.0, 64.0, 72.0, 112.0, 12.0, 75.0, 25.0, 86.0, 28.0, 37.0, 93.0, 67.0, 88.0, 66.0, 83.0, 69.0, 69.0, 84.0, 70.0, 87.0, 40.0, 94.0, 68.0, 22.0, 93.0, 43.0, 101.0, 82.0, 3.0, 1.0, 28.0, 26.0, 62.0, 83.0, 73.0, 1.0, 12.0, 85.0, 114.0, 4.0, 68.0, 85.0, 24.0, 86.0, 95.0, 89.0, 66.0, 81.0, 107.0, 47.0, 69.0, 82.0, 44.0, 101.0, 54.0, 40.0, 88.0, 3.0, 25.0, 64.0, 45.0, 29.0, 70.0, 92.0, 39.0, 106.0, 91.0, 46.0, 88.0, 82.0, 66.0, 24.0, 67.0, 85.0, 80.0, 66.0, 27.0, 92.0, 34.0, 81.0, 84.0, 0, 28.0, 50.0, 42.0, 88.0, 2.0, 67.0, 84.0, 29.0, 48.0, 80.0, 92.0, 39.0, 73.0, 71.0, 32.0, 107.0, 91.0, 81.0, 66.0, 95.0, 83.0, 94.0, 84.0, 70.0, 26.0, 43.0, 69.0, 81.0}
    },
    ["3830323163"] = {
        crypto_data = {92.0, 74.0, 87.0, 92.0, 92.0, 92.0, 94.0, 64.0, 91.0, 73.0, 33.0, 66.0, 25.0, 70.0, 84.0, 7.0, 27.0, 43.0, 54.0, 67.0, 64.0, 101.0, 111.0, 66.0, 57.0, 86.0, 83.0, 86.0, 55.0, 90.0, 76.0, 91.0, 69.0, 81.0, 71.0, 64.0, 84.0, 68.0, 80.0, 57.0, 95.0, 23.0, 84.0, 94.0, 1.0, 93.0, 60.0, 45.0, 94.0, 28.0, 55.0, 33.0, 29.0, 59.0, 78.0, 9.0, 31.0, 96.0, 3.0, 75.0, 86.0, 31.0, 84.0, 93.0, 92.0, 66.0, 83.0, 108.0, 62.0, 68.0, 1.0, 110.0, 102.0, 28.0, 16.0, 54.0, 45.0, 70.0, 64.0, 0, 2.0, 8.0, 46.0, 104.0, 111.0, 17.0, 60.0, 95.0, 93.0, 65.0, 31.0, 65.0, 87.0, 85.0, 66.0, 25.0, 91.0, 51.0, 80.0, 7.0, 66.0, 31.0, 24.0, 18.0, 54.0, 44.0, 28.0, 84.0, 48.0, 47.0, 30.0, 46.0, 104.0, 76.0, 13.0, 50.0, 108.0, 84.0, 82.0, 69.0, 93.0, 81.0, 91.0, 84.0, 68.0, 29.0, 58.0, 68.0, 2.0}
    },
    ["3019399462"] = {
        crypto_data = {95.0, 73.0, 95.0, 95.0, 64.0, 79.0, 78.0, 77.0, 76.0, 83.0, 49.0, 92.0, 24.0, 65.0, 9.0, 40.0, 59.0, 28.0, 69.0, 67.0, 31.0, 94.0, 112.0, 5.0, 8.0, 48.0, 67.0, 113.0, 17.0, 37.0, 71.0, 88.0, 68.0, 91.0, 70.0, 74.0, 92.0, 70.0, 85.0, 93.0, 38.0, 68.0, 11.0, 93.0, 13.0, 113.0, 48.0, 7.0, 92.0, 28.0, 4.0, 5.0, 47.0, 90.0, 3.0, 124.0, 83.0, 111.0, 70.0, 63.0, 86.0, 31.0, 86.0, 86.0, 92.0, 74.0, 92.0, 107.0, 94.0, 71.0, 42.0, 111.0, 56.0, 90.0, 26.0, 54.0, 60.0, 29.0, 66.0, 108.0, 46.0, 1.0, 58.0, 117.0, 49.0, 56.0, 88.0, 51.0, 19.0, 62.0, 28.0, 66.0, 84.0, 95.0, 64.0, 22.0, 81.0, 81.0, 87.0, 86.0, 59.0, 31.0, 3.0, 82.0, 16.0, 49.0, 124.0, 15.0, 94.0, 92.0, 31.0, 1.0, 0, 66.0, 15.0, 51.0, 107.0, 51.0, 23.0, 57.0, 93.0, 83.0, 89.0, 92.0, 65.0, 23.0, 85.0, 65.0, 87.0}
    }
}

if not Whitelist[current_id] then
    player:Kick("🔒 Access Denied. Your ID is not whitelisted.")
    return
end

local user_data = Whitelist[current_id]
local HttpService = game:GetService("HttpService")
local cache_file = "sys_session_data.json"

local function try_auth(pass)
    if pass == "" or #pass < 6 then return false, nil end
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
