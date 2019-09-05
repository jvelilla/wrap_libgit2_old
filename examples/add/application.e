note
	description: "[
		libgit2 "add" example - shows how to modify the index
		]"
	EIS: "name=git add", "src=https://github.com/libgit2/libgit2/blob/master/examples/add.c","protocol=uri"

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
			create path.make_from_string (".")
			create files.make (1)

			make_command_line_parser
			process_arguments
			add
		end


feature -- Repository

	add
		local
			ini: INTEGER
			index: GIT_INDEX_STRUCT_API
			array: GIT_STRARRAY_STRUCT_API
			count: INTEGER
			payload: PAYLOAD
			matched_cb: GIT_INDEX_MATCHED_PATH_CB_DISPATCHER
			repo: GIT_REPOSITORY_STRUCT_API
			git_index: GIT_INDEX_API
			callback: POINTER
		do
			ini := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			print ("%NIntializing Libgit2%N")

			create index.make
			create array.make
			create payload
			create repo.make

			if git_repository.git_repository_open (repo, (create {PATH}.make_from_string (path)).out) < 0 then
				print ("%NCould not open repository")
				{EXCEPTIONS}.die (1)
			end

			if git_repository.git_repository_index (index, repo) < 0 then
				print ("%NCould not open repository index")
				{EXCEPTIONS}.die (1)
			end

			init_array (array)
--			git_array_to_eiffel_array (array)

				-- Setup a callback if the requested options need it.
			if ((options & VERBOSE) /= 0 ) or ((options & SKIP) /= 0) then
				create matched_cb.make (agent print_matched_cb)
			end

				-- Perform the requested action with the index and files.
			payload.set_options (options)
			payload.set_repository (repo)

			callback := if attached matched_cb as l_matched_cb then l_matched_cb.c_dispatcher else default_pointer end

			create git_index
			if (options & UPDATE) /= 0 then
				ini := git_index.git_index_update_all (index, array, callback, serialize (payload))
			else
				ini := git_index.git_index_add_all (index, array, 0,  callback, serialize (payload))
			end

				-- Clenup memory
			ini := git_index.git_index_write (index)
			git_index.git_index_free (index)
		end

	print_matched_cb (a_path: POINTER; a_matched_pathspec: POINTER; a_payload: POINTER): INTEGER
			--  This callback is called for each file under consideration by
			--  git_index_(update|add)_all above.
			--  It makes uses of the callback's ability to abort the action.
		local
			l_payload: PAYLOAD
			ret: INTEGER
			status: INTEGER
			git_status: GIT_STATUS
			repo: GIT_REPOSITORY_STRUCT_API

		do
			create git_status
			l_payload := deserialize (a_payload)
			if attached l_payload then
				repo := if attached l_payload.repo as l_repo then l_repo else create {GIT_REPOSITORY_STRUCT_API}.make end
			else
				create repo.make
			end
		 		--	Get the file status
		 	if git_status.git_status_file ($status, repo, (create {C_STRING}.make_by_pointer (a_path)).string) < 0 then
				Result := -1
		 	end

			if ((( status & {GIT_STATUS_T_ENUM_API}.GIT_STATUS_WT_MODIFIED )/= 0 ) or ( status & ({GIT_STATUS_T_ENUM_API}.GIT_STATUS_WT_NEW) /= 0 )) and (Result /= -1) then
				print ("add " + (create {C_STRING}.make_by_pointer (a_path)).string  )
				Result := 0
			else
				Result := 1
			end

			if attached l_payload and then (l_payload.options & SKIP) /= 0 then
				Result := 1
			end

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

			if match_long_option ("dry-run") then
				options := options | SKIP
				consume_option
			end

			if match_long_option ("verbose") then
				options := options | VERBOSE
				consume_option
			end

			if match_long_option ("update") then
				options := options | UPDATE
				consume_option
			end

			from
				if  has_next_option and then not is_next_option_long_option then
					files.force (next_option)
					consume_option
				else
					print("%N Missing command line parameter <file>%N")
					usage
					{EXCEPTIONS}.die (1)
				end
			until
				not has_next_option
			loop
				if has_next_option and then not is_next_option_long_option then
					files.force (next_option)
					consume_option
				else
					print ("%NUnexpected parameter%N")
					usage
					{EXCEPTIONS}.die (1)
				end
			end
		end

	usage
		local
			str: STRING
		do
			str := "[
				git_add [--git-dir] [options] file [file] 
					[--git-dir]: use the following git repository. 
					[--dry-run]: dry-run
					[--verbose]: be verbose
					[--update]: update tracked files
					<files>
				]"

			print("%N")
			print (str)
		end

	init_array (a_array: GIT_STRARRAY_STRUCT_API)
		local
			l_array: ARRAY [STRING]
			mp: MANAGED_POINTER

		do
			l_array := files.to_array

			create mp.make (l_array.count * {PLATFORM}.pointer_bytes)
			across l_array as ic  loop
				mp.put_pointer ((create {C_STRING}.make (ic.item)).item, (ic.cursor_index - 1) * {PLATFORM}.pointer_bytes )
			end

			a_array.set_count (l_array.count)
			a_array.set_strings (mp.item)
		end


	 git_array_to_eiffel_array (a_array: GIT_STRARRAY_STRUCT_API)
	 	local
	 		mp: MANAGED_POINTER
	 		l_arr: ARRAY [STRING]
	 		i: INTEGER
	 	do
	 		create mp.make_from_pointer (a_array.strings, a_array.count * {PLATFORM}.pointer_bytes)
	 		create l_arr.make_filled ("", 1, a_array.count)
	 		from

	 		until
				i = a_array.count
	 		loop
				l_arr.put ((create {C_STRING}.make_by_pointer (mp.read_pointer (i*{PLATFORM}.pointer_bytes))).string, i + 1)
				i := i + 1
	 		end

	 	end

	 deserialize (a_pointer: POINTER): PAYLOAD
	 	local
	 		mp: MANAGED_POINTER
	 	do
			create mp.make_from_pointer (a_pointer, {PLATFORM}.integer_32_bytes + {PLATFORM}.pointer_bytes)
			create Result
			Result.set_options (mp.read_integer_32 (0))
			Result.set_repository (create {GIT_REPOSITORY_STRUCT_API}.make_by_pointer (mp.read_pointer ({PLATFORM}.integer_32_bytes)))
	 	end

	 serialize (a_payload: PAYLOAD): POINTER
	 	local
	 		l_ptr: MANAGED_POINTER
	 	do
			create l_ptr.make ({PLATFORM}.integer_32_bytes + {PLATFORM}.pointer_bytes)
			l_ptr.put_integer_32 (a_payload.options, 0)
			l_ptr.put_pointer (a_payload.pointer, {PLATFORM}.integer_32_bytes)
			Result := l_ptr.item
	 	end

feature -- Options

	git_repository: LIBGIT2_REPOSITORY
	path: STRING
	files: ARRAYED_LIST [STRING]
	options: INTEGER

	SKIP: INTEGER = 1
	VERBOSE: INTEGER = 2
  	UPDATE: INTEGER = 4

end
