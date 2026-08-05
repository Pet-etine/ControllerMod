import "Turbine.UI";
import "Turbine.UI.Lotro";

-- Declare functions early so they are accessible everywhere in file scope
local UpdateBackdropOpacity;
local UpdateAuxOpacity;
local SavePluginData;
local LoadPluginData;
local showAuxPanel = true;

-- 1. Setup Display & Main Window Coordinates
local screenWidth = Turbine.UI.Display:GetWidth();
local screenHeight = Turbine.UI.Display:GetHeight();

local windowWidth = 440;
local windowHeight = 320;

-- Default position: Center horizontally, sit 100px above bottom bar
local defaultX = (screenWidth - windowWidth) / 2;
local defaultY = screenHeight - windowHeight - 100; 

-- Icon Texture Path Map (Relative to Plugins folder)
local ICON_PATH = "Patetine/ControllerMod/Icons/"

local ButtonIcons = {
    [1] = ICON_PATH .. "btn_a.tga",     -- Button 1 (A)
    [2] = ICON_PATH .. "btn_b.tga",     -- Button 2 (B)
    [3] = ICON_PATH .. "btn_x.tga",     -- Button 3 (X)
    [4] = ICON_PATH .. "btn_y.tga",     -- Button 4 (Y)
    [5] = ICON_PATH .. "dpad_up.tga",   -- Button 5 (D-Pad Up)
    [6] = ICON_PATH .. "dpad_down.tga", -- Button 6 (D-Pad Down)
    [7] = ICON_PATH .. "dpad_left.tga", -- Button 7 (D-Pad Left)
    [8] = ICON_PATH .. "dpad_right.tga" -- Button 8 (D-Pad Right)
}
local HeaderIcons = {
    BASE = ICON_PATH .. "hdr_base.tga",
    LB   = ICON_PATH .. "hdr_lb.tga",
    RB   = ICON_PATH .. "hdr_rb.tga",
    LT   = ICON_PATH .. "hdr_lt.tga"
}

ControllerWindow = Turbine.UI.Window();
ControllerWindow:SetSize(windowWidth, windowHeight);
ControllerWindow:SetPosition(defaultX, defaultY);
ControllerWindow:SetVisible(true);
ControllerWindow:SetMouseVisible(true);

-- Container for the main frame elements
local backdropPanel = Turbine.UI.Control();
backdropPanel:SetParent(ControllerWindow);
backdropPanel:SetSize(windowWidth, windowHeight);
backdropPanel:SetPosition(0, 0);
backdropPanel:SetMouseVisible(false);

local frameBorderThickness = 2;

-- Helper to create golden UI frame lines
local function CreateUIFrame(parent, width, height)
    local frameTop = Turbine.UI.Control();
    frameTop:SetParent(parent);
    frameTop:SetSize(width, frameBorderThickness);
    frameTop:SetPosition(0, 0);

    local frameBottom = Turbine.UI.Control();
    frameBottom:SetParent(parent);
    frameBottom:SetSize(width, frameBorderThickness);
    frameBottom:SetPosition(0, height - frameBorderThickness);

    local frameLeft = Turbine.UI.Control();
    frameLeft:SetParent(parent);
    frameLeft:SetSize(frameBorderThickness, height);
    frameLeft:SetPosition(0, 0);

    local frameRight = Turbine.UI.Control();
    frameRight:SetParent(parent);
    frameRight:SetSize(frameBorderThickness, height);
    frameRight:SetPosition(width - frameBorderThickness, 0);

    return frameTop, frameBottom, frameLeft, frameRight;
end

local mainTop, mainBottom, mainLeft, mainRight = CreateUIFrame(backdropPanel, windowWidth, windowHeight);

-- Default opacity values
local currentOpacity = 0.95;
local currentAuxOpacity = 0.95;

-- Auxiliary Reference Window (Sticks, View, Menu, RT)
AuxWindow = Turbine.UI.Window();
AuxWindow:SetSize(220, 220); -- Resized to accommodate extra binding detail
AuxWindow:SetPosition(ControllerWindow:GetLeft() + ControllerWindow:GetWidth() + 10, ControllerWindow:GetTop());
AuxWindow:SetVisible(showAuxPanel);

local auxBackdropPanel = Turbine.UI.Control();
auxBackdropPanel:SetParent(AuxWindow);
auxBackdropPanel:SetSize(220, 220);
auxBackdropPanel:SetPosition(0, 0);
auxBackdropPanel:SetMouseVisible(false);

