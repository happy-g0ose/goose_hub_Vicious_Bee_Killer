local function safe_xor(a, b)
    local res = 0
    local bit_val = 1
    while a > 0 or b > 0 do
        local ra = a % 2
        local rb = b % 2
        if ra ~= rb then
            res = res + bit_val
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bit_val = bit_val * 2
    end
    return res
end

local function decrypt(bytes, key)
    local chars = {}
    for i = 1, #bytes do
        local k = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(chars, string.char(safe_xor(bytes[i], k)))
    end
    local decrypted = table.concat(chars)
    return decrypted:sub(18) 
end

local player = game.Players.LocalPlayer
local current_id = tostring(player.UserId)
local HttpService = game:GetService("HttpService")

-- ===========================================================
-- ============================================================
local Whitelist = {}
local database_url = "https://raw.githubusercontent.com/happy-g0ose/goose_hub_Vicious_Bee_Killer/refs/heads/main/whitelist.json"

local success, response = pcall(function()
    return game:HttpGet(database_url)
end)

if success then
    local decode_success, decoded_data = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if decode_success and decoded_data then
        Whitelist = decoded_data
    else
        player:Kick("🔒 Ошибка: База данных ключей повреждена. Напиши владельцу хаба.")
        return
    end
else
    player:Kick("🔒 Ошибка: Не удалось получить доступ к серверу авторизации.")
    return
end

-- Проверка на наличие ID в базе данных
if not Whitelist[current_id] then
    player:Kick("🔒 Access Denied. Your ID is not whitelisted. (ID: " .. current_id .. ")")
    return
end

local user_data = Whitelist[current_id]
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
        if json_ok and data and data.password and data.expires then
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

TextBox.Focused:Connect(function()
    TextBox.PlaceholderText = "Enter security key..."
    TextBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
end)

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
