import "Turbine.UI";
import "Turbine.UI.Lotro";

-- Declare functions early so they are accessible everywhere in file scope
local UpdateBackdropOpacity;
local UpdateAuxOpacity;
local SavePluginData;
local LoadPluginData;
local RefreshLayoutIcons;
local showAuxPanel = true;

-- Active controller layout ("XBOX" or "PS")
local currentStyle = "XBOX";

-- Asset Directory Map
local Paths = {
    XBOX = "Patetine/ControllerMod/Icons/",
    PS   = "Patetine/ControllerMod/Icons/PS/"
}

-- 1. Setup Display & Main Window Coordinates
local screenWidth = Turbine.UI.Display:GetWidth();
local screenHeight = Turbine.UI.Display:GetHeight();

local windowWidth = 440;
local windowHeight = 320;

-- Default position: Center horizontally, sit 100px above bottom bar
local defaultX = (screenWidth - windowWidth) / 2;
local defaultY = screenHeight - windowHeight - 100; 

-- Dynamic Asset Maps
local function GetButtonIcons(style)
    local p = Paths[style] or Paths.XBOX;
    if style == "PS" then
        return {
            -- D-Pad (Indices 1 - 4)
            [1] = p .. "dpad_up.tga",
            [2] = p .. "dpad_down.tga",
            [3] = p .. "dpad_left.tga",
            [4] = p .. "dpad_right.tga",
            -- Face Buttons (Indices 5 - 8)
            [5] = p .. "btn_cross.tga",
            [6] = p .. "btn_circle.tga",
            [7] = p .. "btn_square.tga",
            [8] = p .. "btn_triangle.tga"
        };
    else
        return {
            -- D-Pad (Indices 1 - 4)
            [1] = p .. "dpad_up.tga",
            [2] = p .. "dpad_down.tga",
            [3] = p .. "dpad_left.tga",
            [4] = p .. "dpad_right.tga",
            -- Face Buttons (Indices 5 - 8)
            [5] = p .. "btn_a.tga",
            [6] = p .. "btn_b.tga",
            [7] = p .. "btn_x.tga",
            [8] = p .. "btn_y.tga"
        };
    end
end

local function GetHeaderIcons(style)
    local p = Paths[style] or Paths.XBOX;
    if style == "PS" then
        return {
            BASE = p .. "home.tga", -- Set to home.tga for PS Base Inputs
            LB   = p .. "hdr_l1.tga",
            RB   = p .. "hdr_r1.tga",
            LT   = p .. "hdr_l2.tga"
        };
    else
        return {
            BASE = p .. "hdr_base.tga",
            LB   = p .. "hdr_lb.tga",
            RB   = p .. "hdr_rb.tga",
            LT   = p .. "hdr_lt.tga"
        };
    end
end

local function GetAuxIcons(style)
    local p = Paths[style] or Paths.XBOX;
    if style == "PS" then
        return {
            RT   = p .. "r2.tga",
            LS   = p .. "l3.tga",
            RS   = p .. "r3.tga",
            VIEW = p .. "create.tga",
            MENU = p .. "options.tga"
        };
    else
        return {
            RT   = p .. "rt.tga",
            LS   = p .. "ls.tga",
            RS   = p .. "rs.tga",
            VIEW = p .. "view.tga",
            MENU = p .. "menu.tga"
        };
    end
end

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

-- Auxiliary Reference Window
AuxWindow = Turbine.UI.Window();
AuxWindow:SetSize(230, 230);
AuxWindow:SetPosition(ControllerWindow:GetLeft() + ControllerWindow:GetWidth() + 10, ControllerWindow:GetTop());
AuxWindow:SetVisible(showAuxPanel);

local auxBackdropPanel = Turbine.UI.Control();
auxBackdropPanel:SetParent(AuxWindow);
auxBackdropPanel:SetSize(230, 230);
auxBackdropPanel:SetPosition(0, 0);
auxBackdropPanel:SetMouseVisible(false);

local auxTop, auxBottom, auxLeft, auxRight = CreateUIFrame(auxBackdropPanel, 230, 230);

local auxTitle = Turbine.UI.Label();
auxTitle:SetParent(AuxWindow);
auxTitle:SetSize(230, 25);
auxTitle:SetPosition(0, 8);
auxTitle:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
auxTitle:SetText("[ SYSTEM & EXTRA ]");
auxTitle:SetForeColor(Turbine.UI.Color(1, 0.9, 0.8, 0.3));

-- Global reference tables for live layout swapping
local iconOverlayList = {};
local headerControlList = {};
local auxIconControls = {};
local auxLabelControls = {};

local function AddAuxRow(key, yPos, labelText, rowHeight)
    local h = rowHeight or 36;
    
    local icon = Turbine.UI.Control();
    icon:SetParent(AuxWindow);
    icon:SetSize(32, 32);
    icon:SetPosition(12, yPos);
    icon:SetStretchMode(0); -- Crisp 1:1 rendering
    
    local lbl = Turbine.UI.Label();
    lbl:SetParent(AuxWindow);
    lbl:SetSize(160, h);
    lbl:SetPosition(50, yPos);
    lbl:SetText(labelText);
    lbl:SetForeColor(Turbine.UI.Color(1, 0.85, 0.85, 0.85));

    auxIconControls[key] = icon;
    auxLabelControls[key] = lbl;
