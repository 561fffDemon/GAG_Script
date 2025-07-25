farm = nil
webhook_url = ""
autobuy = false
autoSell = false
waitTimeSell = 0
toCollect = {}
toCollectGear = {}

tw = game:GetService('TweenService')

for _,v in ipairs(workspace.Farm:GetChildren()) do
    if v.Important.Data.Owner.Value == game.Players.LocalPlayer.Name then
        farm = v
        break
    end
end

function collect()
    for _,v in ipairs(farm.Important.Plants_Physical:GetChildren()) do
        for __, plant in v:GetChildren() do
            if plant:FindFirstChild("ProximityPrompt") then
                tw:Create(game.Players.LocalPlayer.Character.HumanoidRootPart,
                TweenInfo.new(0.1), {
                    CFrame = CFrame.new(plant.Position)
                }):Play()
                wait(0.1)
                fireproximityprompt(plant.ProximityPrompt)
                
            end
        end
        if v:FindFirstChild("Fruits") then
            for ___, fruit in ipairs(v:FindFirstChild("Fruits"):GetChildren()) do
                for ____, el in ipairs(fruit:GetChildren()) do
                    if el:FindFirstChild("ProximityPrompt") then
                        tw:Create(game.Players.LocalPlayer.Character.HumanoidRootPart,
                        TweenInfo.new(0.1), {
                            CFrame = CFrame.new(el.Position)
                        }):Play()
                        wait(0.1)
                        fireproximityprompt(el.ProximityPrompt)
                    end
                end
            end
        end
    end

    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
end


function sendEmbedNotification(webhook, title,description)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = title,
                ["description"] = description,
                ["color"] = 0x4086ff,
            }
        }
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = webhook,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

if game.CoreGui:FindFirstChild('LuxtLibGrow a Garden') then
    game.CoreGui['LuxtLibGrow a Garden']:Destroy()
end

local Luxtl = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Luxware-UI-Library/main/Source.lua"))()

local Luxt = Luxtl.CreateWindow("Grow a Garden", 6105620301)

local Examples = Luxt:Tab("Global", 6087485864)
local creditsTab = Luxt:Tab("Credits")

local cf = creditsTab:Section("Main credit")

cf:Credit("KotdemontoK (KDT) | Codding of script")
local ff = Examples:Section("AutoBuy")
local ff1 = Examples:Section("AutoBuy Seeds List")
local ff2 = Examples:Section("AutoBuy Gears List")

ff:Button("Collect all", function()
    collect()
end)

ff:Toggle("Activate Autobuy", function(isToggled)
    autobuy = isToggled
    if #webhook_url > 0 then
        result = "enabled"
        if not isToggled then result = "disabled" end
        sendEmbedNotification(webhook_url,'Autobuy Function','Autobuy function for **`'..game.Players.LocalPlayer.DisplayName..'`** '..result.."!")
    end
end)

ff:Toggle("Activate AutoSell", function(isToggled)
    autoSell = isToggled
    if #webhook_url > 0 then
        result = "enabled"
        if not isToggled then result = "disabled" end
        sendEmbedNotification(webhook_url,'AutoSell Inventory','AutoSell Inv function for **`'..game.Players.LocalPlayer.DisplayName..'`** '..result.."!")
    end
end)
ff:Slider("Max Items to AutoSell", 0, 100, function(currentValue)
    waitTimeSell = currentValue 
end)
-- game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
ff:TextBox("Webhook Notification", "Webhook", function(getText)
    webhook_url = getText
end)

for _,v in ipairs(game.Players.LocalPlayer.PlayerGui.Seed_Shop.Frame.ScrollingFrame:GetChildren()) do
    if #v:GetChildren() > 0 then
        toCollect[v.Name] = false
        ff1:Toggle('Autobuy a '..v.Name, function(isToggled)
            print("Autobuy a "..v.Name.." is",isToggled)
            toCollect[v.Name] = isToggled
            if #webhook_url > 0 then
                txt = "**```"
                for i,v in pairs(toCollect) do
                    if v then
                        txt = txt..i.."\n"
                    end 
                end
                if #txt == 5 then txt = txt.."All\n" end
                txt = txt.."```**"
                sendEmbedNotification(webhook_url,'Autobuy Function','Autobuy list is changed:\n'..txt..'')
            end
        end)
    end
end

for _,v in ipairs(game.Players.LocalPlayer.PlayerGui.Gear_Shop.Frame.ScrollingFrame:GetChildren()) do
    if #v:GetChildren() > 0 then
        toCollectGear[v.Name] = false
        ff2:Toggle('Autobuy a '..v.Name, function(isToggled)
            print("Autobuy a "..v.Name.." is",isToggled)
            toCollectGear[v.Name] = isToggled
            if #webhook_url > 0 then
                txt = "**```"
                for i,v in pairs(toCollectGear) do
                    if v then
                        txt = txt..i.."\n"
                    end 
                end
                if #txt == 5 then txt = txt.."All\n" end
                txt = txt.."```**"
                sendEmbedNotification(webhook_url,'Autobuy Function','Autobuy list is changed:\n'..txt..'')
            end
        end)
    end
end
function detectStock(txt)
    if txt == 'NO STOCK' then return false else return true end    
end
function autocollect()
    if #game.Players.LocalPlayer.Backpack:GetChildren() >= waitTimeSell then
        if autoSell then
            local h = game.Players.LocalPlayer.Character.HumanoidRootPart
            oldPos = h.CFrame

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(87, 3, 0)
            wait(0.1)
            game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
            wait(0.1)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
        end
    end
end

function autoBuySeeds()
    for _,v in ipairs(game.Players.LocalPlayer.PlayerGui.Seed_Shop.Frame.ScrollingFrame:GetChildren()) do
        if #v:GetChildren() > 0 then
            if toCollect[v.Name] then
                if detectStock(v.Main_Frame.Cost_Text.text) then
                    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(v.Name)
                end
            end
        end
    end
end

function autoBuyGears()
    for _,v in ipairs(game.Players.LocalPlayer.PlayerGui.Gear_Shop.Frame.ScrollingFrame:GetChildren()) do
        if #v:GetChildren() > 0 then
            if toCollectGear[v.Name] then
                if detectStock(v.Main_Frame.Cost_Text.text) then
                    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(v.Name)
                end
            end
        end
    end
end

while wait() do
    if autobuy then
        autoBuySeeds()
        autoBuyGears()
    end
    autocollect()
end
