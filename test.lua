local tstart = timer.start
function timer.start(ms)
	if not timer.isRunning then
		tstart(ms)
	end
	timer.isRunning = true
end

local tstop = timer.stop
function timer.stop()
	timer.isRunning = false
	tstop()
end

function on.paint(gc)
    timer.start(0.1)

    gc:drawRect(math.random()*200+10, math.random()*200+10, 20, 20)
end

function on.timer()
    timer.stop()
    platform.window:invalidate()
end