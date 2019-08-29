note
	description: "Summary description for {OPTIONS}."
	date: "$Date$"
	revision: "$Revision$"

class
	OPTIONS

create
	make

feature
	make
		do
			create status_options.make
			status_options.set_version ({LIBGIT2_CONSTANTS}.git_status_options_init)
			create repodir.make_from_string (".")
		end


feature -- Access

	status_options: GIT_STATUS_OPTIONS_STRUCT_API

	repodir: STRING

	pathspec: detachable STRING
		--
	npaths: INTEGER

	format: INTEGER

	zterm: INTEGER

	show_branch: BOOLEAN

	show_submodule: BOOLEAN

	repeat: INTEGER

feature -- Change Element


	set_status_option (a_opt: like status_options)
		do
			status_options := a_opt
		end

	set_repodir (a_val: like repodir)
		do
			repodir := a_val
		end

	set_pathspec (a_val: like pathspec)
		do
			pathspec := a_val
		end

	set_npaths (a_val: like npaths)
		do
			npaths := a_val
		end

	set_format (a_val: like format)
		do
			format := a_val
		end

	set_zterm (a_val: like zterm)
		do
			zterm := a_val
		end

	set_show_branch (a_val: like show_branch)
		do
			show_branch := a_val
		end

	set_show_submodule (a_val: like show_submodule)
		do
			show_submodule := a_val
		end

	set_repeat (a_val: like repeat)
		do
			repeat := a_val
		end


end
