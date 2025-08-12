-- Scratch tests.

local function init_softcut()
    softcut.buffer_clear()      --  Done on script launch, but anyway
    softcut.enable(1, 1)        --  Enable voice #1
    softcut.buffer(1, 1)        --  Attach voice #1 to buffer #1
    softcut.rate(1, 1.0)        --  normal rate
    softcut.loop(1, 1)          --  Enable looping for voice #1
    softcut.loop_start(1, 1)    --  Start loop of V1 at 1 second
    softcut.loop_end(1, 2)      --  End loop of V1 at 2 seconds
    softcut.position(1, 0)      --  Position at start of buffer
end

local function init_mix()
    audio.level_adc_cut(1)      --  Audio in to softcut
    softcut.level(1, 1.0)       --  Full volume for voice #1
    
    softcut.level_input_cut(1, 1, 1.0)      -- ADC input level to V1 (what about SC etc.?)
    softcut.level_input_cut(2, 1, 1.0)      -- ADC input level to V2 (currently unused)
    
    softcut.rec_level(1, 1.0)       -- set voice 1 record level 
    softcut.pre_level(1, 0.0)       -- set voice 1 pre level
end

function init()
    init_softcut()
    init_mix()
end
