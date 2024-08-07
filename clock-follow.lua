-----
-- ## clock-follow
-- simple clock follower.
-- Nick Rothwell, nick@cassiel.com.

G = { }

function init()
    G.clock_id = clock.run(ticker)
end

function ticker()
    clock.sync(1)
    print("ticker")
end

function cleanup()
    if G.clock_id then
        clock.cancel(G.clock_id)
    end
end
