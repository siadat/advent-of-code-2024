vim.cmd.normal("gg0")
vim.fn.search(">\\|<\\|\\^\\|v")
local function get_char(row, col) return vim.fn.getline(row):sub(col, col) end
local function set_char(row, col, char) vim.fn.setline(row, vim.fn.getline(row):sub(1, col-1) .. char .. vim.fn.getline(row):sub(col+1)) end
local direction = vim.fn.getline("."):sub(vim.fn.col("."), vim.fn.col("."))
local line_count = vim.fn.line("$")
local max_line_length = vim.fn.strdisplaywidth(vim.fn.getline(1))
local current_row_number = vim.fn.line(".")
local current_col_number = vim.fn.col(".")
local count = 0
local function run()
	if get_char(current_row_number, current_col_number) ~= "+" then
		set_char(current_row_number, current_col_number, "+")
		count = count + 1
	end
	if direction == ">" then
		local next = get_char(current_row_number, current_col_number+1)
		if next == "#" then
			direction = "v"
		else
			current_col_number = current_col_number + 1
			vim.cmd.normal("l")
		end
	elseif direction == "<" then
		local next = get_char(current_row_number, current_col_number-1)
		if next == "#" then
			direction = "^"
		else
			current_col_number = current_col_number - 1
			vim.cmd.normal("h")
		end
	elseif direction == "^" then
		local next = get_char(current_row_number-1, current_col_number)
		if next == "#" then
			direction = ">"
		else
			current_row_number = current_row_number - 1
			vim.cmd.normal("k")
		end
	elseif direction == "v" then
		local next = get_char(current_row_number+1, current_col_number)
		if next == "#" then
			direction = "<"
		else
			current_row_number = current_row_number + 1
			vim.cmd.normal("j")
		end
	end

	if current_row_number > line_count or current_col_number > max_line_length or current_row_number < 1 or current_col_number < 1 then
		print("Unique locations visited: " .. count)
		return
	end
	vim.cmd("redraw")
	local interval = vim.g.interval or 100
	vim.defer_fn(run, interval)
end
run()
