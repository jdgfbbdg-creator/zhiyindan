-- 只因脚本 v4.9 完整版
-- 作者：只因蛋
-- 功能：完整飞行控制 + 速度调节 + DOORS脚本 + 墨水游戏 + 可拖动悬浮球 + 可滑动高级设置

-- 服务
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")

-- 玩家
local player = Players.LocalPlayer

-- 设备检测
local IS_MOBILE = UserInputService.TouchEnabled
local IS_CONSOLE = UserInputService.GamepadEnabled and not IS_MOBILE
local IS_DESKTOP = not IS_MOBILE and not IS_CONSOLE

-- UI缩放
local UI_SCALE = IS_MOBILE and 0.8 or 1

-- 确保PlayerGui存在
repeat task.wait() until player:FindFirstChild("PlayerGui")

-- ========== 创建主UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlightDoorsUI_Main"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 10
ScreenGui.Parent = player.PlayerGui

-- ===== 可拖动悬浮球 =====
local FloatingBall = Instance.new("ImageButton")
FloatingBall.Name = "FloatingBall"
FloatingBall.Size = UDim2.new(0, 80 * UI_SCALE, 0, 80 * UI_SCALE)
FloatingBall.Position = UDim2.new(1, -100 * UI_SCALE, 1, -200 * UI_SCALE)
FloatingBall.AnchorPoint = Vector2.new(1, 1)
FloatingBall.Image = "rbxassetid://3570695787"
FloatingBall.ImageColor3 = Color3.fromRGB(255, 215, 0)
FloatingBall.BackgroundTransparency = 0.3
FloatingBall.ZIndex = 10
FloatingBall.Parent = ScreenGui

-- 悬浮球发光效果
local BallGlow = Instance.new("ImageLabel")
BallGlow.Name = "BallGlow"
BallGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
BallGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
BallGlow.BackgroundTransparency = 1
BallGlow.Image = "rbxassetid://5028857084"
BallGlow.ImageColor3 = Color3.fromRGB(255, 215, 0)
BallGlow.ImageTransparency = 0.8
BallGlow.ZIndex = 9
BallGlow.Parent = FloatingBall

-- 悬浮球圆角
local BallCorner = Instance.new("UICorner")
BallCorner.CornerRadius = UDim.new(1, 0)
BallCorner.Parent = FloatingBall

-- 悬浮球状态文字
local BallText = Instance.new("TextLabel")
BallText.Name = "BallText"
BallText.Size = UDim2.new(1, 0, 1, 0)
BallText.Position = UDim2.new(0, 0, 0, 0)
BallText.BackgroundTransparency = 1
BallText.Text = "开启"
BallText.TextColor3 = Color3.fromRGB(255, 255, 255)
BallText.TextSize = 22 * UI_SCALE
BallText.Font = Enum.Font.GothamBold
BallText.ZIndex = 11
BallText.Parent = FloatingBall

-- ===== 悬浮球拖动功能 =====
local isDraggingBall = false
local dragStartPos
local ballStartPos

FloatingBall.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingBall = true
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        ballStartPos = FloatingBall.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingBall and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
        FloatingBall.Position = UDim2.new(
            ballStartPos.X.Scale, 
            ballStartPos.X.Offset + delta.X,
            ballStartPos.Y.Scale, 
            ballStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingBall = false
    end
end)

-- ===== 主控制面板 =====
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 500 * UI_SCALE, 0, 400 * UI_SCALE)
MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainPanel.BackgroundTransparency = 0.05
MainPanel.Visible = false
MainPanel.ZIndex = 20
MainPanel.Parent = ScreenGui

-- 面板圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainPanel

-- 面板阴影
local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.new(1, 20, 1, 20)
MainShadow.Position = UDim2.new(0, -10, 0, -10)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://1316045217"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.8
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(10, 10, 118, 118)
MainShadow.ZIndex = 19
MainShadow.Parent = MainPanel

-- 面板标题
local PanelTitle = Instance.new("TextLabel")
PanelTitle.Name = "PanelTitle"
PanelTitle.Size = UDim2.new(1, 0, 0, 40 * UI_SCALE)
PanelTitle.Position = UDim2.new(0, 0, 0, 0)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "只因脚本面板 ("..(IS_MOBILE and "手机" or IS_CONSOLE and "主机" or "电脑")..")"
PanelTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
PanelTitle.TextSize = 24 * UI_SCALE
PanelTitle.Font = Enum.Font.GothamBold
PanelTitle.ZIndex = 21
PanelTitle.Parent = MainPanel

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40 * UI_SCALE, 0, 40 * UI_SCALE)
CloseButton.Position = UDim2.new(1, -50 * UI_SCALE, 0, 5 * UI_SCALE)
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20 * UI_SCALE
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 22
CloseButton.Parent = MainPanel

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- 关闭按钮悬停效果
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
end)

-- ===== 玩家信息区 =====
local PlayerInfo = Instance.new("Frame")
PlayerInfo.Name = "PlayerInfo"
PlayerInfo.Size = UDim2.new(1, -20 * UI_SCALE, 0, 80 * UI_SCALE)
PlayerInfo.Position = UDim2.new(0, 10 * UI_SCALE, 0, 50 * UI_SCALE)
PlayerInfo.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PlayerInfo.ZIndex = 21
PlayerInfo.Parent = MainPanel

local PlayerInfoCorner = Instance.new("UICorner")
PlayerInfoCorner.CornerRadius = UDim.new(0, 10)
PlayerInfoCorner.Parent = PlayerInfo

