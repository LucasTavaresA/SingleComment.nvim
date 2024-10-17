-- stylua: ignore start
return {
	---@type table lines and filetypes that can be changed to block comments
	-- some can't be changed ;-; but are here for format adjustments
	block = {
		["<!--"]     = { "<!-- ", " -->" },
		["--[["]     = { "--[[ ", " ]]" },
		["-- "]      = { "--[[ ", " ]]" },
		["--"]       = { "--[[ ", " ]]" },
		["/*"]       = { "/* ", " */" },
		lisp         = { "#| ", " |#" },
		cmake        = { "#[[ ", " ]]" },
		haskell      = { "{- ", " -}" },
		elm          = { "{- ", " -}" },
		julia        = { "#= ", " =#" },
		luau         = { "--[[ ", " ]]" },
		nim          = { "#[ ", " ]#" },
		ocaml        = { "(* ", " *)" },
		fsharp       = { "(* ", " *)" },
		markdown     = { "<!-- ", " -->" },
		org          = { "# ", "" },
		neorg        = { "# ", "" },
		javascript   = { "/* ", " */" },
		c            = { "/* ", " */" },
		editorconfig = { "# ", "" },
		fortran      = { "! ", "" },
		default      = { "/* ", " */" },
	},
	---@type table blocks and filetypes that can be changed to line comments
	-- some can't be changed ;-; but are here for format adjustments
	line = {
		["<!--"]     = { "<!-- ", " -->" },
		["/*"]       = { "// ", "" },
		["/* "]      = { "// ", "" },
		[";"]        = { "; ", "" },
		["%"]        = { "% ", "" },
		["#"]        = { "# ", "" },
		nim          = { "# ", "" },
		json         = { "// ", "" },
		jsonc        = { "// ", "" },
		nelua        = { "-- ", "" },
		luau         = { "-- ", "" },
		ocaml        = { "(* ", " *)" },
		css          = { "/* ", " */" },
		markdown     = { "<!-- ", " -->" },
		org          = { "# ", "" },
		neorg        = { "# ", "" },
		editorconfig = { "# ", "" },
		fortran      = { "! ", "" },
		default      = { "// ", "" },
	},
}
-- stylua: ignore end
