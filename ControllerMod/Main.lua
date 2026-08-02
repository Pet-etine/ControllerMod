import "Turbine.UI";
import "Turbine.UI.Lotro";

-- 1. Setup Display & Main Window Coordinates
local screenWidth = Turbine.UI.Display:GetWidth();
local screenHeight = Turbine.UI.Display:GetHeight();

local windowWidth = 440;
local windowHeight = 320;
local posX = (screenWidth - windowWidth) / 2;
local posY = screenHeight - windowHeight - 5; 

ControllerWindow = Turbine.UI.Window();
ControllerWindow:SetSize(windowWidth, windowHeight);
ControllerWindow:SetPosition(posX, posY);
ControllerWindow:SetVisible(true);
ControllerWindow:SetMouseVisible(true);

-- Dark Semi-Transparent Backdrop to cover native HUD elements underneath
ControllerWindow:SetBackColor(Turbine.UI.Color(0.95, 0.05, 0.05, 0.08)); 

-- Draggable Window Setup (Ctrl + Left Click Drag)
local dragging = false;
local startX, startY;

ControllerWindow.MouseDown = function(sender, args)
    if (args.Button == Turbine.UI.MouseButton.Left and ControllerWindow:IsControlKeyDown()) then
        dragging = true;
        startX = args.X;
        startY = args.Y;
    end
end

ControllerWindow.MouseMove = function(sender, args)
    if (dragging) then
        local left, top = ControllerWindow:GetPosition();
        ControllerWindow:SetPosition(left + (args.X - startX), top + (args.Y - startY));
    end
end

ControllerWindow.MouseUp = function(sender, args)
    if (args.Button == Turbine.UI.MouseButton.Left) then
        dragging = false;
    end
end

-- 2. Persistence Engine (Save / Load Logic)
local quickslotsList = {}; -- Stores references to all 32 quickslot objects

function SaveQuickslots()
    local saveData = {};
    for i, qs in ipairs(quickslotsList) do
        local shortcut = qs:GetShortcut();
        if (shortcut and shortcut:GetType() ~= Turbine.UI.Lotro.ShortcutType.None) then
            saveData[i] = {
                type = shortcut:GetType(),
                data = shortcut:GetData()
            };
        else
            saveData[i] = nil;
        end
    end
    -- Saves per-character in Documents/The Lord of the Rings Online/PluginData/
    Turbine.PluginData.Save(Turbine.DataScope.Character, "ControllerModData", saveData);
end

function LoadQuickslots()
    local savedData = Turbine.PluginData.Load(Turbine.DataScope.Character, "ControllerModData");
    if (savedData) then
        for i, data in pairs(savedData) do
            if (quickslotsList[i] and data.type and data.data) then
                pcall(function()
                    local sc = Turbine.UI.Lotro.Shortcut(data.type, data.data);
                    quickslotsList[i]:SetShortcut(sc);
                end);
            end
        end
    end
end

-- 3. Helper to Create Labelled Quickslots with High-Contrast Badges
function CreateButtonSlot(parent, x, y, labelText, labelColor)
    local container = Turbine.UI.Control();
    container:SetParent(parent);
    container:SetSize(45, 60);
    container:SetPosition(x, y);

    local qs = Turbine.UI.Lotro.Quickslot();
    qs:SetParent(container);
    qs:SetSize(36, 36);
    qs:SetPosition(4, 0);
    qs:SetVisible(true);

    -- Auto-save whenever a skill is dropped into or removed from this slot
    qs.ShortcutChanged = function()
        SaveQuickslots();
    end

    table.insert(quickslotsList, qs);

    -- Dark Background Badge Pill for High Contrast
    local badge = Turbine.UI.Control();
    badge:SetParent(container);
    badge:SetSize(36, 16);
    badge:SetPosition(4, 38);
    badge:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1));

    -- Clean Arrow / Face Button Label
    local label = Turbine.UI.Label();
    label:SetParent(badge);
    label:SetSize(36, 16);
    label:SetPosition(0, 0);
    label:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    label:SetText(labelText);
    label:SetForeColor(labelColor or Turbine.UI.Color(1, 0.9, 0.2));

    return qs;
end

-- Colors
local cyanColor   = Turbine.UI.Color(0.3, 0.8, 1.0); -- Base Inputs
local greenColor  = Turbine.UI.Color(0.4, 1.0, 0.4); -- LB Cluster
local orangeColor = Turbine.UI.Color(1.0, 0.6, 0.2); -- RB Cluster
local purpleColor = Turbine.UI.Color(0.8, 0.5, 1.0); -- LB+RB Combo

-- 4. Function to Build a Full Dual Diamond (D-Pad + Face Buttons)
function BuildHotbarCluster(parentX, parentY, titleText, titleColor)
    local clusterGroup = Turbine.UI.Control();
    clusterGroup:SetParent(ControllerWindow);
    clusterGroup:SetSize(200, 150);
    clusterGroup:SetPosition(parentX, parentY);
    -- Pass mouse clicks on empty cluster space through to the main window for dragging
    clusterGroup:SetMouseVisible(false);

    local title = Turbine.UI.Label();
    title:SetParent(clusterGroup);
    title:SetSize(200, 18);
    title:SetPosition(0, 0);
    title:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    title:SetText(titleText);
    title:SetForeColor(titleColor);

    -- D-Pad Diamond (Clean arrows: ↑, ←, →, ↓)
    CreateButtonSlot(clusterGroup, 34, 20,  "UP", titleColor);
    CreateButtonSlot(clusterGroup, 2,  56,  "LFT", titleColor);
    CreateButtonSlot(clusterGroup, 66, 56,  "RGT", titleColor);
    CreateButtonSlot(clusterGroup, 34, 92,  "DN", titleColor);

    -- Face Button Diamond (Y, X, B, A)
    CreateButtonSlot(clusterGroup, 134, 20,  "Y", titleColor);
    CreateButtonSlot(clusterGroup, 102, 56,  "X", titleColor);
    CreateButtonSlot(clusterGroup, 166, 56,  "B", titleColor);
    CreateButtonSlot(clusterGroup, 134, 92,  "A", titleColor);

    return clusterGroup;
end

-- 5. Build 2x2 Grid Layout
BuildHotbarCluster(10,  0,   "[ BASE INPUTS ]", cyanColor);
BuildHotbarCluster(220, 0,   "[ LB MODIFIER ]", greenColor);
BuildHotbarCluster(10,  155, "[ RB MODIFIER ]", orangeColor);
BuildHotbarCluster(220, 155, "[ LT MODIFIER ]", purpleColor);

-- 6. Load Saved Skills on Startup
LoadQuickslots();

Turbine.Shell.WriteLine("Controller Hotbar Overlay Updated!");