-- 玩家头像
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Name = "AvatarFrame"
AvatarFrame.Size = UDim2.new(0, 60 * UI_SCALE, 0, 60 * UI_SCALE)
AvatarFrame.Position = UDim2.new(0, 10 * UI_SCALE, 0.5, -30 * UI_SCALE)
AvatarFrame.BackgroundTransparency = 1
AvatarFrame.ZIndex = 22
AvatarFrame.Parent = PlayerInfo

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Name = "AvatarImage"
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.Position = UDim2.new(0, 0, 0, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxassetid://0"
AvatarImage.ZIndex = 23
AvatarImage.Parent = AvatarFrame

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImage

-- 头像边框
local AvatarBorder = Instance.new("ImageLabel")
AvatarBorder.Name = "AvatarBorder"
AvatarBorder.Size = UDim2.new(1.1, 0, 1.1, 0)
AvatarBorder.Position = UDim2.new(-0.05, 0, -0.05, 0)
AvatarBorder.BackgroundTransparency = 1
AvatarBorder.Image = "rbxassetid://4031889928"
AvatarBorder.ImageColor3 = Color3.fromRGB(255, 215, 0)
AvatarBorder.ZIndex = 22
AvatarBorder.Parent = AvatarFrame

-- 玩家信息文字
local PlayerName = Instance.new("TextLabel")
PlayerName.Name = "PlayerName"
PlayerName.Size = UDim2.new(0.6, 0, 0, 20 * UI_SCALE)
PlayerName.Position = UDim2.new(0, 80 * UI_SCALE, 0, 10 * UI_SCALE)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = "玩家: "..player.Name
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.TextSize = 16 * UI_SCALE
PlayerName.Font = Enum.Font.Gotham
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.ZIndex = 22
PlayerName.Parent = PlayerInfo

local WelcomeText = Instance.new("TextLabel")
WelcomeText.Name = "WelcomeText"
WelcomeText.Size = UDim2.new(0.6, 0, 0, 20 * UI_SCALE)
WelcomeText.Position = UDim2.new(0, 80 * UI_SCALE, 0, 35 * UI_SCALE)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Text = "欢迎使用只因脚本!"
WelcomeText.TextColor3 = Color3.fromRGB(200, 200, 255)
WelcomeText.TextSize = 14 * UI_SCALE
WelcomeText.Font = Enum.Font.Gotham
WelcomeText.TextXAlignment = Enum.TextXAlignment.Left
WelcomeText.ZIndex = 22
WelcomeText.Parent = PlayerInfo

-- 白名单状态
local WhitelistStatus = Instance.new("TextLabel")
WhitelistStatus.Name = "WhitelistStatus"
WhitelistStatus.Size = UDim2.new(0.6, 0, 0, 20 * UI_SCALE)
WhitelistStatus.Position = UDim2.new(0, 80 * UI_SCALE, 0, 60 * UI_SCALE)
WhitelistStatus.BackgroundTransparency = 1
WhitelistStatus.Text = "白名单状态: 已授权"
WhitelistStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
WhitelistStatus.TextSize = 14 * UI_SCALE
WhitelistStatus.Font = Enum.Font.Gotham
WhitelistStatus.TextXAlignment = Enum.TextXAlignment.Left
WhitelistStatus.ZIndex = 22
WhitelistStatus.Parent = PlayerInfo

-- ===== 分类系统 =====
local CategoryPanel = Instance.new("Frame")
CategoryPanel.Name = "CategoryPanel"
CategoryPanel.Size = UDim2.new(0, 120 * UI_SCALE, 0, 250 * UI_SCALE)
CategoryPanel.Position = UDim2.new(0, 0, 0, 140 * UI_SCALE)
CategoryPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CategoryPanel.BackgroundTransparency = 0.1
CategoryPanel.ZIndex = 21
CategoryPanel.Parent = MainPanel

local CategoryCorner = Instance.new("UICorner")
CategoryCorner.CornerRadius = UDim.new(0, 10, 0, 0)
CategoryCorner.Parent = CategoryPanel

-- 创建可滚动内容区域
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -120 * UI_SCALE, 0, 250 * UI_SCALE)
ScrollFrame.Position = UDim2.new(0, 120 * UI_SCALE, 0, 140 * UI_SCALE)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600 * UI_SCALE) -- 足够容纳所有内容
ScrollFrame.ZIndex = 21
ScrollFrame.Parent = MainPanel

-- 创建分类按钮函数
local function createCategoryButton(name, position)
    local button = Instance.new("TextButton")
    button.Name = name.."Button"
    button.Size = UDim2.new(0.9, 0, 0, 50 * UI_SCALE)
    button.Position = UDim2.new(0.05, 0, 0, position * 60 * UI_SCALE + 10 * UI_SCALE)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18 * UI_SCALE
    button.Font = Enum.Font.GothamSemibold
    button.ZIndex = 22
    button.Parent = CategoryPanel
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    -- 按钮悬停效果
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 75)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
    end)
    
    return button
end

-- 创建内容页面函数
local function createContentPage(name)
    local frame = Instance.new("Frame")
    frame.Name = name.."Page"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ZIndex = 22
    frame.Parent = ScrollFrame
    return frame
end

-- 创建分类和页面
local homeButton = createCategoryButton("主页", 0)
local generalButton = createCategoryButton("通用", 1)
local doorsButton = createCategoryButton("DOORS", 2)
local inkGameButton = createCategoryButton("墨水游戏", 3)

local homePage = createContentPage("Home")
local generalPage = createContentPage("General")
local doorsPage = createContentPage("Doors")
local inkGamePage = createContentPage("InkGame")

-- ===== 主页内容 =====
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Size = UDim2.new(1, -20 * UI_SCALE, 0, 30 * UI_SCALE)
TimeLabel.Position = UDim2.new(0, 10 * UI_SCALE, 0, 20 * UI_SCALE)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "当前时间: 加载中..."
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.TextSize = 18 * UI_SCALE
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.ZIndex = 23
TimeLabel.Parent = homePage

local CreatorLabel = Instance.new("TextLabel")
CreatorLabel.Name = "CreatorLabel"
CreatorLabel.Size = UDim2.new(1, -20 * UI_SCALE, 0, 50 * UI_SCALE)
CreatorLabel.Position = UDim2.new(0, 10 * UI_SCALE, 0, 60 * UI_SCALE)
CreatorLabel.BackgroundTransparency = 1
CreatorLabel.Text = "By 只因蛋"
CreatorLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
CreatorLabel.TextSize = 24 * UI_SCALE
CreatorLabel.Font = Enum.Font.GothamBold
CreatorLabel.TextXAlignment = Enum.TextXAlignment.Left
CreatorLabel.ZIndex = 23
CreatorLabel.Parent = homePage

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(1, -20 * UI_SCALE, 0, 30 * UI_SCALE)
VersionLabel.Position = UDim2.new(0, 10 * UI_SCALE, 0, 120 * UI_SCALE)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "只因脚本 v4.9 ("..(IS_MOBILE and "手机版" or "电脑版")..")"
VersionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
VersionLabel.TextSize = 16 * UI_SCALE
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.ZIndex = 23
VersionLabel.Parent = homePage

