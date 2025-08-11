-- ## uptime
-- Simple uptime display (for
-- the script, not the machine).
-- No controls or interaction.
--
-- Nick Rothwell, nick@cassiel.com.

-- All globals:
G = { }

SCREEN_HEIGHT = 64
SCREEN_WIDTH = 128

BRIGHT = 15
-- Turn DIM up to 8 or so for screen shots.
DIM = 1

-- Use names rather than font numbers (assuming these are stable):
local function get_font_numbers()
    local t = tab.invert(screen.font_face_names)
    
    -- System font name changed in system 240911:
    SYSTEM_FONT = t["norns"] or t["04B_03__"]
    NONPROP_FONT = t["bmp/ctrld-fixed-10r"]
end

function init()
    get_font_numbers()
    
    G.start_time = os.time()
    G.now_time = G.start_time
    
    local m = metro.init(service, 0.05, -1)
    m:start()
    G.display_strobe = m
end

function service()
    G.now_time = os.time()

    redraw()            --  Can't refer to this in a metro - is it special?
end

local function print_item(row, key, value)
    screen.font_face(SYSTEM_FONT)
    screen.level(DIM)
    screen.move(5, row * 10)
    screen.text(key)
    
    --screen.font_face(NONPROP_FONT)
    screen.level(BRIGHT)
    screen.move(30, row * 10)
    screen.text(value)
end

function redraw()
    screen.font_size(8)
    
    screen.clear()
    
    print_item(1, "start", os.date("%Y-%b-%d %X", G.start_time))
    print_item(2, "now", os.date("%Y-%b-%d %X", G.now_time))
    print_item(3, "up", G.now_time - G.start_time)
    
    screen.update()
end

function cleanup()
    if G.display_strobe then
        G.display_strobe:stop()
    end
end
