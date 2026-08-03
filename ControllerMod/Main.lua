import "Turbine.UI";
import "Turbine.UI.Lotro";

-- Declare functions early so they are accessible everywhere in file scope
local UpdateBackdropOpacity;
local SavePluginData;
local LoadPluginData;

-- 1. Setup Display & Main Window Coordinates
local screenWidth = Turbine.UI.Display:GetWidth();
local screenHeight = Turbine.UI.Display:GetHeight();

local windowWidth = 440;
local windowHeight = 320;

-- Default position: Center horizontally, sit 100px above bottom bar
local defaultX = (screenWidth - windowWidth) / 2;
local defaultY = screenHeight - windowHeight - 100; 

ControllerWindow = Turbine.UI.Window();
ControllerWindow:SetSize(windowWidth, windowHeight);
ControllerWindow:SetPosition(defaultX, defaultY);
ControllerWindow:SetVisible(true);
ControllerWindow:SetMouseVisible(true);

-- Container for the frame elements
local backdropPanel = Turbine.UI.Control();
backdropPanel:SetParent(ControllerWindow);
backdropPanel:SetSize(windowWidth, windowHeight);
backdropPanel:SetPosition(0, 0);
backdropPanel:SetMouseVisible(false);

local frameBorderThickness = 2;
local frameTop, frameBottom, frameLeft, frameRight;

-- Create Frame Lines inside the container
local function CreateUIFrame(parent, width, height)
    -- Top Border
    frameTop = Turbine.UI.Control();
    frameTop:SetParent(parent);
    frameTop:SetSize(width, frameBorderThickness);
    frameTop:SetPosition(0, 0);

    -- Bottom Border
    frameBottom = Turbine.UI.Control();
    frameBottom:SetParent(parent);
    frameBottom:SetSize(width, frameBorderThickness);
    frameBottom:SetPosition(0, height - frameBorderThickness);

    -- Left Border
    frameLeft = Turbine.UI.Control();
    frameLeft:SetParent(parent);
    frameLeft:SetSize(frameBorderThickness, height);
    frameLeft:SetPosition(0, 0);

    -- Right Border
    frameRight = Turbine.UI.Control();
    frameRight:SetParent(parent);
    frameRight:SetSize(frameBorderThickness, height);
    frameRight:SetPosition(width - frameBorderThickness, 0);
end

CreateUIFrame(backdropPanel, windowWidth, windowHeight);

-- Default opacity value
local currentOpacity = 0.95;

UpdateBackdropOpacity = function(alpha)
    currentOpacity = alpha;
    
    -- Main background fill
    ControllerWindow:SetBackColor(Turbine.UI.Color(currentOpacity, 0.05, 0.05, 0.08));
    
    -- Frame lines fade synchronously with the background opacity
    local frameColor = Turbine.UI.Color(currentOpacity, 0.8, 0.6, 0.2);
    if (frameTop) then
        frameTop:SetBackColor(frameColor);
        frameBottom:SetBackColor(frameColor);
        frameLeft:SetBackColor(frameColor);
        frameRight:SetBackColor(frameColor);
    end
end

-- Apply initial opacity to both backdrop and frame
UpdateBackdropOpacity(currentOpacity);

-- 2. Persistence Engine (Save Position + Quickslots)
local quickslotsList = {}; -- Stores references to all 32 quickslot objects

SavePluginData = function()
    local left, top = ControllerWindow:GetPosition();
    local saveData = {
        opacity = currentOpacity,
        x = left,
        y = top,
        slots = {}
    };
    for i, qs in ipairs(quickslotsList) do
        local shortcut = qs:GetShortcut();
        if (shortcut and shortcut:GetType() ~= Turbine.UI.Lotro.ShortcutType.None) then
            saveData.slots[i] = {
                type = shortcut:GetType(),
                data = shortcut:GetData()
            };
        end
    end
    Turbine.PluginData.Save(Turbine.DataScope.Character, "ControllerModData", saveData);
end

LoadPluginData = function()
    local savedData = Turbine.PluginData.Load(Turbine.DataScope.Character, "ControllerModData");
    if (type(savedData) == "table") then
        -- Restore saved opacity
        if (savedData.opacity) then
            UpdateBackdropOpacity(savedData.opacity);
        end
        
        -- Restore saved window position
        if (savedData.x and savedData.y) then
            ControllerWindow:SetPosition(savedData.x, savedData.y);
        end
        
        -- Restore saved quickslot shortcuts
        local slotsData = savedData.slots or savedData;
        if (type(slotsData) == "table") then
            for i, data in pairs(slotsData) do
                if (quickslotsList[i] and type(data) == "table" and data.type and data.data) then
                    pcall(function()
                        local sc = Turbine.UI.Lotro.Shortcut(data.type, data.data);
                        quickslotsList[i]:SetShortcut(sc);
                    end);
                end
            end
        end
    end