-- 公告区域
local NoticeBackground = Instance.new("Frame")
NoticeBackground.Name = "NoticeBackground"
NoticeBackground.Size = UDim2.new(1, -20 * UI_SCALE, 0, 60 * UI_SCALE)
NoticeBackground.Position = UDim2.new(0, 10 * UI_SCALE, 0, 160 * UI_SCALE)
NoticeBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
NoticeBackground.BackgroundTransparency = 0.1
NoticeBackground.ZIndex = 22
NoticeBackground.Parent = homePage

local NoticeCorner = Instance.new("UICorner")
NoticeCorner.CornerRadius = UDim.new(0, 10)
NoticeCorner.Parent = NoticeBackground

local NoticeLabel = Instance.new("TextLabel")
NoticeLabel.Name = "NoticeLabel"
NoticeLabel.Size = UDim2.new(1, -10 * UI_SCALE, 1, -10 * UI_SCALE)
NoticeLabel.Position = UDim2.new(0, 5 * UI_SCALE, 0, 5 * UI_SCALE)
NoticeLabel.BackgroundTransparency = 1
NoticeLabel.Text = "此脚本在测试阶段，禁止外泄"
NoticeLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
NoticeLabel.TextSize = 16 * UI_SCALE
NoticeLabel.Font = Enum.Font.GothamBold
NoticeLabel.TextXAlignment = Enum.TextXAlignment.Left
NoticeLabel.ZIndex = 23
NoticeLabel.Parent = NoticeBackground

-- ===== 通用页面（飞行控制） =====
local FlightStatus = Instance.new("TextLabel")
FlightStatus.Name = "FlightStatus"
FlightStatus.Size = UDim2.new(1, -20 * UI_SCALE, 0, 30 * UI_SCALE)
FlightStatus.Position = UDim2.new(0, 10 * UI_SCALE, 0, 20 * UI_SCALE)
FlightStatus.BackgroundTransparency = 1
FlightStatus.Text = "飞行: 关闭"
FlightStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
FlightStatus.TextSize = 18 * UI_SCALE
FlightStatus.Font = Enum.Font.GothamBold
FlightStatus.TextXAlignment = Enum.TextXAlignment.Left
FlightStatus.ZIndex = 23
FlightStatus.Parent = generalPage

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.8, 0, 0, 50 * UI_SCALE)
ToggleButton.Position = UDim2.new(0.1, 0, 0, 60 * UI_SCALE)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
ToggleButton.Text = "开启飞行"
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.TextSize = 18 * UI_SCALE
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.ZIndex = 23
ToggleButton.Parent = generalPage

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

-- 按钮悬停效果
ToggleButton.MouseEnter:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 230, 100)}):Play()
end)

ToggleButton.MouseLeave:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
end)

-- 速度控制区域
local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Name = "SpeedControlFrame"
SpeedControlFrame.Size = UDim2.new(0.9, 0, 0, 120 * UI_SCALE)
SpeedControlFrame.Position = UDim2.new(0.05, 0, 0, 130 * UI_SCALE)
SpeedControlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedControlFrame.ZIndex = 23
SpeedControlFrame.Parent = generalPage

local SpeedControlCorner = Instance.new("UICorner")
SpeedControlCorner.CornerRadius = UDim.new(0, 10)
SpeedControlCorner.Parent = SpeedControlFrame

-- 飞行速度控制
local FlightSpeedLabel = Instance.new("TextLabel")
FlightSpeedLabel.Name = "FlightSpeedLabel"
FlightSpeedLabel.Size = UDim2.new(1, -10 * UI_SCALE, 0, 25 * UI_SCALE)
FlightSpeedLabel.Position = UDim2.new(0, 5 * UI_SCALE, 0, 10 * UI_SCALE)
FlightSpeedLabel.BackgroundTransparency = 1
FlightSpeedLabel.Text = "飞行速度: 16"
FlightSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlightSpeedLabel.TextSize = 16 * UI_SCALE
FlightSpeedLabel.Font = Enum.Font.GothamSemibold
FlightSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlightSpeedLabel.ZIndex = 24
FlightSpeedLabel.Parent = SpeedControlFrame

local FlightSpeedSlider = Instance.new("Frame")
FlightSpeedSlider.Name = "FlightSpeedSlider"
FlightSpeedSlider.Size = UDim2.new(1, -10 * UI_SCALE, 0, 20 * UI_SCALE)
FlightSpeedSlider.Position = UDim2.new(0, 5 * UI_SCALE, 0, 40 * UI_SCALE)
FlightSpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
FlightSpeedSlider.ZIndex = 24
FlightSpeedSlider.Parent = SpeedControlFrame

local FlightSpeedSliderCorner = Instance.new("UICorner")
FlightSpeedSliderCorner.CornerRadius = UDim.new(0, 10)
FlightSpeedSliderCorner.Parent = FlightSpeedSlider

local FlightSpeedFill = Instance.new("Frame")
FlightSpeedFill.Name = "FlightSpeedFill"
FlightSpeedFill.Size = UDim2.new(0.5, 0, 1, 0)
FlightSpeedFill.Position = UDim2.new(0, 0, 0, 0)
FlightSpeedFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
FlightSpeedFill.ZIndex = 25
FlightSpeedFill.Parent = FlightSpeedSlider

local FlightSpeedFillCorner = Instance.new("UICorner")
FlightSpeedFillCorner.CornerRadius = UDim.new(0, 10)
FlightSpeedFillCorner.Parent = FlightSpeedFill

local FlightSpeedValue = Instance.new("TextLabel")
FlightSpeedValue.Name = "FlightSpeedValue"
FlightSpeedValue.Size = UDim2.new(1, 0, 1, 0)
FlightSpeedValue.Position = UDim2.new(0, 0, 0, 0)
FlightSpeedValue.BackgroundTransparency = 1
FlightSpeedValue.Text = "16"
FlightSpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
FlightSpeedValue.TextSize = 14 * UI_SCALE
FlightSpeedValue.Font = Enum.Font.GothamBold
FlightSpeedValue.ZIndex = 26
FlightSpeedValue.Parent = FlightSpeedSlider

