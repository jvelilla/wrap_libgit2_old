note
	description: "[
		libgit2 "ls-files" example - shows how to view all files currently in the index.
		]"
	EIS: "name=git add", "src=https://github.com/libgit2/libgit2/blob/maint/v0.28/examples/ls-files.c","protocol=uri"

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

		do
			create git_repository
			create options.make
			create path.make_from_string (".")
			make_command_line_parser
			process_arguments
			print_paths
		end


feature -- Repository

	print_paths
		local
			ini: INTEGER
			index: GIT_INDEX_STRUCT_API
			repo: GIT_REPOSITORY_STRUCT_API
			entry: GIT_INDEX_ENTRY_STRUCT_API
			git_index: GIT_INDEX
			count: INTEGER
		do
			ini := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			print ("%NIntializing Libgit2%N")

			create index.make
			create repo.make
			create git_index

			if git_repository.git_repository_open_ext (repo, (create {PATH}.make_from_string (path)).out, 0, Void) < 0 then
				print ("%NCould not open repository")
				{EXCEPTIONS}.die (1)
			end

			if git_repository.git_repository_index (index, repo) < 0 then
				print ("%NCould not open repository index")
				{EXCEPTIONS}.die (1)
			end

			create entry.make

				--  if there are no files explicitly listed by the user print all entries in the index
			if options.files.is_empty then
				count := git_index.git_index_entrycount (index)

				across 1 |..| count as ic loop
					if attached {GIT_INDEX_ENTRY_STRUCT_API} git_index.git_index_get_byindex (index, ic.item - 1) as l_entry and then
						attached l_entry.path as l_path
					then
						print (l_path)
						io.put_new_line
					end
				end
			else
				-- loop through the files found in the args and print them if they exist */
				across options.files as ic loop
					if attached {GIT_INDEX_ENTRY_STRUCT_API} git_index.git_index_get_bypath (index, ic.item, {GIT_INDEX_STAGE_T_ENUM_API}.git_index_stage_normal)  then
						print (path)
						io.put_new_line
					elseif options.error_unmatch then
						print ("%NError: pathspec " + path + "did not match any file(s) known to git%N" )
						print ("%NDid you forget to %"git add?%"%N")
					end
				end
			end

			git_index.git_index_free (index)
			git_repository.git_repository_free (repo)
		end



feature	{NONE} -- Process Arguments


	process_arguments
			-- Process command line arguments
		local
			shared_value: STRING
		do
			if match_long_option ("git-dir") then
				if is_next_option_long_option and then has_next_option_value then
					create path.make_from_string (next_option_value)
					consume_option
				else
					print("%N Missing command line parameter --git-dir=<dir>")
					usage
					{EXCEPTIONS}.die (1)
				end
			end

			if match_long_option ("unmarch") then
				options.set_error_unmatch (True)
				consume_option
			end


			from
				if  has_next_option and then not is_next_option_long_option then
					options.add_file (next_option)
					consume_option
				end
			until
				not has_next_option
			loop
				if has_next_option and then not is_next_option_long_option then
					options.add_file (next_option)
					consume_option
				end
			end
		end

	usage
		local
			str: STRING
		do
			str := "[
				git_add [--git-dir] [unmatch] [files]
					[--git-dir]: use the following git repository. 
					[--unmatch]: show unmatched files
					[files]
				]"

			print("%N")
			print (str)
		end

feature -- Options

	git_repository: LIBGIT2_REPOSITORY
	path: STRING
	options: OPTIONS

end
