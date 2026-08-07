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

# ControllerMod — Steam Input Setup Guide

Since Steam layout indexing can vary across different game versions and hardware configurations, follow this guide to configure your controller bindings manually in Steam Input.

---

## 1. Quick Import Link
If you are on PC, try opening this direct link in your web browser with Steam running:

```text
steam://controllerconfig/212500/3779183885
(If the link does not open automatically in Steam, proceed with the manual setup below.)
2. Controller Button Mappings
Movement & Camera
•	Left Joystick: W / A / S / D (Movement)
•	Left Stick Click (L3):
o	Press: Tab (Select nearest enemy)
o	Double Press: Delete (Select nearest object)
•	Right Joystick: Joystick Mouse (Camera control)
•	Right Stick Click (R3): Right Mouse Click (Target / Interact)
Action Bars & Modifiers
The UI uses shoulder buttons as modifier keys to access all 32 quickslots across 4 action bars:
Controller Button	Key Binding	In-Game Action / Function
Face Buttons (A, B, X, Y)	1, 2, 3, 4	Main Skill Slots 1–4
D-Pad (Up, Right, Down, Left)	5, 6, 7, 8	Main Skill Slots 5–8
Left Bumper (LB)	Shift Key	Modifier Key (Shift Bar)
Right Bumper (RB)	Control Key	Modifier Key (Control Bar)
Left Trigger (LT)	Alt Key	Modifier Key (Alt Bar)
Right Trigger (RT)	Left Mouse Click	Target Selection / Drag-and-Drop
System & Menus
View / Select Button (Left Menu)
•	Press: M (Map)
•	Long Press: C (Character Panel)
•	Double Press: L (Quest Log)
Menu / Start Button (Right Menu)
•	Press: I (Inventory / Bags)
•	Long Press: Escape (Main Menu / Cancel)
•	Double Press: K (Skill Panel)
3. Configuring Multi-Action Buttons in Steam
To assign multiple commands (Press, Long Press, Double Press) to a single button (such as the Select or Start buttons):
1.	Open Steam Controller Settings for LOTRO.
2.	Select the button you wish to configure (e.g., Select Button).
3.	Set Command 1 to Regular Press and assign the primary key (e.g., M).
4.	Click the Gear Icon next to Command 1 and select Add Extra Command.
5.	Change the activator type for Command 2 to Long Press and assign the second key (e.g., C).
6.	Click Add Extra Command again, change the activator type for Command 3 to Double Press, and assign the third key (e.g., L).
4. In-Game Skill Assignment (Drag-and-Drop)
1.	Open your Skill Panel in-game (K key or double-press the Start button).
2.	Use the Right Joystick to move the cursor over a skill icon.
3.	Hold Right Trigger (RT) to pick up the skill icon.
4.	Drag the icon over to your desired ControllerMod quickslot and release RT to place it.
5.	Repositioning Overlay: To move the ControllerMod UI overlay on screen, hold Ctrl + Left Click on the frame and drag it to your desired position.


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