-- 行走速度控制
local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Name = "WalkSpeedLabel"
WalkSpeedLabel.Size = UDim2.new(1, -10 * UI_SCALE, 0, 25 * UI_SCALE)
WalkSpeedLabel.Position = UDim2.new(0, 5 * UI_SCALE, 0, 70 * UI_SCALE)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Text = "行走速度: 16"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedLabel.TextSize = 16 * UI_SCALE
WalkSpeedLabel.Font = Enum.Font.GothamSemibold
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkSpeedLabel.ZIndex = 24
WalkSpeedLabel.Parent = SpeedControlFrame

local WalkSpeedSlider = Instance.new("Frame")
WalkSpeedSlider.Name = "WalkSpeedSlider"
WalkSpeedSlider.Size = UDim2.new(1, -10 * UI_SCALE, 0, 20 * UI_SCALE)
WalkSpeedSlider.Position = UDim2.new(0, 5 * UI_SCALE, 0, 95 * UI_SCALE)
WalkSpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
WalkSpeedSlider.ZIndex = 24
WalkSpeedSlider.Parent = SpeedControlFrame

local WalkSpeedSliderCorner = Instance.new("UICorner")
WalkSpeedSliderCorner.CornerRadius = UDim.new(0, 10)
WalkSpeedSliderCorner.Parent = WalkSpeedSlider

local WalkSpeedFill = Instance.new("Frame")
WalkSpeedFill.Name = "WalkSpeedFill"
WalkSpeedFill.Size = UDim2.new(0.5, 0, 1, 0)
WalkSpeedFill.Position = UDim2.new(0, 0, 0, 0)
WalkSpeedFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
WalkSpeedFill.ZIndex = 25
WalkSpeedFill.Parent = WalkSpeedSlider

local WalkSpeedFillCorner = Instance.new("UICorner")
WalkSpeedFillCorner.CornerRadius = UDim.new(0, 10)
WalkSpeedFillCorner.Parent = WalkSpeedFill

local WalkSpeedValue = Instance.new("TextLabel")
WalkSpeedValue.Name = "WalkSpeedValue"
WalkSpeedValue.Size = UDim2.new(1, 0, 1, 0)
WalkSpeedValue.Position = UDim2.new(0, 0, 0, 0)
WalkSpeedValue.BackgroundTransparency = 1
WalkSpeedValue.Text = "16"
WalkSpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedValue.TextSize = 14 * UI_SCALE
WalkSpeedValue.Font = Enum.Font.GothamBold
WalkSpeedValue.ZIndex = 26
WalkSpeedValue.Parent = WalkSpeedSlider

-- ===== 高级设置区域 =====
local AdvancedSettingsFrame = Instance.new("Frame")
AdvancedSettingsFrame.Name = "AdvancedSettingsFrame"
AdvancedSettingsFrame.Size = UDim2.new(0.9, 0, 0, 180 * UI_SCALE)
AdvancedSettingsFrame.Position = UDim2.new(0.05, 0, 0, 270 * UI_SCALE)
AdvancedSettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
AdvancedSettingsFrame.ZIndex = 23
AdvancedSettingsFrame.Parent = generalPage

local AdvancedSettingsCorner = Instance.new("UICorner")
AdvancedSettingsCorner.CornerRadius = UDim.new(0, 10)
AdvancedSettingsCorner.Parent = AdvancedSettingsFrame

local AdvancedSettingsTitle = Instance.new("TextLabel")
AdvancedSettingsTitle.Name = "AdvancedSettingsTitle"
AdvancedSettingsTitle.Size = UDim2.new(1, -10 * UI_SCALE, 0, 30 * UI_SCALE)
AdvancedSettingsTitle.Position = UDim2.new(0, 5 * UI_SCALE, 0, 5 * UI_SCALE)
AdvancedSettingsTitle.BackgroundTransparency = 1
AdvancedSettingsTitle.Text = "高级设置 ▼"
AdvancedSettingsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
AdvancedSettingsTitle.TextSize = 18 * UI_SCALE
AdvancedSettingsTitle.Font = Enum.Font.GothamBold
AdvancedSettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
AdvancedSettingsTitle.ZIndex = 24
AdvancedSettingsTitle.Parent = AdvancedSettingsFrame

-- 旋转功能开关
local SpinToggle = Instance.new("TextButton")
SpinToggle.Name = "SpinToggle"
SpinToggle.Size = UDim2.new(0.8, 0, 0, 40 * UI_SCALE)
SpinToggle.Position = UDim2.new(0.1, 0, 0, 40 * UI_SCALE)
SpinToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
SpinToggle.Text = "旋转: 关闭"
SpinToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinToggle.TextSize = 16 * UI_SCALE
SpinToggle.Font = Enum.Font.GothamBold
SpinToggle.ZIndex = 24
SpinToggle.Parent = AdvancedSettingsFrame

local SpinCorner = Instance.new("UICorner")
SpinCorner.CornerRadius = UDim.new(0, 10)
SpinCorner.Parent = SpinToggle

SpinToggle.MouseEnter:Connect(function()
    TweenService:Create(SpinToggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 100)}):Play()
end)

