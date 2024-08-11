-- ## clock-follow
-- simple clock follower. Config
-- from PARAMETERS > CLOCK.
-- Make sure link start/stop on
-- to animate the cursor.
--
-- Nick Rothwell, nick@cassiel.com.

-- I am neurotic about pollution of the top-level environment,
-- so apart from consts and top-level functions I'm going to wrap everything
-- inside a single global table.

G = { }

SCREEN_HEIGHT = 64
SCREEN_WIDTH = 128
DISC_MARGIN = 2

BRIGHT = 15
-- Turn DIM up to 8 or so for screen shots.
DIM = 1

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
    
    -- Track (and display) the state of the transport:
    G.transport_started = false
    
    clock.transport.start = function ()
        G.transport_started = true
    end

    clock.transport.stop = function ()
        G.transport_started = false
    end
end

-- It seems that we can't just call redraw from a metro - it
-- doesn't work. (Generally we'd want a wrapper anyway to
-- carry additional application logic.)

function service()
    redraw()
end

local function point_on_disc(radius, theta)
    local p = G.disc_params
    local x = p.x + radius * math.sin(theta)
    local y = p.y - radius * math.cos(theta)
    
    return x, y
end

local function draw_disc()
    local p = G.disc_params

    screen.level(DIM)
    screen.line_width(1)

    screen.circle(p.x, p.y, p.r)
    screen.stroke()
    
    -- Draw the ticks, according to quantum value.
    local quantum = params:get("link_quantum")
    
    for i = 1, quantum do
        local theta = math.pi * 2 * i / quantum
        local x1, y1 = point_on_disc(p.r, theta)
        local x2, y2 = point_on_disc(p.r - 5, theta)
        screen.move(x1, y1)
        screen.line(x2, y2)
        screen.stroke()
    end
end

local function draw_locator()
    -- Show one rotation per quantum
    local quantum = params:get("link_quantum")
    local beats = clock.get_beats()
    --print(math.fmod(beats, quantum))
    local theta = math.fmod(beats, quantum) * math.pi * 2 / quantum
    
    local p = G.disc_params
    local x, y = point_on_disc(p.r, theta)

    screen.level(BRIGHT)
    screen.line_width(0)

    screen.circle(x, y, 2)
    screen.fill()
    
    screen.move(p.x, p.y)
    screen.level(DIM)
    screen.line_width(1)
    screen.line(x, y)
    screen.stroke()
    
end

local function show_beats()
    screen.move(SCREEN_HEIGHT / 2, SCREEN_HEIGHT / 2 + 4)
    screen.font_face(NONPROP_FONT)
    screen.font_size(12)
    screen.level(BRIGHT)
    screen.text_center(string.format("%.1f", clock.get_beats()))
end

local function show_settings()
    screen.font_face(SYSTEM_FONT)
    screen.font_size(8)
    screen.level(BRIGHT)
    
    screen.move(SCREEN_WIDTH / 2 + 10, 10)
    -- params:get("clock_tempo") is only integer resolution
    screen.text("tempo " .. string.format("%.2f", clock.get_tempo()))
    
    screen.move(SCREEN_WIDTH / 2 + 10, 18)
    screen.text("quantum " .. params:get("link_quantum"))
    
    local src = params:get("clock_source")
    local snames = {"internal", "midi", "link", "crow"}
    local src_name = snames[src]
    screen.move(SCREEN_WIDTH / 2 + 10, 26)
    screen.text("src " .. src_name)
    
    local start_stop = params:get("link_start_stop_sync")
    local ssnames = {"n", "y"}
    local ss_name = ssnames[start_stop]
    screen.move(SCREEN_WIDTH / 2 + 10, 34)
    screen.text("strt/stp " .. ss_name)
    
    screen.move(SCREEN_WIDTH / 2 + 10, 42)
    local tr_name = (G.transport_started and "y" or "n")
    screen.text("transport " .. tr_name)
end

-- The name "redraw" is magic - it prevents screen updates when
-- on the norns system menu pages. It also seems to get an implicit
-- first call from init(), and when refocussing after system pages.

function redraw()
    screen.clear()
    screen.stroke()     -- Needed to avoid spurious traces...?
    
    draw_disc()
    
    -- Don't draw location when we're cueing, or transport stopped:
    if clock.get_beats() >= 0 and G.transport_started then
        draw_locator()
    end
    
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
