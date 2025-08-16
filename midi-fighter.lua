-- ## midi-fighter
-- Simple tests for MIDI Fighter Spectra,
-- with colour support for the buttons.
-- Select MIDI device via params page.
--
-- Nick Rothwell, nick@cassiel.com.

-- All globals:
G = { }

BRIGHT = 15
DIM = 4

-- Obviously, will need to reload the script if the MIDI vports change.

function init()
    local midi_devices = { }
    local midi_names = { }
    
    for i = 1, #midi.vports do
        midi_devices[i] = midi.connect(i)
        -- The trim is mainly for the parameter page. (Perhaps we should
        -- have a second table with longer names for the script page.))
        table.insert(
            midi_names,
            "port "..i..": "..util.trim_string_to_width(midi_devices[i].name, 40)
        )
        
        -- Check Lua's closure capture: we should make sure we ignore
        -- messages from devices other than the current target.
        midi_devices[i].event =
            function (x)
                print("Virtual device " .. i)
                tab.print(midi.to_msg(x))
            end
    end
    
    params:add_option("midi target", "midi target", midi_names, 1)
    params:set_action("midi target", function(x) G.midi.target = x end)
    
    G.midi = {
        devices = midi_devices,
        names = midi_names,
        target = 1
    }
    
    for i = 1, 16 do
        G.midi.devices[G.midi.target]:note_on(36 + i - 1, math.random(127), 3)
    end
end

local function print_item(row, key, value)
    local y = row * 10 + 10
    
    screen.clear()
    screen.move(25, y)
    screen.level(DIM)
    screen.text_right(key)
    screen.move(30, y)
    screen.level(BRIGHT)
    screen.text(value)
    screen.update()
end

function redraw()
    print_item(1, "target", params:string("midi target"))
end
