import "Turbine.UI";
import "Turbine.UI.Lotro";

-- 1. Setup Display & Main Window Coordinates
local screenWidth = Turbine.UI.Display:GetWidth();
local screenHeight = Turbine.UI.Display:GetHeight();

local windowWidth = 420;
local windowHeight = 300;
local posX = (screenWidth - windowWidth) / 2;
local posY = screenHeight - windowHeight - 140; 

ControllerWindow = Turbine.UI.Window();
ControllerWindow:SetSize(windowWidth, windowHeight);
ControllerWindow:SetPosition(posX, posY);
ControllerWindow:SetVisible(true);
ControllerWindow:SetMouseVisible(true);

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

-- 3. Helper to Create Labelled Quickslots
function CreateButtonSlot(parent, x, y, labelText, labelColor)
    local container = Turbine.UI.Control();
    container:SetParent(parent);
    container:SetSize(45, 55);
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

    local label = Turbine.UI.Label();
    label:SetParent(container);
    label:SetSize(55, 15);
    label:SetPosition(-5, 38);
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
function BuildHotbarCluster(parentX, parentY, titleText, titleColor, tagPrefix)
    local clusterGroup = Turbine.UI.Control();
    clusterGroup:SetParent(ControllerWindow);
    clusterGroup:SetSize(190, 140);
    clusterGroup:SetPosition(parentX, parentY);

    local title = Turbine.UI.Label();
    title:SetParent(clusterGroup);
    title:SetSize(190, 18);
    title:SetPosition(0, 0);
    title:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    title:SetText(titleText);
    title:SetForeColor(titleColor);

    local pfx = (tagPrefix == "" and "" or tagPrefix .. " ");

    -- D-Pad Diamond
    CreateButtonSlot(clusterGroup, 32, 20,  pfx .. "D-Up", titleColor);
    CreateButtonSlot(clusterGroup, 0,  55,  pfx .. "D-L",  titleColor);
    CreateButtonSlot(clusterGroup, 64, 55,  pfx .. "D-R",  titleColor);
    CreateButtonSlot(clusterGroup, 32, 90,  pfx .. "D-Dn", titleColor);

    -- Face Button Diamond
    CreateButtonSlot(clusterGroup, 126, 20,  pfx .. "Y", titleColor);
    CreateButtonSlot(clusterGroup, 94,  55,  pfx .. "X", titleColor);
    CreateButtonSlot(clusterGroup, 158, 55,  pfx .. "B", titleColor);
    CreateButtonSlot(clusterGroup, 126, 90,  pfx .. "A", titleColor);

    return clusterGroup;
end

-- 5. Build 2x2 Grid Layout
BuildHotbarCluster(10,  0,   "[ BASE INPUTS ]", cyanColor, "");
BuildHotbarCluster(210, 0,   "[ LB MODIFIER ]", greenColor, "LB+");
BuildHotbarCluster(10,  150, "[ RB MODIFIER ]", orangeColor, "RB+");
BuildHotbarCluster(210, 150, "[ LB+RB COMBO ]", purpleColor, "L+R");

-- 6. Load Saved Skills on Startup
LoadQuickslots();

Turbine.Shell.WriteLine("Controller Hotbar Loaded with Auto-Save Enabled!");