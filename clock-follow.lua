-----
-- ## clock-follow
-- simple clock follower.
-- Nick Rothwell, nick@cassiel.com.

-- I am neurotic about pollution of the top-level environment,
-- so apart from consts and top-level functions I'm going to wrap everything
-- inside a single global table.

G = { }

SCREEN_HEIGHT = 64
SCREEN_WIDTH = 128
DISC_MARGIN = 2

-- Use names rather than font numbers (assuming these are stable):
local function get_font_numbers()
    local t = tab.invert(screen.font_face_names)
    
    SYSTEM_FONT = t["04B_03__"]
    NONPROP_FONT = t["bmp/ctrld-fixed-10r"]
end

local function get_disc_params()
    G.disc_params = {
        x = SCREEN_HEIGHT / 2,
        y = SCREEN_HEIGHT / 2,
        r = (SCREEN_HEIGHT / 2) - DISC_MARGIN
    }
end

function init()
    get_font_numbers()
    get_disc_params()
    
    -- We could do a clock.set_source("xxx") here, but that doesn't
    -- seem to get reflected in the display for PARAMETERS>CLOCK,
    -- so let's just rely on the latter since it's provided already.
    
    G.clock_id = clock.run(ticker)
    
    -- We'll run a metro for asynchronous update of display,
    -- regardless of beat sync. (So it'll probably jitter slightly
    -- against the beat, unless we're at 60, 120 or similar)

    local m = metro.init(service, 0.05, -1)
    m:start()
    G.display_strobe = m
end

-- It seems that we can't just call redraw from a metro - it
-- doesn't work. (Generally we'd want a wrapper anyway to
-- carry additional application logic.)

function service()
    redraw()
end

local function draw_disc()
    local p = G.disc_params

    screen.level(1)
    screen.line_width(1)

    screen.circle(p.x, p.y, p.r)
    screen.stroke()
end

local function draw_locator()
    -- Show one rotation per quantum
    local quantum = params:get("link_quantum")
    local beats = clock.get_beats()
    --print(math.fmod(beats, quantum))
    local theta = math.fmod(beats, quantum) * math.pi * 2 / quantum
    
    local p = G.disc_params
    local locator_x = p.x + p.r * math.sin(theta)
    local locator_y = p.y - p.r * math.cos(theta)
    
    screen.level(8)
    screen.line_width(0)

    screen.circle(locator_x, locator_y, 2)
    screen.fill()
    
    screen.move(p.x, p.y)
    screen.level(1)
    screen.line_width(1)
    screen.line(locator_x, locator_y)
    screen.stroke()
    
end

local function show_beats()
    screen.move(SCREEN_HEIGHT / 2, SCREEN_HEIGHT / 2 + 4)
    screen.font_face(NONPROP_FONT)
    screen.font_size(12)
    screen.level(12)
    screen.text_center(string.format("%.1f", clock.get_beats()))
end

local function show_settings()
    screen.font_face(SYSTEM_FONT)
    screen.font_size(8)
    screen.level(12)
    
    screen.move(SCREEN_WIDTH / 2 + 10, 10)
    -- params:get("clock_tempo") is only integer resolution
    screen.text("tempo " .. clock.get_tempo())
    
    screen.move(SCREEN_WIDTH / 2 + 10, 18)
    screen.text("quantum " .. params:get("link_quantum"))
    
    local src = params:get("clock_source")
    local names = {"internal", "midi", "link", "crow"}
    local src_name = names[src]
    screen.move(SCREEN_WIDTH / 2 + 10, 26)
    screen.text("src " .. src_name)
end

-- The name "redraw" is magic - it prevents screen updates when
-- on the norns system menu pages. It also seems to get an implicit
-- first call from init(), and when refocussing after system pages.

function redraw()
    screen.clear()
    screen.stroke()     -- Needed to avoid spurious traces...?
    
    draw_disc()
    draw_locator()
    show_beats()
    show_settings()
    
    screen.update()
end

function ticker()
    clock.sync(1)
    print("ticker")
end

function cleanup()
    clock.link.stop()       --  TODO: safe to call this if not in link?
    
    if G.clock_id then
        clock.cancel(G.clock_id)
    end
    
    if G.display_strobe then
        G.display_strobe:stop()
    end
end