local auxTop, auxBottom, auxLeft, auxRight = CreateUIFrame(auxBackdropPanel, 220, 220);

local auxTitle = Turbine.UI.Label();
auxTitle:SetParent(AuxWindow);
auxTitle:SetSize(220, 25);
auxTitle:SetPosition(0, 8);
auxTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
auxTitle:SetText("[ SYSTEM & EXTRA ]");
auxTitle:SetForeColor(Turbine.UI.Color(1, 0.9, 0.8, 0.3));

-- Auxiliary Texture Map
local AuxIcons = {
    RT   = ICON_PATH .. "rt.tga",
    LS   = ICON_PATH .. "ls.tga",
    RS   = ICON_PATH .. "rs.tga",
    VIEW = ICON_PATH .. "view.tga",
    MENU = ICON_PATH .. "menu.tga"
}

local function AddAuxRow(yPos, iconPath, labelText, rowHeight)
    local h = rowHeight or 36;
    
    -- Icon Container (32x32 bounding box)
    local icon = Turbine.UI.Control();
    icon:SetParent(AuxWindow);
    icon:SetSize(32, 32);
    icon:SetPosition(12, yPos);
    
    -- Disable forced stretching so textures render crisp without edge clipping
    icon:SetStretchMode(0);
    
    if (type(iconPath) == "string" and iconPath ~= "") then
        local success = pcall(function()
            icon:SetBackground(iconPath);
        end);
        if not success then
            icon:SetBackColor(Turbine.UI.Color(0.3, 0.3, 0.3));
        end
    end

    -- Label Container (Offset to the right to accommodate 32px icons)
    local lbl = Turbine.UI.Label();
    lbl:SetParent(AuxWindow);
    lbl:SetSize(160, h);
    lbl:SetPosition(50, yPos);
    lbl:SetText(labelText);
    lbl:SetForeColor(Turbine.UI.Color(1, 0.85, 0.85, 0.85));
end

-- Render Rows with adjusted vertical spacing
AddAuxRow(35,  AuxIcons.RT,   "Click", 28);
AddAuxRow(68,  AuxIcons.LS,   "Target\n2x: Target object", 36);
AddAuxRow(108, AuxIcons.RS,   "Camera", 28);
AddAuxRow(140, AuxIcons.VIEW, "Map\n2x: Journal | Hold: Char", 36);
AddAuxRow(180, AuxIcons.MENU, "Inventory\n2x: Skills | Hold: Menu", 36);

-- Opacity Controllers
UpdateBackdropOpacity = function(alpha)
    currentOpacity = alpha;
    ControllerWindow:SetBackColor(Turbine.UI.Color(currentOpacity, 0.05, 0.05, 0.08));
    
    local frameColor = Turbine.UI.Color(currentOpacity, 0.8, 0.6, 0.2);
    if (mainTop) then
        mainTop:SetBackColor(frameColor);
        mainBottom:SetBackColor(frameColor);
        mainLeft:SetBackColor(frameColor);
        mainRight:SetBackColor(frameColor);
    end
end

UpdateAuxOpacity = function(alpha)
    currentAuxOpacity = alpha;
    AuxWindow:SetBackColor(Turbine.UI.Color(currentAuxOpacity, 0.05, 0.05, 0.08));
    
    local frameColor = Turbine.UI.Color(currentAuxOpacity, 0.8, 0.6, 0.2);
    if (auxTop) then
        auxTop:SetBackColor(frameColor);
        auxBottom:SetBackColor(frameColor);
        auxLeft:SetBackColor(frameColor);
        auxRight:SetBackColor(frameColor);
    end
end

-- Apply initial opacities
UpdateBackdropOpacity(currentOpacity);
UpdateAuxOpacity(currentAuxOpacity);

-- 2. Persistence Engine
local quickslotsList = {};

