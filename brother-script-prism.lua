-- [[ BROTHER SCRIPT: PRISM EDITION ]] --
-- UI: Modern/Sleek | Optimized for Delta Mobile | Kan Theara Exclusive

local function LoadBrotherScript()
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local Window = Fluent:CreateWindow({
        Title = "BROTHER SCRIPT",
        SubTitle = "Prism Edition",
        TabWidth = 160,
        Size = UDim2.fromOffset(450, 320),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Global Settings
    _G.AutoClick = false
    _G.LockPos = false
    _G.AutoStats = false
    _G.StatTarget = "Strength"
    _G.SkillsActive = {["Z"]=false, ["X"]=false, ["C"]=false, ["V"]=false, ["F"]=false}
    _G.SkillCDs = {["Z"]=5.0, ["X"]=8.0, ["C"]=12.0, ["V"]=15.0, ["F"]=25.0}

    -- 1. STYLISH FLOATING TOGGLE
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local ToggleBtn = Instance.new("TextButton", ScreenGui)
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "B"
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150) -- Neon Green for a "Modern" look
    ToggleBtn.TextSize = 28
    ToggleBtn.Draggable = true
    ToggleBtn.Active = true
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 50) -- Circular
    
    ToggleBtn.MouseButton1Click:Connect(function() Window:Minimize() end)

    -- 2. TABS
    local Tabs = {
        Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
        Timers = Window:AddTab({ Title = "Skill Timing", Icon = "timer" }),
        AutoStat = Window:AddTab({ Title = "Progression", Icon = "trending-up" }),
        Perf = Window:AddTab({ Title = "System", Icon = "cpu" })
    }

    -- 3. COMBAT TAB
    local CombatSection = Tabs.Combat:AddSection("Farming Tools")

    CombatSection:AddToggle("AutoM1", {Title = "Auto Clicker (M1)", Default = false}):OnChanged(function(v)
        _G.AutoClick = v
        task.spawn(function()
            while _G.AutoClick do
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 0)
                task.wait(0.4)
            end
        end)
    end)

    CombatSection:AddToggle("LockPos", {Title = "Lock Position (Anti-Knockback)", Default = false}):OnChanged(function(v)
        _G.LockPos = v
        local lp = game:GetService("Players").LocalPlayer
        if v and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local SavedCF = lp.Character.HumanoidRootPart.CFrame
            task.spawn(function()
                while _G.LockPos do
                    lp.Character.HumanoidRootPart.CFrame = SavedCF
                    lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    task.wait()
                end
            end)
        end
    end)

    -- 4. SKILL TIMING (+/- 0.25s)
    for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
        local Section = Tabs.Timers:AddSection("Skill " .. key)
        
        Section:AddToggle("Tog"..key, {Title = "Enable " .. key, Default = false}):OnChanged(function(v)
            _G.SkillsActive[key] = v
            if v then
                task.spawn(function()
                    local vim = game:GetService("VirtualInputManager")
                    while _G.SkillsActive[key] do
                        vim:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                        task.wait(0.2)
                        vim:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        task.wait(_G.SkillCDs[key] + (math.random(1, 4)/10))
                    end
                end)
            end
        end)

        local Label = Section:AddParagraph({Title = "Current Delay: " .. string.format("%.2f", _G.SkillCDs[key]) .. "s"})
        
        Section:AddButton({Title = "+ 0.25s", Callback = function() 
            _G.SkillCDs[key] = _G.SkillCDs[key] + 0.25 
            Label:SetTitle("Current Delay: " .. string.format("%.2f", _G.SkillCDs[key]) .. "s") 
        end})
        
        Section:AddButton({Title = "- 0.25s", Callback = function() 
            if _G.SkillCDs[key] > 0.25 then 
                _G.SkillCDs[key] = _G.SkillCDs[key] - 0.25 
                Label:SetTitle("Current Delay: " .. string.format("%.2f", _G.SkillCDs[key]) .. "s") 
            end 
        end})
    end

    -- 5. PROGRESSION (AUTO-STATS)
    Tabs.AutoStat:AddDropdown("StatSelect", {
        Title = "Stat Priority",
        Values = {"Strength", "Defense", "Sword", "Fruit"},
        Default = "Strength",
        Callback = function(v) _G.StatTarget = v end
    })

    Tabs.AutoStat:AddToggle("AutoStatTog", {Title = "Enable Auto-Stats", Default = false}):OnChanged(function(v)
        _G.AutoStats = v
        task.spawn(function()
            while _G.AutoStats do
                game:GetService("ReplicatedStorage").Events.Stats:FireServer(_G.StatTarget, 1)
                task.wait(1)
            end
        end)
    end)

    -- 6. SYSTEM (PERFORMANCE)
    Tabs.Perf:AddButton({Title = "Anti-Lag (Low GFX)", Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
    end})

    Tabs.Perf:AddButton({Title = "Server Hop", Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
    end})

    -- ANTI-AFK (Fixed & Stable)
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)

    Fluent:Notify({Title = "Brother Script", Content = "Prism v6 Loaded Successfully!", Duration = 5})
end

LoadBrotherScript()