SpinToggle.MouseLeave:Connect(function()
    TweenService:Create(SpinToggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
end)

-- 旋转速度控制
local SpinSpeedLabel = Instance.new("TextLabel")
SpinSpeedLabel.Name = "SpinSpeedLabel"
SpinSpeedLabel.Size = UDim2.new(1, -10 * UI_SCALE, 0, 25 * UI_SCALE)
SpinSpeedLabel.Position = UDim2.new(0, 5 * UI_SCALE, 0, 90 * UI_SCALE)
SpinSpeedLabel.BackgroundTransparency = 1
SpinSpeedLabel.Text = "旋转速度: 50"
SpinSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinSpeedLabel.TextSize = 16 * UI_SCALE
SpinSpeedLabel.Font = Enum.Font.GothamSemibold
SpinSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpinSpeedLabel.ZIndex = 24
SpinSpeedLabel.Parent = AdvancedSettingsFrame

local SpinSpeedSlider = Instance.new("Frame")
SpinSpeedSlider.Name = "SpinSpeedSlider"
SpinSpeedSlider.Size = UDim2.new(1, -10 * UI_SCALE, 0, 20 * UI_SCALE)
SpinSpeedSlider.Position = UDim2.new(0, 5 * UI_SCALE, 0, 120 * UI_SCALE)
SpinSpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SpinSpeedSlider.ZIndex = 24
SpinSpeedSlider.Parent = AdvancedSettingsFrame

local SpinSpeedSliderCorner = Instance.new("UICorner")
SpinSpeedSliderCorner.CornerRadius = UDim.new(0, 10)
SpinSpeedSliderCorner.Parent = SpinSpeedSlider

local SpinSpeedFill = Instance.new("Frame")
SpinSpeedFill.Name = "SpinSpeedFill"
SpinSpeedFill.Size = UDim2.new(0.5, 0, 1, 0)
SpinSpeedFill.Position = UDim2.new(0, 0, 0, 0)
SpinSpeedFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
SpinSpeedFill.ZIndex = 25
SpinSpeedFill.Parent = SpinSpeedSlider

local SpinSpeedFillCorner = Instance.new("UICorner")
SpinSpeedFillCorner.CornerRadius = UDim.new(0, 10)
SpinSpeedFillCorner.Parent = SpinSpeedFill

local SpinSpeedValue = Instance.new("TextLabel")
SpinSpeedValue.Name = "SpinSpeedValue"
SpinSpeedValue.Size = UDim2.new(1, 0, 1, 0)
SpinSpeedValue.Position = UDim2.new(0, 0, 0, 0)
SpinSpeedValue.BackgroundTransparency = 1
SpinSpeedValue.Text = "50"
SpinSpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinSpeedValue.TextSize = 14 * UI_SCALE
SpinSpeedValue.Font = Enum.Font.GothamBold
SpinSpeedValue.ZIndex = 26
SpinSpeedValue.Parent = SpinSpeedSlider

-- 跳跃高度控制
local JumpHeightLabel = Instance.new("TextLabel")
JumpHeightLabel.Name = "JumpHeightLabel"
JumpHeightLabel.Size = UDim2.new(1, -10 * UI_SCALE, 0, 25 * UI_SCALE)
JumpHeightLabel.Position = UDim2.new(0, 5 * UI_SCALE, 0, 150 * UI_SCALE)
JumpHeightLabel.BackgroundTransparency = 1
JumpHeightLabel.Text = "跳跃高度: 50"
JumpHeightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpHeightLabel.TextSize = 16 * UI_SCALE
JumpHeightLabel.Font = Enum.Font.GothamSemibold
JumpHeightLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpHeightLabel.ZIndex = 24
JumpHeightLabel.Parent = AdvancedSettingsFrame

local JumpHeightSlider = Instance.new("Frame")
JumpHeightSlider.Name = "JumpHeightSlider"
JumpHeightSlider.Size = UDim2.new(1, -10 * UI_SCALE, 0, 20 * UI_SCALE)
JumpHeightSlider.Position = UDim2.new(0, 5 * UI_SCALE, 0, 180 * UI_SCALE)
JumpHeightSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
JumpHeightSlider.ZIndex = 24
JumpHeightSlider.Parent = AdvancedSettingsFrame

local JumpHeightSliderCorner = Instance.new("UICorner")
JumpHeightSliderCorner.CornerRadius = UDim.new(0, 10)
JumpHeightSliderCorner.Parent = JumpHeightSlider

local JumpHeightFill = Instance.new("Frame")
JumpHeightFill.Name = "JumpHeightFill"
JumpHeightFill.Size = UDim2.new(0.5, 0, 1, 0)
JumpHeightFill.Position = UDim2.new(0, 0, 0, 0)
JumpHeightFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
JumpHeightFill.ZIndex = 25
JumpHeightFill.Parent = JumpHeightSlider

local JumpHeightFillCorner = Instance.new("UICorner")
JumpHeightFillCorner.CornerRadius = UDim.new(0, 10)
JumpHeightFillCorner.Parent = JumpHeightFill

local JumpHeightValue = Instance.new("TextLabel")
JumpHeightValue.Name = "JumpHeightValue"
JumpHeightValue.Size = UDim2.new(1, 0, 1, 0)
JumpHeightValue.Position = UDim2.new(0, 0, 0, 0)
JumpHeightValue.BackgroundTransparency = 1
JumpHeightValue.Text = "50"
JumpHeightValue.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpHeightValue.TextSize = 14 * UI_SCALE
JumpHeightValue.Font = Enum.Font.GothamBold
JumpHeightValue.ZIndex = 26
JumpHeightValue.Parent = JumpHeightSlider

-- 穿墙功能
local NoclipToggle = Instance.new("TextButton")
NoclipToggle.Name = "NoclipToggle"
NoclipToggle.Size = UDim2.new(0.8, 0, 0, 40 * UI_SCALE)
NoclipToggle.Position = UDim2.new(0.1, 0, 0, 210 * UI_SCALE)
NoclipToggle.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
NoclipToggle.Text = "穿墙: 关闭"
NoclipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipToggle.TextSize = 16 * UI_SCALE
NoclipToggle.Font = Enum.Font.GothamBold
NoclipToggle.ZIndex = 24
NoclipToggle.Parent = AdvancedSettingsFrame

local NoclipCorner = Instance.new("UICorner")
NoclipCorner.CornerRadius = UDim.new(0, 10)
NoclipCorner.Parent = NoclipToggle

NoclipToggle.MouseEnter:Connect(function()
    TweenService:Create(NoclipToggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 100)}):Play()
end)