SavePluginData = function()
    local left, top = ControllerWindow:GetPosition();
    local auxLeft, auxTop = AuxWindow:GetPosition();
    
    local saveData = {
        opacity = currentOpacity,
        auxOpacity = currentAuxOpacity,
        x = left,
        y = top,
        auxX = auxLeft,
        auxY = auxTop,
        showAux = showAuxPanel,
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
        if (savedData.opacity) then
            UpdateBackdropOpacity(savedData.opacity);
        end
        if (savedData.auxOpacity) then
            UpdateAuxOpacity(savedData.auxOpacity);
        end
        
        if (savedData.x and savedData.y) then
            ControllerWindow:SetPosition(savedData.x, savedData.y);
        end
        
        if (savedData.auxX and savedData.auxY) then
            AuxWindow:SetPosition(savedData.auxX, savedData.auxY);
        elseif (savedData.x and savedData.y) then
            AuxWindow:SetPosition(savedData.x + ControllerWindow:GetWidth() + 10, savedData.y);
        end
        
        if (savedData.showAux ~= nil) then
            showAuxPanel = savedData.showAux;
            AuxWindow:SetVisible(showAuxPanel);
        end
        
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

-- Draggable Windows
local draggingMain = false;
local mainStartX, mainStartY;

ControllerWindow.MouseDown = function(sender, args)
    if (args.Button == Turbine.UI.MouseButton.Left and ControllerWindow:IsControlKeyDown()) then
        draggingMain = true;
        mainStartX = args.X;
        mainStartY = args.Y;
    end
end

ControllerWindow.MouseMove = function(sender, args)
    if (draggingMain) then
        local left, top = ControllerWindow:GetPosition();
        ControllerWindow:SetPosition(left + (args.X - mainStartX), top + (args.Y - mainStartY));
    end
end

ControllerWindow.MouseUp = function(sender, args)
    if (args.Button == Turbine.UI.MouseButton.Left and draggingMain) then
        draggingMain = false;
        SavePluginData();
    end
end

local draggingAux = false;
local auxStartX, auxStartY;

AuxWindow.MouseDown = function(sender, args)
    if (args.Button == Turbine.UI.MouseButton.Left and AuxWindow:IsControlKeyDown()) then
        draggingAux = true;
        auxStartX = args.X;
        auxStartY = args.Y;
    end
end

AuxWindow.MouseMove = function(sender, args)
    if (draggingAux) then
        local left, top = AuxWindow:GetPosition();
        AuxWindow:SetPosition(left + (args.X - auxStartX), top + (args.Y - auxStartY));
    end
end

AuxWindow.MouseUp = function(sender, args)
    if (args.Button == Turbine.UI.MouseButton.Left and draggingAux) then
        draggingAux = false;
        SavePluginData();
    end
end

-- 3. Quickslot Creation
function CreateButtonSlot(parent, x, y, buttonIndex)
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

    local iconOverlay = Turbine.UI.Control();
    iconOverlay:SetParent(container);
    iconOverlay:SetSize(28, 28); 
    iconOverlay:SetPosition(8, 36); 
    iconOverlay:SetMouseVisible(false);
    iconOverlay:SetStretchMode(1);

    local iconPath = ButtonIcons[buttonIndex];
    if (iconPath) then
        iconOverlay:SetBackground(iconPath);
    end

    return qs;
end

local cyanColor   = Turbine.UI.Color(0.3, 0.8, 1.0);
local greenColor  = Turbine.UI.Color(0.4, 1.0, 0.4);
local orangeColor = Turbine.UI.Color(1.0, 0.6, 0.2);
local purpleColor = Turbine.UI.Color(0.8, 0.5, 1.0);

-- 4. Build Clusters
function BuildHotbarCluster(parentX, parentY, headerTexture, fallbackText, titleColor)
    local clusterGroup = Turbine.UI.Control();
    clusterGroup:SetParent(ControllerWindow);
    clusterGroup:SetSize(200, 160);
    clusterGroup:SetPosition(parentX, parentY);
    clusterGroup:SetMouseVisible(false);

    if (headerTexture) then
        local headerIcon = Turbine.UI.Control();
        headerIcon:SetParent(clusterGroup);
        headerIcon:SetSize(24, 24);         
        headerIcon:SetPosition(88, 0);
        headerIcon:SetMouseVisible(false);
        headerIcon:SetStretchMode(1);
        headerIcon:SetBackground(headerTexture);
    else
        local title = Turbine.UI.Label();
        title:SetParent(clusterGroup);
        title:SetSize(200, 18);
        title:SetPosition(0, 0);
        title:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
        title:SetText(fallbackText);
        title:SetForeColor(titleColor);
    end

    CreateButtonSlot(clusterGroup, 34, 25, 5); -- UP
    CreateButtonSlot(clusterGroup, 34, 97, 6); -- DOWN
    CreateButtonSlot(clusterGroup, 2,  61, 7); -- LEFT
    CreateButtonSlot(clusterGroup, 66, 61, 8); -- RIGHT

    CreateButtonSlot(clusterGroup, 134, 97, 1); -- A
    CreateButtonSlot(clusterGroup, 166, 61, 2); -- B
    CreateButtonSlot(clusterGroup, 102, 61, 3); -- X
    CreateButtonSlot(clusterGroup, 134, 25, 4); -- Y

    return clusterGroup;
end

-- 5. Build Layout
BuildHotbarCluster(10,  0,   HeaderIcons.LB,   "[ LB MODIFIER ]", greenColor);
BuildHotbarCluster(220, 0,   HeaderIcons.RB,   "[ RB MODIFIER ]", orangeColor);
BuildHotbarCluster(10,  160, HeaderIcons.LT,   "[ LT MODIFIER ]", purpleColor);
BuildHotbarCluster(220, 160, HeaderIcons.BASE, "[ BASE INPUTS ]", cyanColor);

-- 6. Options Panel
local optionsPanel = Turbine.UI.Control();
optionsPanel:SetSize(400, 260);

local optionsTitle = Turbine.UI.Label();
optionsTitle:SetParent(optionsPanel);
optionsTitle:SetSize(400, 25);
optionsTitle:SetPosition(10, 10);
optionsTitle:SetText("Controller Hotbar Overlay Options");
optionsTitle:SetFont(Turbine.UI.Lotro.Font.TrajanPro18);
optionsTitle:SetForeColor(Turbine.UI.Color(1, 0.9, 0.2));

-- Main Opacity Controls
local opacityLabel = Turbine.UI.Label();
opacityLabel:SetParent(optionsPanel);
opacityLabel:SetSize(350, 20);
opacityLabel:SetPosition(10, 45);
opacityLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);