end

-- Render Aux Rows
AddAuxRow("RT",   35,  "Click", 28);
AddAuxRow("LS",   68,  "Target\n2x: Target object", 36);
AddAuxRow("RS",   108, "Camera", 28);
AddAuxRow("VIEW", 140, "Map\n2x: Journal | Hold: Char", 36);
AddAuxRow("MENU", 180, "Inventory\n2x: Skills | Hold: Menu", 36);

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

UpdateBackdropOpacity(currentOpacity);
UpdateAuxOpacity(currentAuxOpacity);

-- Live Layout Refresh Engine
RefreshLayoutIcons = function()
    local btnMap = GetButtonIcons(currentStyle);
    local hdrMap = GetHeaderIcons(currentStyle);
    local auxMap = GetAuxIcons(currentStyle);

    -- 1. Update 32 Quickslot Overlay Icons
    for idx, overlay in ipairs(iconOverlayList) do
        local btnIdx = ((idx - 1) % 8) + 1;
        overlay:SetBackground(nil);
        if btnMap[btnIdx] then
            pcall(function() overlay:SetBackground(btnMap[btnIdx]); end);
        end
    end

    -- 2. Update Cluster Header Icons (Set nil first to clear old images completely)
    for key, ctrl in pairs(headerControlList) do
        ctrl:SetBackground(nil);
        if hdrMap[key] then
            pcall(function() ctrl:SetBackground(hdrMap[key]); end);
        end
    end

    -- 3. Update Aux Icons
    for key, ctrl in pairs(auxIconControls) do
        ctrl:SetBackground(nil);
        if auxMap[key] then
            pcall(function() ctrl:SetBackground(auxMap[key]); end);
        end
    end

    -- 4. Update Aux Text Labels
    if currentStyle == "PS" then
        if auxLabelControls.RT then auxLabelControls.RT:SetText("Click"); end
        if auxLabelControls.LS then auxLabelControls.LS:SetText("Target\n2x: Target object"); end
        if auxLabelControls.RS then auxLabelControls.RS:SetText("Camera"); end
        if auxLabelControls.VIEW then auxLabelControls.VIEW:SetText("Map\n2x: Journal | Hold: Char"); end
        if auxLabelControls.MENU then auxLabelControls.MENU:SetText("Inventory\n2x: Skills | Hold: Menu"); end
    else
        if auxLabelControls.RT then auxLabelControls.RT:SetText("Click"); end
        if auxLabelControls.LS then auxLabelControls.LS:SetText("Target\n2x: Target object"); end
        if auxLabelControls.RS then auxLabelControls.RS:SetText("Camera"); end
        if auxLabelControls.VIEW then auxLabelControls.VIEW:SetText("Map\n2x: Journal | Hold: Char"); end
        if auxLabelControls.MENU then auxLabelControls.MENU:SetText("Inventory\n2x: Skills | Hold: Menu"); end
    end
end

-- 2. Persistence Engine
local quickslotsList = {};

