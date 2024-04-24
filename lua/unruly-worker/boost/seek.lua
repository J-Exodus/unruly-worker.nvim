local log = require("unruly-worker.log")
local seek_buffer = require("unruly-worker.boost.seek-buffer")
local seek_quickfix = require("unruly-worker.boost.seek-quickfix")
local seek_loclist = require("unruly-worker.boost.seek-loclist")

-- module
local M = {}

---@enum UnrulySeekMode
M.seek_mode = {
	quickfix = "Q",
	loclist = "L",
	buffer = "B",
}

local state = {
	seek_mode = M.seek_mode.buffer,
}

local function create_mode_set_fn(mode_option)
	return function()
		state.seek_mode = mode_option
		M.seek_first()
	end
end

-- seek quick fix list
M.mode_set_quickfix = create_mode_set_fn(M.seek_mode.quickfix)
M.mode_set_buffer = create_mode_set_fn(M.seek_mode.buffer)
M.mode_set_loclist = create_mode_set_fn(M.seek_mode.loclist)

---@class UnrulyHudStateSeek
---@field mode UnrulySeekMode
---@field len number
---@field index number

--- get seek hud state
---@return UnrulyHudStateSeek
function M.get_hud_state()
	local result = {
		mode = state.seek_mode,
		len = 0,
		index = 0,
	}

	if state.seek_mode == M.seek_mode.buffer then
		local buffer_state = seek_buffer.get_hud_state()
		result.len = buffer_state.len
		result.index = buffer_state.index
		return result
	end

	if state.seek_mode == M.seek_mode.quickfix then
		local buffer_state = seek_quickfix.get_hud_state()
		result.len = buffer_state.len
		result.index = buffer_state.index
		return result
	end

	local buffer_state = seek_loclist.get_hud_state()
	result.len = buffer_state.len
	result.index = buffer_state.index
	return result
end

function M.mode_get()
	return state.seek_mode
end

function M.seek_forward()
	if state.seek_mode == M.seek_mode.buffer then
		return seek_buffer.seek_forward()
	end

	if state.seek_mode == M.seek_mode.quickfix then
		return seek_quickfix.seek_forward()
	end

	if state.seek_mode == M.seek_mode.loclist then
		return seek_loclist.seek_forward()
	end

	log.error("no seek forward impl for %s", M.mode_get())
end

function M.seek_reverse()
	if state.seek_mode == M.seek_mode.buffer then
		return seek_buffer.seek_reverse()
	end
	if state.seek_mode == M.seek_mode.quickfix then
		return seek_quickfix.seek_reverse()
	end
	if state.seek_mode == M.seek_mode.loclist then
		return seek_loclist.seek_reverse()
	end
	log.error("no seek reverse impl for %s", M.mode_get())
end

function M.seek_first()
	if state.seek_mode == M.seek_mode.buffer then
		return seek_buffer.seek_first()
	end
	if state.seek_mode == M.seek_mode.quickfix then
		return seek_quickfix.seek_first()
	end
	if state.seek_mode == M.seek_mode.loclist then
		return seek_loclist.seek_first()
	end

	log.error("no seek forward impl for %s", M.mode_get())
end

function M.seek_last()
	if state.seek_mode == M.seek_mode.buffer then
		return seek_buffer.seek_last()
	end
	if state.seek_mode == M.seek_mode.quickfix then
		return seek_quickfix.seek_last()
	end
	if state.seek_mode == M.seek_mode.loclist then
		return seek_loclist.seek_last()
	end

	log.error("no seek forward impl for %s", M.mode_get())
end

--- @param seek_mode UnrulySeekMode
function M.set_seek_mode_silent(seek_mode)
	state.seek_mode = seek_mode
end

return M
