note
	description: "[
		libgit2 "status" example - shows how to use the status APIs
		]"
	EIS: "name=git status", "src=https://github.com/libgit2/libgit2/blob/master/examples/status.c","protocol=uri"

class APPLICATION

inherit

	COMMAND_LINE_PARSER
		rename
			make as make_command_line_parser
		end

create
	make

feature {NONE} --Initialization

	make
		local
			status: GIT_STATUS_LIST_STRUCT_API
			repo: 	GIT_REPOSITORY_STRUCT_API
			ini: INTEGER
			git_status: GIT_STATUS
		do
			create git_repository
			create git_status
			create repo.make
			ini := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			print ("%N Intializing Libgit2")
			create options.make
			options.status_options.set_show ({GIT_STATUS_SHOW_T_ENUM_API}.GIT_STATUS_SHOW_INDEX_AND_WORKDIR)
			options.status_options.set_flags (	{GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_include_untracked |
												{GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_renames_head_to_index |
												{GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_sort_case_sensitively)

			create status.make

			make_command_line_parser
			process_arguments

			if git_repository.git_repository_open (repo, (create {PATH}.make_from_string (options.repodir)).out) < 0 then
				print ("%NCould not open repository")
				{EXCEPTIONS}.die (1)
			end

			if git_repository.git_repository_is_bare (repo) < 0 then
				 print ("%NCannot report status on bare repository " + git_repository.git_repository_path (repo))
				{EXCEPTIONS}.die (1)
			end

			-- Show status

				--	 * Run status on the repository
				--	 *
				--	 * We use `git_status_list_new()` to generate a list of status
				--	 * information which lets us iterate over it at our
				--	 * convenience and extract the data we want to show out of
				--	 * each entry.
				--	 *
				--	 * You can use `git_status_foreach()` or
				--	 * `git_status_foreach_ext()` if you'd prefer to execute a
				--	 * callback for each entry. The latter gives you more control
				--	 * about what results are presented.
				--	 */

			if git_status.git_status_list_new (status, repo, options.status_options) < 0 then
				 print ("%NCould not get status " + git_repository.git_repository_path (repo))
				{EXCEPTIONS}.die (1)
			end

			if options.show_branch then
				show_branch (repo)
			end

			if options.show_submodule then
			   -- to be completed.
			end

			if options.format = {FORMAT_ENUM}.format_long then
				print_long (status)
			else
				print_short (repo, status)
			end

			git_status.git_status_list_free (status)

		end

	show_branch (a_repo: GIT_REPOSITORY_STRUCT_API)
			-- If the user asked for the branch, let's show the short name of the branch
		local
			head: GIT_REFERENCE_STRUCT_API
			error: INTEGER
			branch: STRING
			git_reference: GIT_REFERENCE
			l_ptr: POINTER
		do
			create git_reference
			create head.make
			error := git_repository.git_repository_head(head, a_repo)

			if error = {GIT_ERROR_CODE_ENUM_API}.GIT_EUNBORNBRANCH or error={GIT_ERROR_CODE_ENUM_API}.GIT_EUNBORNBRANCH then
				branch := ""
			elseif error >= 0 then
				branch := git_reference.git_reference_shorthand (head)
			else
				print ("%Nfailed to get current branch")
				{EXCEPTIONS}.die (1)
			end

			print ("%NOn branch " + branch)
			git_reference.git_reference_free (head)
		end


feature	{NONE} -- Process Arguments


	process_arguments
			-- Process command line arguments
		local
			shared_value: STRING
		do

			if match_long_option ("short") then
				consume_option
				options.set_format ({FORMAT_ENUM}.FORMAT_SHORT)
			end

			if match_long_option ("long") then
				consume_option
				options.set_format ({FORMAT_ENUM}.FORMAT_LONG)
			end

			if match_long_option ("porcelain") then
				consume_option
				options.set_format ({FORMAT_ENUM}.FORMAT_PORCELAIN)
			end

			if match_long_option ("branch") then
				consume_option
				options.set_show_branch (True)
			end

			if match_long_option ("z") then
				consume_option
				options.set_zterm (1)
				if options.format = {FORMAT_ENUM}.FORMAT_DEFAULT then
					options.set_format ({FORMAT_ENUM}.FORMAT_PORCELAIN)
				end
			end

			if match_long_option ("ignored") then
				consume_option
				options.status_options.set_flags (options.status_options.flags | {GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_include_ignored)
			end

				--untracked-files=no
			if match_long_option ("uno") then
				consume_option
				options.status_options.set_flags (options.status_options.flags & ({GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_include_untracked).bit_not)
			end

				--untracked-files=normal
			if match_long_option ("unormal") then
				consume_option
				options.status_options.set_flags (options.status_options.flags | {GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_include_untracked)
			end
				--untracked-files=all
			if match_long_option ("uall") then
				consume_option
				options.status_options.set_flags (options.status_options.flags | {GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_include_untracked | {GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_recurse_untracked_dirs )
			end
				--ignore-submodules=all
			if match_long_option ("ignore-submodules") then
				consume_option
				options.status_options.set_flags (options.status_options.flags | {GIT_STATUS_OPT_T_ENUM_API}.git_status_opt_exclude_submodules )
			end

			if match_long_option ("git-dir") then
				if is_next_option_long_option and then has_next_option_value then
					options.set_repodir (next_option_value)
					consume_option
				else
					print("%N Missing command line parameter --git-dir=<dir>")
					usage
					{EXCEPTIONS}.die (1)
				end
			end
			if match_long_option ("list-submodules") then
				consume_option
				options.set_show_submodule (True)
			end


		end

feature -- Print

	print_long (a_status: GIT_STATUS_LIST_STRUCT_API)
		local
			git_status: GIT_STATUS
			maxi: INTEGER
			s: GIT_STATUS_ENTRY_STRUCT_API
			changed_in_index: BOOLEAN
			header: BOOLEAN
			changed_in_workdir, rm_in_workdir: BOOLEAN
			old_path, new_path: STRING
			is_status: STRING
			ws_status: STRING
			continue: BOOLEAN
		do
			create git_status
			maxi := git_status.git_status_list_entrycount (a_status)

				-- Print index changes
			across 1 |..| maxi as ic loop
				create is_status.make_empty
				s := git_status.git_status_byindex (a_status, ic.item - 1)
				if s.status = {GIT_STATUS_T_ENUM_API}.Git_Status_current then
					continue := True
				end
				if (s.status & {GIT_STATUS_T_ENUM_API}.git_status_wt_deleted) /= 0  and not continue then
					rm_in_workdir := True
				end
				if (s.status & {GIT_STATUS_T_ENUM_API}.git_status_index_new) /= 0 and not continue  then
					is_status.append ("new file: ")
				end
				if (s.status & {GIT_STATUS_T_ENUM_API}.git_status_index_modified) /= 0 and not continue  then
					is_status.append ("modified: ")
				end
				if (s.status & {GIT_STATUS_T_ENUM_API}.git_status_index_deleted) /= 0 and not continue  then
					is_status.append ("deleted: ")
				end
				if (s.status & {GIT_STATUS_T_ENUM_API}.git_status_index_renamed) /= 0 and not continue  then
					is_status.append ("renamed: ")
				end
				if (s.status & {GIT_STATUS_T_ENUM_API}.git_status_index_typechange) /= 0 and not continue  then
					is_status.append ("typechange: ")
				end
				if is_status.is_empty then
					continue := True
				end

				if not header then
					print("%N# Changes to be committed:%N")
					print("%N#(use %"git reset HEAD <file>...%" to unstage)%N")
					print("%N#%N");
					header := True
				end

				if attached s.head_to_index as l_head_to_index and then
					attached l_head_to_index.old_file as l_old_file
				then
					old_path := l_old_file.path
				end

				if attached s.head_to_index as l_head_to_index and then
					attached l_head_to_index.new_file as l_new_file
				then
					new_path := l_new_file.path
				end

				if old_path /= Void and then new_path  /= Void and then old_path.is_case_insensitive_equal_general (new_path) then
					print ("%N%T" + is_status + " " + old_path + " -> " + new_path )
				else
					if old_path /= Void and then old_path.is_empty then
						print ("%N%T" + is_status + " " + if attached new_path then new_path else "" end)
					else
						print ("%N%T" + is_status + " " + if attached old_path then old_path else "" end)
					end
				end
			end

			if header then
				changed_in_index := True
				print ("#%N")
			end

			header := False

				-- Print workdir changes to tracked files.

			across 1 |..| maxi as ic loop
				create ws_status.make_empty
				s := git_status.git_status_byindex (a_status, ic.item - 1)
					--
					--	With `GIT_STATUS_OPT_INCLUDE_UNMODIFIED` (not used in this example)
					--	`index_to_workdir` may not be `NULL` even if there are
					--	 no differences, in which case it will be a `GIT_DELTA_UNMODIFIED`.
					--
				if s.status ={GIT_STATUS_T_ENUM_API}.git_status_current or (attached s.index_to_workdir as l_index_to_workdir and then l_index_to_workdir.item = default_pointer) then
					continue := True
				end

					-- Print out the output since we know the file has some changes
				if s.status = {GIT_STATUS_T_ENUM_API}.git_status_wt_modified and not continue then
					ws_status := "modified: "
				end
				if s.status = {GIT_STATUS_T_ENUM_API}.git_status_wt_deleted and not continue then
					ws_status := "deleted: "
				end
				if s.status = {GIT_STATUS_T_ENUM_API}.git_status_wt_renamed and not continue then
					ws_status := "renamed: "
				end
				if s.status = {GIT_STATUS_T_ENUM_API}.git_status_index_typechange and not continue then
					ws_status := "typechange: "
				end
				if ws_status.is_empty then
					continue := True
				end

				if not header then
					print("# Changes not staged for commit:%N");
					if rm_in_workdir = 1 then
						print ("# (use %"git add /rm <file>...%" to update what will be committed)%N")
					else
						print ("# (use %"git add <file>...%" to update what will be committed)%N")
					end
					print ("# (use %"git checkout -- <file>...%" to discard changes in working directory)%N")
					print ("#%N");
					header := True
				end

				if attached s.head_to_index as l_head_to_index and then
					attached l_head_to_index.old_file as l_old_file
				then
					old_path := l_old_file.path
				end

				if attached s.head_to_index as l_head_to_index and then
					attached l_head_to_index.new_file as l_new_file
				then
					new_path := l_new_file.path
				end
			end

			if header then
				changed_in_workdir := True
				print ("#%N")
			end

				-- Print untracked files.
			header := False
			across 1 |..| maxi as ic loop
				s := git_status.git_status_byindex (a_status, ic.item - 1)
				if s.status = {GIT_STATUS_T_ENUM_API}.git_status_wt_new then
					if not header then
						print("# Untracked files:%N");
						print("# (use %"git add <file>...%" to include in what will be committed)%N");
						print("#%N");
						header := True;
					end
					print("#%T" + if attached s.index_to_workdir as l_index_workdir and then attached l_index_workdir.old_file as l_old_file and then attached l_old_file.path as l_path then l_path else "" end + "%N")
				end
			end

			header := False
			--	Print ignored files.
			across 1 |..| maxi as ic loop
				s := git_status.git_status_byindex (a_status, ic.item - 1)
				if s.status = {GIT_STATUS_T_ENUM_API}.git_status_ignored then
					if not header then
						print("# Ignored files:%N");
						print("# (use %"git add <file>...%" to include in what will be committed)%N");
						print("#%N");
						header := True;
					end
					print("#%T" + if attached s.index_to_workdir as l_index_workdir and then attached l_index_workdir.old_file as l_old_file and then attached l_old_file.path as l_path then l_path else "" end)
				end
			end

			if not changed_in_index and changed_in_workdir then
				print("%Nno changes added to commit (use %"git add%" and/or %"git commit -a%")%N");
			end

		end


	print_short (a_repo: GIT_REPOSITORY_STRUCT_API; a_status: GIT_STATUS_LIST_STRUCT_API)
			-- This version of the output prefixes each path with two status columns and shows submodule status information.
		do

		end

feature -- Usage

	usage
		local
			str: STRING
		do
			str := "[
				%N
				git_status [--short] [--long] [--porcelain]
					 [--branch] [--z] [--ignored] [--uno] [--unormal] [--uall]
					 [--ignore-submodules] [-git-dir=<dir>]
					 [--list-submodules]
					 ]"
			print("%N")
			print (str)
		end

feature -- Options

	options: OPTIONS

	git_repository: LIBGIT2_REPOSITORY

end
