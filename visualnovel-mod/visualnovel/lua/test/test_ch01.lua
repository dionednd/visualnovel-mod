-- Sample Visual Novel Script for Visual Novel Mode

-- we initialize two variables named exit and choice.
-- visualnovel.storyboard() always returns at least 1 variable, which is a boolean reserved for the exit code.
-- if exit is true then the player left from the pause menu.
-- if exit is false, the script proceeds with execution.
exit, come_to_river, peel_orange = visualnovel.storyboard("visualnovel/storyboards/test/ch01_01.def", "visualnovel/lua/test/test_ch01.lua")
if exit == true then setMatchNo(-1) return end -- exits from lua file if exited from storyboard. must be checked everytime a storyboard is played

if come_to_river == 1 and peel_orange == 1 then
	exit, points, oranges_peeled, koed = assert(loadfile("visualnovel/minigames/test/orange_peeler.lua"))() -- orange peeler minigame
	if exit == true then setMatchNo(-1) return end

	visualnovel.data.private.orangepeeler_score = points
	visualnovel.data.private.oranges_peeled = oranges_peeled
	if (oranges_peeled < 30 and points < 50000) or koed == true then -- fail orange peel test
		exit = visualnovel.storyboard("visualnovel/storyboards/test/ch01_02a.def", "visualnovel/lua/test/test_ch01.lua")
		if exit == true then setMatchNo(-1) return end
	else -- success
		exit = visualnovel.storyboard("visualnovel/storyboards/test/ch01_02b.def", "visualnovel/lua/test/test_ch01.lua")
		if exit == true then setMatchNo(-1) return end
	end
elseif come_to_river == 1 and peel_orange == 0 then
	visualnovel.launchFight({
	p1char = {"chars/kfm/kfm.def"}, p2char = {"chars/kfm/kfm.def"}, stage = "stages/interactivestage.def", vsscreen = false
	})
end

if visualnovel.resume == nil or (visualnovel.resume and visualnovel.resume.luaPath ~= debug.getinfo(1,'S').source) then
	-- run new lua file from here
	if visualnovel.resume ~= nil and visualnovel.resume.luaPath ~= debug.getinfo(1,'S').source then
		-- is not in the right lua file
		-- load correct lua file, then return.
		assert(loadfile(visualnovel.resume.luaPath))()
		return -- we do this so the other lines do not get executed
	end

	-- load a new lua file here for our next chapter
	-- assert(loadfile("visualnovel/lua/test/test_ch02.lua"))()

	-- if we're not loading a save file, end normally
	setMatchNo(-1) -- end of lua file. leave lua file. if we don't put this in, our lua file will just loop.
end

--functions you can use:
-- visualnovel.storyboard(storyboardPath, luaPath)

-- tables:
-- visualnovel.data.global (global data, persists through save files. useful in cases where finishing a chapter or a specific choice unlocks a character, mode, stage, or another chapter)
-- visualnovel.data.private (private data, is contained inside the save files. useful for save file data to remember what choices the player has made.)