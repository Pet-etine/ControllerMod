function CreateImageSlot(parent, x, y, imageFileName, iconColor)
    local container = Turbine.UI.Control();
    container:SetParent(parent);
    -- Increase size slightly for the diagnostic label
    container:SetSize(45, 78); 
    container:SetPosition(x, y);

    -- Quickslot
    local qs = Turbine.UI.Lotro.Quickslot();
    qs:SetParent(container);
    qs:SetSize(36, 36);
    qs:SetPosition(4, 0);
    qs:SetVisible(true);

    qs.ShortcutChanged = function()
        SaveQuickslots();
    end

    table.insert(quickslotsList, qs);

    -- [DIAGNOSTIC LABEL] - Shows if the code is running
    local diagLabel = Turbine.UI.Label();
    diagLabel:SetParent(container);
    diagLabel:SetSize(40, 16);
    diagLabel:SetPosition(2, 38);
    diagLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
    diagLabel:SetText(imageFileName);
    diagLabel:SetForeColor(Turbine.UI.Color(1, 0, 0)); -- Bright RED

    -- Controller Button Image Control
    local icon = Turbine.UI.Control();
    icon:SetParent(container);
    -- Increase position to make room for diagLabel
    icon:SetSize(22, 22); 
    icon:SetPosition(11, 54); 
    icon:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    
    -- Load TGA Image relative to the plugin path
    local imagePath = "Patetine/ControllerMod/Images/" .. imageFileName .. ".tga";
    
    -- Try loading it, fail gracefully with a red box if it's missing entirely
    pcall(function()
        icon:SetBackground(imagePath);
    end);
    
    -- Safety check: If it didn't find the background, give it a subtle color border
    if (not icon:GetBackground()) then
         icon:SetBackColor(Turbine.UI.Color(0.2, 0.1, 0.1)); -- Dark red fail box
    end

    return qs;
end