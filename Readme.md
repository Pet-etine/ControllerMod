# 🎮 Controller Hotbar Overlay – Setup Guide

This plugin provides an on-screen cross-hotbar overlay designed specifically for controller play in *Lord of the Rings Online*. It translates your physical controller inputs into in-game skill execution seamlessly using modifier keys.

---

### 📦 Installation Guide

1. **Download** the provided zip file (`ControllerMod.zip`).
2. **Extract** the contents into your LOTRO Plugins directory:
   * **Windows:**
     ```text
     C:\Users\<YourUsername>\Documents\The Lord of the Rings Online\Plugins\
     ```
   * **Steam Deck (Desktop Mode):**
     ```text
     /home/deck/.local/share/Steam/steamapps/compatdata/21250/pfx/drive_c/users/steamuser/Documents/The Lord of the Rings Online/Plugins/
     ```
     *(Make sure "Show Hidden Files" is enabled in Dolphin file manager)*

3. **Verify Folder Structure:**
   Ensure the extracted files match this exact path structure:
   ```text
   .../Documents/The Lord of the Rings Online/Plugins/Patetine/ControllerMod/
   └── Main.lua

   .../Documents/The Lord of the Rings Online/Plugins/Patetine/
   └── ControllerMod.plugin

    Load the Plugin In-Game:

        Open the chat box in-game and type /plugins manager.

        Find ControllerMod under the Patetine directory in the list and check the box to load it (or check "Automatically load for this character").

        Alternatively, type /plugins load ControllerMod in chat.

⚙️ How It Works (Button Mapping)

The overlay is split into 4 primary input clusters of 8 slots each (4 D-Pad directions + 4 Face buttons), giving you instant access to 32 abilities:

    Number Keys (1 – 8): Bound to your core action inputs across all clusters:

        D-Pad: 5 (Up), 6 (Down), 7 (Left), 8 (Right)

        Face Buttons: 1 (A / Cross), 2 (B / Circle), 3 (X / Square), 4 (Y / Triangle)

    Modifier Triggers & Bumpers:

        Base Inputs (No Modifier): Triggers keys 1 through 8 directly.

        LB / L1 Cluster (Shift): Holding LB / L1 sends Shift + 1 through Shift + 8.

        RB / R1 Cluster (Ctrl): Holding RB / R1 sends Ctrl + 1 through Ctrl + 8.

        LT / L2 Cluster (Alt): Holding LT / L2 sends Alt + 1 through Alt + 8.

🔧 Steam / Controller Configuration

For the smoothest experience, search for and apply the community layout named Patetine's Controller Configuration in Steam's Controller Settings. This pre-configured profile maps your controller's D-Pad, face buttons, bumpers, and triggers directly to the 1–8 keys and Shift / Ctrl / Alt modifiers used by the overlay.
📌 Features & In-Game Controls

    Repositioning: Hold Ctrl + Left Click and drag the overlay box anywhere on your screen to adjust its position.

    Controller Style Swapping: Open /plugins manager, select ControllerMod, navigate to the Options tab, and toggle between Xbox and PlayStation button icon styles to match your gamepad setup.

    Opacity Control: Fine-tune the backdrop and frame transparency using the opacity slider in the Plugin Manager Options tab.

    Quickslot Drag-and-Drop: Drag skills, items, or macros directly from your character panel onto any overlay slot so they match your preferred controller layout.

📜 Credits & Acknowledgments

    Author & Developer: Pet.e-tine

    AI Collaborator: Gemini (Code Assistance & Documentation Support)

    Framework: Powered by the LOTRO API (Turbine.UI)

Third-Party Visual Assets & Licenses

    Xbox Series & PlayStation Button Icons & UI Assets:

        Author: Zacksly (zacksly.itch.io)

        License: CC BY 3.0

        Note: Original assets were modified (cropped, scaled, color-adjusted, and formatted as uncompressed 32-bit TGA files) for LOTRO UI compatibility and dynamic style-swapping support.

    Game Controller Icon:

        Source: Icons8

        License: CC BY 3.0

        Note: Adapted for plugin manager and icon branding.
