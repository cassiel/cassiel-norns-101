-- ## midi-fighter
-- Simple tests for MIDI Fighter Spectra,
-- with colour support for the buttons.
--
-- Nick Rothwell, nick@cassiel.com.

-- All globals:
G = { }

BRIGHT = 15
DIM = 1

function init()
    local midi_devices = { }
    local midi_names = { }
    
    for i = 1, #midi.vports do
        midi_devices[i] = midi.connect(i)
        table.insert(
            midi_names,
            "port "..i..": "..util.trim_string_to_width(midi_devices[i].name, 80)
        )
    end
    
    params:add_option("midi target", "midi target", midi_names, 1)
    params:set_action("midi target", function(x) G.midi.target = x end)
    
    G.midi = {
        devices = midi_devices,
        names = midi_names,
        target = 1
    }
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
