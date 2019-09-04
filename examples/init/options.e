note
	description: "Summary description for {OPTIONS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	OPTIONS

create
	make

feature
	make
		do
			shared := {GIT_REPOSITORY_INIT_MODE_T_ENUM_API}.git_repository_init_shared_umask
		end

feature -- Access

	no_options: BOOLEAN
		do
			Result := quiet or bare or initial_commit or (shared /= {GIT_REPOSITORY_INIT_MODE_T_ENUM_API}.git_repository_init_shared_umask) or (attached template) or (attached gitdir)
		end

	quiet: BOOLEAN

	bare: BOOLEAN

	initial_commit: BOOLEAN

	shared: INTEGER

	template: detachable STRING

	gitdir: detachable STRING

	dir: detachable STRING

feature -- Change Element

	set_quiet (a_val: like quiet)
		do
			quiet := a_val
		end

	set_bare (a_val: like bare)
		do
			bare := a_val
		end

	set_initial_commit (a_val: like initial_commit)
		do
			initial_commit :=  a_val
		end

	set_shared (a_val: like shared)
		do
			shared := a_val
		end

	set_template (a_val: like template)
		do
			template := a_val
		end

	set_gitdir (a_val: like gitdir)
		do
			gitdir := a_val
		end

	set_dir (a_val: like dir)
		do
			dir := a_val
		end
end