end

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
        if (dragging) then
            dragging = false;
            SavePluginData(); -- Save position as soon as drag finishes
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

    qs.ShortcutChanged = function()
        SavePluginData();
    end

    table.insert(quickslotsList, qs);

    local badge = Turbine.UI.Control();
    badge:SetParent(container);
    badge:SetSize(36, 16);
    badge:SetPosition(4, 38);
    badge:SetBackColor(Turbine.UI.Color(0.1, 0.1, 0.1));

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
local cyanColor   = Turbine.UI.Color(0.3, 0.8, 1.0);
local greenColor  = Turbine.UI.Color(0.4, 1.0, 0.4);
local orangeColor = Turbine.UI.Color(1.0, 0.6, 0.2);
local purpleColor = Turbine.UI.Color(0.8, 0.5, 1.0);

-- 4. Function to Build Hotbar Clusters
function BuildHotbarCluster(parentX, parentY, titleText, titleColor)
    local clusterGroup = Turbine.UI.Control();
    clusterGroup:SetParent(ControllerWindow);
    clusterGroup:SetSize(200, 150);
    clusterGroup:SetPosition(parentX, parentY);
    clusterGroup:SetMouseVisible(false);

    local title = Turbine.UI.Label();
    title:SetParent(clusterGroup);
    title:SetSize(200, 18);
    title:SetPosition(0, 0);
    title:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    title:SetText(titleText);
    title:SetForeColor(titleColor);

    -- D-Pad
    CreateButtonSlot(clusterGroup, 34, 20,  "UP",  titleColor);
    CreateButtonSlot(clusterGroup, 2,  56,  "LFT", titleColor);
    CreateButtonSlot(clusterGroup, 66, 56,  "RGT", titleColor);
    CreateButtonSlot(clusterGroup, 34, 92,  "DN",  titleColor);

    -- Face Buttons
    CreateButtonSlot(clusterGroup, 134, 20,  "Y", titleColor);
    CreateButtonSlot(clusterGroup, 102, 56,  "X", titleColor);
    CreateButtonSlot(clusterGroup, 166, 56,  "B", titleColor);
    CreateButtonSlot(clusterGroup, 134, 92,  "A", titleColor);

    return clusterGroup;
end

-- 5. Build Layout
BuildHotbarCluster(10,  0,   "[ BASE INPUTS ]", cyanColor);
BuildHotbarCluster(220, 0,   "[ LB MODIFIER ]", greenColor);
BuildHotbarCluster(10,  155, "[ RB MODIFIER ]", orangeColor);
BuildHotbarCluster(220, 155, "[ LT MODIFIER ]", purpleColor);

-- 6. Options Panel Engine with Slider
local optionsPanel = Turbine.UI.Control();
optionsPanel:SetSize(400, 200);

local optionsTitle = Turbine.UI.Label();
optionsTitle:SetParent(optionsPanel);
optionsTitle:SetSize(400, 25);
optionsTitle:SetPosition(10, 10);
optionsTitle:SetText("Controller Hotbar Overlay Options");
optionsTitle:SetFont(Turbine.UI.Lotro.Font.TrajanPro18);
optionsTitle:SetForeColor(Turbine.UI.Color(1, 0.9, 0.2));

-- Slider Value Label
local opacityLabel = Turbine.UI.Label();
opacityLabel:SetParent(optionsPanel);
opacityLabel:SetSize(350, 20);
opacityLabel:SetPosition(10, 45);
opacityLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);

local function UpdateSliderLabel(val)
    local pct = math.floor((val or 0.95) * 100);
    opacityLabel:SetText("Backdrop Opacity: " .. tostring(pct) .. "%");
end

-- LOTRO Horizontal Scrollbar acting as a Opacity Slider
local slider = Turbine.UI.Lotro.ScrollBar();
slider:SetParent(optionsPanel);
slider:SetOrientation(Turbine.UI.Orientation.Horizontal);
slider:SetSize(250, 10);
slider:SetPosition(10, 75);
slider:SetMinimum(0);
slider:SetMaximum(100);
slider:SetSmallChange(1);
slider:SetLargeChange(10);
slider:SetValue(math.floor(currentOpacity * 100));

UpdateSliderLabel(currentOpacity);

slider.ValueChanged = function()
    local newOpacity = slider:GetValue() / 100;
    UpdateBackdropOpacity(newOpacity);
    UpdateSliderLabel(newOpacity);
    SavePluginData();
end

-- Register Options Panel
if (plugin ~= nil) then
    plugin.GetOptionsPanel = function()
        return optionsPanel;
    end
else
    Plugins["ControllerMod"].GetOptionsPanel = function()
        return optionsPanel;
    end
end

-- 7. Load Saved Data
LoadPluginData();

-- Sync slider position with loaded opacity
if (slider ~= nil) then
    slider:SetValue(math.floor(currentOpacity * 100));
end

Turbine.Shell.WriteLine("Controller Hotbar Loaded with Slider Options!");