NoclipToggle.MouseLeave:Connect(function()
    TweenService:Create(NoclipToggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
end)

-- ===== DOORS页面 =====
local DoorsScriptButton = Instance.new("TextButton")
DoorsScriptButton.Name = "DoorsScriptButton"
DoorsScriptButton.Size = UDim2.new(0.9, 0, 0, 60 * UI_SCALE)
DoorsScriptButton.Position = UDim2.new(0.05, 0, 0.1, 0)
DoorsScriptButton.BackgroundColor3 = Color3.fromRGB(70, 30, 120)
DoorsScriptButton.Text = "DOORS脚本"
DoorsScriptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DoorsScriptButton.TextSize = 18 * UI_SCALE
DoorsScriptButton.Font = Enum.Font.GothamBold
DoorsScriptButton.ZIndex = 23
DoorsScriptButton.Parent = doorsPage

local DoorsScriptButtonCorner = Instance.new("UICorner")
DoorsScriptButtonCorner.CornerRadius = UDim.new(0, 10)
DoorsScriptButtonCorner.Parent = DoorsScriptButton

DoorsScriptButton.MouseEnter:Connect(function()
    TweenService:Create(DoorsScriptButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 50, 140)}):Play()
end)

DoorsScriptButton.MouseLeave:Connect(function()
    TweenService:Create(DoorsScriptButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 30, 120)}):Play()
end)

-- ===== 墨水游戏页面 =====
local InkGameButton = Instance.new("TextButton")
InkGameButton.Name = "InkGameButton"
InkGameButton.Size = UDim2.new(0.9, 0, 0, 60 * UI_SCALE)
InkGameButton.Position = UDim2.new(0.05, 0, 0.1, 0)
InkGameButton.BackgroundColor3 = Color3.fromRGB(30, 70, 120)
InkGameButton.Text = "墨水游戏脚本"
InkGameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InkGameButton.TextSize = 18 * UI_SCALE
InkGameButton.Font = Enum.Font.GothamBold
InkGameButton.ZIndex = 23
InkGameButton.Parent = inkGamePage

local InkGameButtonCorner = Instance.new("UICorner")
InkGameButtonCorner.CornerRadius = UDim.new(0, 10)
InkGameButtonCorner.Parent = InkGameButton

InkGameButton.MouseEnter:Connect(function()
    TweenService:Create(InkGameButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 90, 140)}):Play()
end)

InkGameButton.MouseLeave:Connect(function()
    TweenService:Create(InkGameButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 70, 120)}):Play()
end)

-- ===== 功能实现 =====
-- 飞行状态变量
local isFlying = false
local flySpeed = 16
local walkSpeed = 16
local bodyVelocity
local bodyGyro
local flightConnections = {}
local originalGravity
local originalAutoRotate
local originalAnimateScript

-- 旋转功能变量
local isSpinning = false
local spinSpeed = 50
local spinConnection

-- 穿墙功能变量
local isNoclip = false
local noclipConnection
local originalCollision = {}

-- 加载玩家头像
local function loadPlayerAvatar()
    local userId = tostring(player.UserId)
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    
    AvatarImage.Image = content
end

-- 更新UI显示
local function updateSpeedDisplays()
    FlightSpeedValue.Text = tostring(math.floor(flySpeed))
    FlightSpeedLabel.Text = "飞行速度: "..math.floor(flySpeed)
    FlightSpeedFill.Size = UDim2.new((flySpeed - 10) / 90, 0, 1, 0)
    
    WalkSpeedValue.Text = tostring(math.floor(walkSpeed))
    WalkSpeedLabel.Text = "行走速度: "..math.floor(walkSpeed)
    WalkSpeedFill.Size = UDim2.new((walkSpeed - 10) / 90, 0, 1, 0)
    
    -- 更新角色行走速度
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
    end
end

-- 更新旋转速度显示
local function updateSpinSpeedDisplay()
    SpinSpeedValue.Text = tostring(math.floor(spinSpeed))
    SpinSpeedLabel.Text = "旋转速度: "..math.floor(spinSpeed)
    SpinSpeedFill.Size = UDim2.new((spinSpeed - 10) / 90, 0, 1, 0)
end

-- 更新跳跃高度显示
local function updateJumpHeightDisplay()
    JumpHeightValue.Text = tostring(math.floor(jumpHeight))
    JumpHeightLabel.Text = "跳跃高度: "..math.floor(jumpHeight)
    JumpHeightFill.Size = UDim2.new((jumpHeight - 10) / 90, 0, 1, 0)
    
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid").JumpPower = jumpHeight
    end
end

-- 更新时间显示
local function updateTime()
    if TimeLabel then
        TimeLabel.Text = "当前时间: "..os.date("%H:%M:%S")
    end
end

-- 完全禁用动画
local function disableAnimations(character)
    if character then
        local animate = character:FindFirstChild("Animate")
        if animate then
            originalAnimateScript = animate:Clone()
            animate:Destroy()
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end

-- 恢复动画
local function restoreAnimations(character)
    if character and originalAnimateScript then
        local animate = character:FindFirstChild("Animate")
        if not animate then
            originalAnimateScript:Clone().Parent = character
        end
    end
end

-- 旋转功能
local function toggleSpin()
    isSpinning = not isSpinning
    SpinToggle.Text = "旋转: "..(isSpinning and "开启" or "关闭")
    
    if isSpinning then
        spinConnection = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed/10), 0)
            end
        end)
    else
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
    end
end

