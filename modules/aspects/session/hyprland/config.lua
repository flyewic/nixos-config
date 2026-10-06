-- Ported from the curated niri config so the compositors feel the same.
-- Hyprland's layout is dwindle/master, so niri's column actions map to the
-- closest equivalent or are dropped. Shell actions go through noctalia.
-- `@KB_LAYOUT@`/`@KB_VARIANT@` are filled from the `keyboard` option.

local mainMod = "SUPER"

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 4,
        border_size = 1,
        layout = "dwindle",
    },
    decoration = {
        rounding = 12,
    },
    input = {
        kb_layout = "@KB_LAYOUT@",
        kb_variant = "@KB_VARIANT@",
        numlock_by_default = true,
        sensitivity = 1.0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = true,
            ["tap-to-click"] = true,
        },
    },
    binds = {
        workspace_back_and_forth = true,
    },
    misc = {
        disable_hyprland_logo = true,
        focus_on_activate = true,
    },
})

hl.window_rule({
    name = "gnome-rounding",
    match = { class = "^org\\.gnome\\." },
    rounding = 12,
})

hl.window_rule({
    name = "float-dialogs",
    match = {
        class = "^(gnome-control-center|pavucontrol|nm-connection-editor|org\\.gnome\\.Calculator|gnome-calculator|galculator|blueman-manager|org\\.gnome\\.Nautilus|xdg-desktop-portal)$",
    },
    float = true,
})

hl.window_rule({
    name = "steam-toasts",
    match = { class = "^steam$", title = "^notificationtoasts_\\d+_desktop$" },
    float = true,
    move = "10 10",
    no_focus = true,
})

hl.window_rule({
    name = "pip-and-zoom",
    match = { class = "^(firefox|zen|zoom)$", title = "^Picture-in-Picture$" },
    float = true,
})

-- === System & Overview ===
-- niri's overview/hotkey-overlay have no built-in Hyprland equivalent.

-- === Application Launchers ===
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("flatpak run app.zen_browser.zen"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("noctalia msg panel-toggle notifications"))

-- === Security ===
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))

-- === Audio Controls ===
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up 3"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down 3"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("noctalia msg mic-mute"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("noctalia msg media toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"), { locked = true })

-- === Brightness Controls ===
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up 5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down 5"), { locked = true, repeating = true })

-- === Window Management ===
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))

-- === Focus Navigation ===
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- === Window Movement ===
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- === Monitor Navigation ===
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ monitor = "left" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ monitor = "down" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.focus({ monitor = "up" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ monitor = "right" }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ monitor = "left" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.focus({ monitor = "down" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.focus({ monitor = "up" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ monitor = "right" }))

-- === Move to Monitor ===
hl.bind(mainMod .. " + SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "left" }))
hl.bind(mainMod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "down" }))
hl.bind(mainMod .. " + SHIFT + CTRL + up", hl.dsp.window.move({ monitor = "up" }))
hl.bind(mainMod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "right" }))
hl.bind(mainMod .. " + SHIFT + CTRL + H", hl.dsp.window.move({ monitor = "left" }))
hl.bind(mainMod .. " + SHIFT + CTRL + J", hl.dsp.window.move({ monitor = "down" }))
hl.bind(mainMod .. " + SHIFT + CTRL + K", hl.dsp.window.move({ monitor = "up" }))
hl.bind(mainMod .. " + SHIFT + CTRL + L", hl.dsp.window.move({ monitor = "right" }))

-- === Workspace Navigation ===
hl.bind(mainMod .. " + Page_Down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + Page_Up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + U", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + U", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + I", hl.dsp.window.move({ workspace = "e-1" }))

-- === Mouse Wheel Navigation ===
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))

-- === Numbered Workspaces ===
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- === Sizing & Layout ===
hl.bind(mainMod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + C", hl.dsp.window.center())
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

-- === Screenshots ===
hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("noctalia msg screenshot-region"))

-- === System Controls ===
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.dpms())