local function UpdateSliderLabel(val)
    local pct = math.floor((val or 0.95) * 100);
    opacityLabel:SetText("Main Overlay Opacity: " .. tostring(pct) .. "%");
end

local slider = Turbine.UI.Lotro.ScrollBar();
slider:SetParent(optionsPanel);
slider:SetOrientation(Turbine.UI.Orientation.Horizontal);
slider:SetSize(250, 10);
slider:SetPosition(10, 70);
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

-- Aux Opacity Controls
local auxOpacityLabel = Turbine.UI.Label();
auxOpacityLabel:SetParent(optionsPanel);
auxOpacityLabel:SetSize(350, 20);
auxOpacityLabel:SetPosition(10, 95);
auxOpacityLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);

local function UpdateAuxSliderLabel(val)
    local pct = math.floor((val or 0.95) * 100);
    auxOpacityLabel:SetText("Info Box Opacity: " .. tostring(pct) .. "%");
end

local auxSlider = Turbine.UI.Lotro.ScrollBar();
auxSlider:SetParent(optionsPanel);
auxSlider:SetOrientation(Turbine.UI.Orientation.Horizontal);
auxSlider:SetSize(250, 10);
auxSlider:SetPosition(10, 120);
auxSlider:SetMinimum(0);
auxSlider:SetMaximum(100);
auxSlider:SetSmallChange(1);
auxSlider:SetLargeChange(10);
auxSlider:SetValue(math.floor(currentAuxOpacity * 100));

UpdateAuxSliderLabel(currentAuxOpacity);

auxSlider.ValueChanged = function()
    local newOpacity = auxSlider:GetValue() / 100;
    UpdateAuxOpacity(newOpacity);
    UpdateAuxSliderLabel(newOpacity);
    SavePluginData();
end

-- Auxiliary Panel Toggle Checkbox
local auxCheckbox = Turbine.UI.Lotro.CheckBox();
auxCheckbox:SetParent(optionsPanel);
auxCheckbox:SetPosition(10, 150);
auxCheckbox:SetSize(250, 20);
auxCheckbox:SetText(" Show Utility Info Box");
auxCheckbox:SetChecked(showAuxPanel);

auxCheckbox.CheckedChanged = function()
    showAuxPanel = auxCheckbox:IsChecked();
    AuxWindow:SetVisible(showAuxPanel);
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

-- Sync UI state
if (slider ~= nil) then
    slider:SetValue(math.floor(currentOpacity * 100));
end
if (auxSlider ~= nil) then
    auxSlider:SetValue(math.floor(currentAuxOpacity * 100));
end
if (auxCheckbox ~= nil) then
    auxCheckbox:SetChecked(showAuxPanel);
end

Turbine.Shell.WriteLine("Controller Hotbar Loaded with Options!");