-- 穿墙功能
local function toggleNoclip()
    isNoclip = not isNoclip
    NoclipToggle.Text = "穿墙: "..(isNoclip and "开启" or "关闭")
    
    if isNoclip then
        -- 保存原始碰撞状态
        if player.Character then
            originalCollision = {}
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalCollision[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end
        
        -- 连接角色变化事件
        noclipConnection = player.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        -- 恢复原始碰撞状态
        if player.Character and originalCollision then
            for part, canCollide in pairs(originalCollision) do
                if part and part.Parent then
                    part.CanCollide = canCollide
                end
            end
        end
        
        -- 断开连接
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- 飞行功能
local function toggleFlight()
    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChildOfClass("Humanoid") do
        player.CharacterAdded:Wait()
        task.wait(0.1)
    end
    
    isFlying = not isFlying
    
    -- 更新UI状态
    BallText.Text = isFlying and "关闭" or "开启"
    FlightStatus.Text = "飞行: "..(isFlying and "开启" or "关闭")
    ToggleButton.Text = isFlying and "关闭飞行" or "开启飞行"
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = player.Character.HumanoidRootPart
    
    if isFlying then
        -- 保存原始状态
        originalGravity = workspace.Gravity
        originalAutoRotate = humanoid.AutoRotate
        
        -- 禁用自动旋转和摔落伤害
        humanoid.AutoRotate = false
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        
        -- 完全禁用所有动画
        disableAnimations(player.Character)
        
        -- 创建飞行所需的物理组件
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro = Instance.new("BodyGyro")
        
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.P = 1000
        
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 1000
        bodyGyro.D = 100
        bodyGyro.CFrame = humanoidRootPart.CFrame
        
        bodyVelocity.Parent = humanoidRootPart
        bodyGyro.Parent = humanoidRootPart
        
        -- 设置零重力
        workspace.Gravity = 0
        
        -- 连接输入事件
        table.insert(flightConnections, RunService.Heartbeat:Connect(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            
            local humanoidRootPart = player.Character.HumanoidRootPart
            local camera = workspace.CurrentCamera
            local cf = camera.CFrame
            
            -- 初始化移动方向
            local direction = Vector3.new()
            local isMoving = false
            
            -- 手机触摸控制
            if IS_MOBILE then
                -- 检测是否有触摸输入
                local isTouching = false
                for _, touch in ipairs(UserInputService:GetTouches()) do
                    isTouching = true
                    break
                end
                
                -- 只要有触摸就朝视角方向飞行
                if isTouching then
                    direction = cf.LookVector
                    isMoving = true
                end
                
                -- 检测屏幕右侧触摸（上升/下降）
                for _, touch in ipairs(UserInputService:GetTouches()) do
                    if touch.Position.X > GuiService:GetScreenResolution().X / 2 then
                        -- 触摸屏幕上半部分上升，下半部分下降
                        if touch.Position.Y < GuiService:GetScreenResolution().Y / 2 then
                            direction = direction + Vector3.new(0, 1, 0)
                        else
                            direction = direction - Vector3.new(0, 1, 0)
                        end
                        isMoving = true
                    end
                end
            else
                -- 键盘控制
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cf.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cf.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
            end
            
            -- 标准化方向并应用速度
            if direction.Magnitude > 0 then
                direction = direction.Unit * flySpeed
            else
                direction = Vector3.new(0, 0, 0)
            end
            
            -- 应用速度
            bodyVelocity.Velocity = direction
            bodyGyro.CFrame = camera.CFrame
            
            -- 强制保持直立姿势
            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, camera.CFrame.YAxis.Y, 0)
        end))
    else
        -- 关闭飞行
        workspace.Gravity = originalGravity or 196.2
        if humanoid then
            humanoid.AutoRotate = originalAutoRotate ~= nil and originalAutoRotate or true
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        end
        
        -- 恢复动画
        restoreAnimations(player.Character)
        
        -- 清理飞行组件
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        -- 断开所有飞行连接
        for _, connection in ipairs(flightConnections) do
            connection:Disconnect()
        end
        flightConnections = {}
    end
end

-- 速度滑块交互逻辑
local isDraggingFlightSpeed = false
local isDraggingWalkSpeed = false
local isDraggingSpinSpeed = false
local isDraggingJumpHeight = false

local function updateFlightSpeedFromInput(xPosition)
    local relativeX = xPosition - FlightSpeedSlider.AbsolutePosition.X
    local percentage = math.clamp(relativeX / FlightSpeedSlider.AbsoluteSize.X, 0, 1)
    flySpeed = math.floor(10 + (100 - 10) * percentage)
    
    updateSpeedDisplays()
    
    if isFlying and bodyVelocity then
        local currentVelocity = bodyVelocity.Velocity
        if currentVelocity.Magnitude > 0 then
            bodyVelocity.Velocity = currentVelocity.Unit * flySpeed
        end
    end
end

local function updateWalkSpeedFromInput(xPosition)
    local relativeX = xPosition - WalkSpeedSlider.AbsolutePosition.X
    local percentage = math.clamp(relativeX / WalkSpeedSlider.AbsoluteSize.X, 0, 1)
    walkSpeed = math.floor(10 + (100 - 10) * percentage)
    
    updateSpeedDisplays()
end

local function updateSpinSpeedFromInput(xPosition)
    local relativeX = xPosition - SpinSpeedSlider.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SpinSpeedSlider.AbsoluteSize.X, 0, 1)
    spinSpeed = math.floor(10 + (100 - 10) * percentage)
    
    updateSpinSpeedDisplay()
    
    if isSpinning and spinConnection then
        toggleSpin()
        toggleSpin()
    end
end

local function updateJumpHeightFromInput(xPosition)
    local relativeX = xPosition - JumpHeightSlider.AbsolutePosition.X
    local percentage = math.clamp(relativeX / JumpHeightSlider.AbsoluteSize.X, 0, 1)
    jumpHeight = math.floor(10 + (100 - 10) * percentage)
    
    updateJumpHeightDisplay()
end

FlightSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingFlightSpeed = true
        updateFlightSpeedFromInput(input.Position.X)
    end
end)

FlightSpeedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingFlightSpeed = false
    end
end)

WalkSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWalkSpeed = true
        updateWalkSpeedFromInput(input.Position.X)
    end
end)

WalkSpeedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWalkSpeed = false
    end
end)

SpinSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSpinSpeed = true
        updateSpinSpeedFromInput(input.Position.X)
    end
end)

SpinSpeedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSpinSpeed = false
    end
end)

JumpHeightSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingJumpHeight = true
        updateJumpHeightFromInput(input.Position.X)
    end
end)

JumpHeightSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingJumpHeight = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggingFlightSpeed then
            updateFlightSpeedFromInput(input.Position.X)
        elseif isDraggingWalkSpeed then
            updateWalkSpeedFromInput(input.Position.X)
        elseif isDraggingSpinSpeed then
            updateSpinSpeedFromInput(input.Position.X)
        elseif isDraggingJumpHeight then
            updateJumpHeightFromInput(input.Position.X)
        end
    end
end)

-- 按钮点击事件
ToggleButton.MouseButton1Click:Connect(toggleFlight)
SpinToggle.MouseButton1Click:Connect(toggleSpin)
NoclipToggle.MouseButton1Click:Connect(toggleNoclip)