SavePluginData = function()
    local left, top = ControllerWindow:GetPosition();
    local auxLeft, auxTop = AuxWindow:GetPosition();
    
    local saveData = {
        style = currentStyle,
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
        if (savedData.style) then
            currentStyle = savedData.style;
        end
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
    RefreshLayoutIcons();
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

    table.insert(iconOverlayList, iconOverlay);

    return qs;
end

local cyanColor   = Turbine.UI.Color(0.3, 0.8, 1.0);
local greenColor  = Turbine.UI.Color(0.4, 1.0, 0.4);
local orangeColor = Turbine.UI.Color(1.0, 0.6, 0.2);
local purpleColor = Turbine.UI.Color(0.8, 0.5, 1.0);

-- 4. Build Clusters
function BuildHotbarCluster(parentX, parentY, headerKey, fallbackText, titleColor)
    local clusterGroup = Turbine.UI.Control();
    clusterGroup:SetParent(ControllerWindow);
    clusterGroup:SetSize(200, 160);
    clusterGroup:SetPosition(parentX, parentY);
    clusterGroup:SetMouseVisible(false);

    -- Header Icon Control
    local headerIcon = Turbine.UI.Control();
    headerIcon:SetParent(clusterGroup);
    headerIcon:SetSize(32, 32);         
    headerIcon:SetPosition(84, 0);
    headerIcon:SetMouseVisible(false);
    headerIcon:SetStretchMode(1);
    
    headerControlList[headerKey] = headerIcon;

    -- D-PAD Cluster (Left Side -> Indices 1 to 4)
    CreateButtonSlot(clusterGroup, 34, 25, 1); -- D-Pad UP
    CreateButtonSlot(clusterGroup, 34, 97, 2); -- D-Pad DOWN
    CreateButtonSlot(clusterGroup, 2,  61, 3); -- D-Pad LEFT
    CreateButtonSlot(clusterGroup, 66, 61, 4); -- D-Pad RIGHT

    -- FACE BUTTON Cluster (Right Side -> Indices 5 to 8)
    CreateButtonSlot(clusterGroup, 134, 97, 5); -- A / Cross  (Bottom)
    CreateButtonSlot(clusterGroup, 166, 61, 6); -- B / Circle (Right)
    CreateButtonSlot(clusterGroup, 102, 61, 7); -- X / Square (Left)
    CreateButtonSlot(clusterGroup, 134, 25, 8); -- Y / Triangle (Top)

    return clusterGroup;
end

-- 5. Build Layout
BuildHotbarCluster(10,  0,   "LB",   "[ LB MODIFIER ]", greenColor);
BuildHotbarCluster(220, 0,   "RB",   "[ RB MODIFIER ]", orangeColor);
BuildHotbarCluster(10,  160, "LT",   "[ LT MODIFIER ]", purpleColor);
BuildHotbarCluster(220, 160, "BASE", "[ BASE INPUTS ]", cyanColor);

-- 6. Options Panel
local optionsPanel = Turbine.UI.Control();
optionsPanel:SetSize(400, 310);

local optionsTitle = Turbine.UI.Label();
optionsTitle:SetParent(optionsPanel);
optionsTitle:SetSize(400, 25);
optionsTitle:SetPosition(10, 10);
optionsTitle:SetText("Controller Hotbar Overlay Options");
optionsTitle:SetFont(Turbine.UI.Lotro.Font.TrajanPro18);
optionsTitle:SetForeColor(Turbine.UI.Color(1, 0.9, 0.2));

-- Controller Style Checkboxes (Mutually Exclusive)
local styleTitle = Turbine.UI.Label();
styleTitle:SetParent(optionsPanel);
styleTitle:SetSize(350, 20);
styleTitle:SetPosition(10, 45);
styleTitle:SetText("Controller Style:");
styleTitle:SetFont(Turbine.UI.Lotro.Font.Verdana14);

local xboxCheck = Turbine.UI.Lotro.CheckBox();
xboxCheck:SetParent(optionsPanel);
xboxCheck:SetPosition(10, 70);
xboxCheck:SetSize(120, 20);
xboxCheck:SetText(" Xbox / PC");

local psCheck = Turbine.UI.Lotro.CheckBox();
psCheck:SetParent(optionsPanel);
psCheck:SetPosition(140, 70);
psCheck:SetSize(120, 20);
psCheck:SetText(" PlayStation");

local updatingToggle = false;

xboxCheck.CheckedChanged = function()
    if updatingToggle then return end
    if xboxCheck:IsChecked() then
        updatingToggle = true;
        psCheck:SetChecked(false);
        updatingToggle = false;
        currentStyle = "XBOX";
        RefreshLayoutIcons();
        SavePluginData();
    elseif not psCheck:IsChecked() then
        -- Prevent unchecking both
        updatingToggle = true;
        xboxCheck:SetChecked(true);
        updatingToggle = false;
    end
end

psCheck.CheckedChanged = function()
    if updatingToggle then return end
    if psCheck:IsChecked() then
        updatingToggle = true;
        xboxCheck:SetChecked(false);
        updatingToggle = false;
        currentStyle = "PS";
        RefreshLayoutIcons();
        SavePluginData();
    elseif not xboxCheck:IsChecked() then
        -- Prevent unchecking both
        updatingToggle = true;
        psCheck:SetChecked(true);
        updatingToggle = false;
    end
end

-- Main Opacity Controls
local opacityLabel = Turbine.UI.Label();
opacityLabel:SetParent(optionsPanel);
opacityLabel:SetSize(350, 20);
opacityLabel:SetPosition(10, 105);
opacityLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);

local function UpdateSliderLabel(val)
    local pct = math.floor((val or 0.95) * 100);
    opacityLabel:SetText("Main Overlay Opacity: " .. tostring(pct) .. "%");
end

local slider = Turbine.UI.Lotro.ScrollBar();
slider:SetParent(optionsPanel);
slider:SetOrientation(Turbine.UI.Orientation.Horizontal);
slider:SetSize(250, 10);
slider:SetPosition(10, 130);
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
auxOpacityLabel:SetPosition(10, 155);
auxOpacityLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14);

local function UpdateAuxSliderLabel(val)
    local pct = math.floor((val or 0.95) * 100);
    auxOpacityLabel:SetText("Info Box Opacity: " .. tostring(pct) .. "%");
end

local auxSlider = Turbine.UI.Lotro.ScrollBar();
auxSlider:SetParent(optionsPanel);
auxSlider:SetOrientation(Turbine.UI.Orientation.Horizontal);
auxSlider:SetSize(250, 10);
auxSlider:SetPosition(10, 180);
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
auxCheckbox:SetPosition(10, 210);
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

-- 7. Load Saved Data & Sync Checkbox Controls
LoadPluginData();

updatingToggle = true;
if (xboxCheck ~= nil and psCheck ~= nil) then
    xboxCheck:SetChecked(currentStyle == "XBOX");
    psCheck:SetChecked(currentStyle == "PS");
end
updatingToggle = false;

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