DoorsScriptButton.MouseButton1Click:Connect(function()
    local originalText = DoorsScriptButton.Text
    DoorsScriptButton.Text = "加载中..."
    
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KINGHUB01/BlackKing/main/Blackking%20Game"))()
    end)
    
    if not success then
        warn("DOORS脚本加载失败: "..tostring(err))
        DoorsScriptButton.Text = "加载失败，点击重试"
    else
        DoorsScriptButton.Text = "已加载!"
        task.wait(1)
        DoorsScriptButton.Text = originalText
    end
end)

InkGameButton.MouseButton1Click:Connect(function()
    local originalText = InkGameButton.Text
    InkGameButton.Text = "加载中..."
    
    local success, err = pcall(function()
        loadstring("\u{006c}\u{006f}\u{0061}\u{0064}\u{0073}\u{0074}\u{0072}\u{0069}\u{006e}\u{0067}\u{0028}\u{0067}\u{0061}\u{006d}\u{0065}\u{003a}\u{0048}\u{0074}\u{0074}\u{0070}\u{0047}\u{0065}\u{0074}\u{0028}\u{0022}\u{0068}\u{0074}\u{0074}\u{0070}\u{0073}\u{003a}\u{002f}\u{002f}\u{0072}\u{0061}\u{0077}\u{002e}\u{0067}\u{0069}\u{0074}\u{0068}\u{0075}\u{0062}\u{0075}\u{0073}\u{0065}\u{0072}\u{0063}\u{006f}\u{006e}\u{0074}\u{0065}\u{006e}\u{0074}\u{002e}\u{0063}\u{006f}\u{006d}\u{002f}\u{004a}\u{0073}\u{0059}\u{0062}\u{0036}\u{0036}\u{0036}\u{002f}\u{0054}\u{0055}\u{0049}\u{0058}\u{0055}\u{0049}\u{005f}\u{0071}\u{0075}\u{006e}\u{002d}\u{0038}\u{0030}\u{0039}\u{0037}\u{0037}\u{0031}\u{0031}\u{0034}\u{0031}\u{002f}\u{0072}\u{0065}\u{0066}\u{0073}\u{002f}\u{0068}\u{0065}\u{0061}\u{0064}\u{0073}\u{002f}\u{0054}\u{0055}\u{0049}\u{0058}\u{0055}\u{0049}\u{002f}\u{004d}\u{0053}\u{0059}\u{0058}\u{0022}\u{0029}\u{0029}\u{0028}\u{0029}")()
    end)
    
    if not success then
        warn("墨水游戏脚本加载失败: "..tostring(err))
        InkGameButton.Text = "加载失败，点击重试"
    else
        InkGameButton.Text = "已加载!"
        task.wait(1)
        InkGameButton.Text = originalText
    end
end)

-- 分类按钮点击事件
homeButton.MouseButton1Click:Connect(function()
    homePage.Visible = true
    generalPage.Visible = false
    doorsPage.Visible = false
    inkGamePage.Visible = false
    updateTime()
end)

generalButton.MouseButton1Click:Connect(function()
    homePage.Visible = false
    generalPage.Visible = true
    doorsPage.Visible = false
    inkGamePage.Visible = false
    updateSpeedDisplays()
    updateSpinSpeedDisplay()
    updateJumpHeightDisplay()
end)

doorsButton.MouseButton1Click:Connect(function()
    homePage.Visible = false
    generalPage.Visible = false
    doorsPage.Visible = true
    inkGamePage.Visible = false
end)

inkGameButton.MouseButton1Click:Connect(function()
    homePage.Visible = false
    generalPage.Visible = false
    doorsPage.Visible = false
    inkGamePage.Visible = true
end)

-- 关闭按钮点击事件
CloseButton.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
    
    if MainPanel.Visible then
        -- 打开动画
        MainPanel.Size = UDim2.new(0, 0, 0, 0)
        MainPanel.Visible = true
        TweenService:Create(MainPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500 * UI_SCALE, 0, 400 * UI_SCALE)}):Play()
        
        homePage.Visible = true
        generalPage.Visible = false
        doorsPage.Visible = false
        inkGamePage.Visible = false
        updateTime()
    else
        -- 关闭动画
        TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.2)
        MainPanel.Visible = false
    end
end)

-- 悬浮球点击事件
FloatingBall.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
    
    if MainPanel.Visible then
        -- 打开动画
        MainPanel.Size = UDim2.new(0, 0, 0, 0)
        MainPanel.Visible = true
        TweenService:Create(MainPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500 * UI_SCALE, 0, 400 * UI_SCALE)}):Play()
        
        homePage.Visible = true
        generalPage.Visible = false
        doorsPage.Visible = false
        inkGamePage.Visible = false
        updateTime()
    else
        -- 关闭动画
        TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.2)
        MainPanel.Visible = false
    end
end)

-- 角色变化处理
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    updateSpeedDisplays()
    updateSpinSpeedDisplay()
    updateJumpHeightDisplay()
    
    if isFlying then
        task.spawn(function()
            task.wait(0.1)
            toggleFlight()
            toggleFlight()
        end)
    end
    
    if isNoclip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if isSpinning then
        task.spawn(function()
            task.wait(0.1)
            toggleSpin()
            toggleSpin()
        end)
    end
end)

-- 初始化UI
local function initializeUI()
    -- 加载玩家头像
    loadPlayerAvatar()
    
    -- 更新速度显示
    updateSpeedDisplays()
    updateSpinSpeedDisplay()
    updateJumpHeightDisplay()
    
    -- 初始角色处理
    if player.Character then
        if isFlying then
            isFlying = false
            toggleFlight()
        end
        if isSpinning then
            isSpinning = false
            toggleSpin()
        end
    end
    
    -- 确保主面板初始状态正确
    homePage.Visible = true
    generalPage.Visible = false
    doorsPage.Visible = false
    inkGamePage.Visible = false
    MainPanel.Visible = false
    MainPanel.Size = UDim2.new(0, 500 * UI_SCALE, 0, 400 * UI_SCALE)
end

-- 启动UI
task.spawn(function()
    initializeUI()
    
    -- 更新时间显示
    while true do
        updateTime()
        task.wait(1)
    end
end)
