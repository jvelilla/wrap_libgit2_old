note
	description: "[
		libgit2 "init" example - shows how to initialize a new repo
		]"
	EIS: "name=git init", "src=https://github.com/libgit2/libgit2/blob/master/examples/init.c","protocol=uri"

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
			create options.make
			create grepository

			make_command_line_parser
			process_arguments
			initialize_repository
		end


feature -- Intiialize Repository

	initialize_repository
		local
			repo: GIT_REPOSITORY_STRUCT_API
			ini: INTEGER
			error: INTEGER
			iniopts: GIT_REPOSITORY_INIT_OPTIONS_STRUCT_API
		do
			ini := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			print ("%N Intializing Libgit2")
			create repo.make
			if options.no_options then
					-- No options were specified, so lets demonstrate the default
					-- simple case of git_repositoy_init API usage.
				if attached options.dir as l_dir then
					error := grepository.git_repository_init (repo, l_dir, False)
					if error /= 0 then
						print ("Could not initialise repository , error code " + error.out)
					end
				end
			else
					-- Some command line options were specified, so we'll use the extended init API to handle them
				create iniopts.make
				iniopts.set_version (1)
				iniopts.set_flags (iniopts.flags | {GIT_REPOSITORY_INIT_FLAG_T_ENUM_API}.git_repository_init_mkpath)

				if options.bare then
					iniopts.set_flags (iniopts.flags | {GIT_REPOSITORY_INIT_FLAG_T_ENUM_API}.git_repository_init_bare)
				end

				if attached options.template  as l_template then
					iniopts.set_flags (iniopts.flags | {GIT_REPOSITORY_INIT_FLAG_T_ENUM_API}.git_repository_init_external_template)
					iniopts.set_template_path (l_template)
				end

				if attached options.gitdir as l_gitdir and then attached options.dir as l_dir then
						-- If you specified a separate git directory, then initialize
						-- the repository at the path and use the second path as the working directory of the
						-- repository (with a git-link file)
					iniopts.set_workdir_path (l_dir)
					options.set_dir (l_gitdir)
				end
				if options.shared /= 0 then
					iniopts.set_mode (options.shared)
				end

				if attached options.dir as l_dir then
					error := grepository.git_repository_init_ext (repo, l_dir, iniopts)
				end
			end

				-- Print a message to the stdout like git init does
			if not options.quiet then
				if options.bare or attached options.gitdir then
					options.set_dir (grepository.git_repository_path (repo))
				else
					options.set_dir ((create {C_STRING}.make_by_pointer (grepository.git_repository_workdir (repo))).string)
				end
				if attached options.dir as l_dir then
					print("%N Initialized empty Git Repository in " + l_dir + "%N")
				end
			end
				-- As an extension to the basic git init this example
				-- gives the options to create an empty initial commit.
				-- This is mostly to demonstrate what it takes to do that, but
				-- also some people like to have that empty base commit in their repo
			if	options.initial_commit then
				create_initial_commit (repo)
			end
			grepository.git_repository_free (repo)
		end


	create_initial_commit (a_repo: GIT_REPOSITORY_STRUCT_API)
			-- Unlike regular `git init` this example shows hot to create
			-- an empty commit in the repository. This is the helper function
			-- that does that.
		local
			sig: GIT_SIGNATURE_STRUCT_API
			index: GIT_INDEX_STRUCT_API
			tree_id, commit_id: GIT_OID_STRUCT_API
			tree: GIT_TREE_STRUCT_API
			signature: GIT_SIGNATURE
			gitindex: GIT_INDEX
			gittree: GIT_TREE
			gitcommit: GIT_COMMIT

		do
			create signature
			create sig.make
			create index.make
			create gitindex
			create gittree

				-- First use the config to initialize a commit signature for the user.		
			if signature.git_signature_default (sig, a_repo) < 0 then
				print ("%N Unable to create a commit signature.%NPherhaps 'user.name' and 'user.email' are not set")
				{EXCEPTIONS}.die (1)
			end

				-- 	Now	let's create an empty tree for this commit

			if grepository.git_repository_index (index, a_repo) < 0 then
				print ("%N Could not open repository index%N")
				{EXCEPTIONS}.die (1)
			end

				-- Outside of this example, you could call git_index_add_bypath
				-- here to put actial files into the index. For our purposes, we'll
			 	-- leave it empty for now.

			create tree_id.make
			if gitindex.git_index_write_tree (tree_id, index) < 0 then
				print ("%NUnable to write initial tree from index%N")
				{EXCEPTIONS}.die (1)
			end

			gitindex.git_index_free (index)

			create tree.make
			if gittree.git_tree_lookup (tree, a_repo, tree_id) < 0 then
				print ("%N Could not look up initial tree%N")
				{EXCEPTIONS}.die (1)
			end
				-- Ready to create initial commit
				--
				-- Normally creating a commit would involve looking up the current
				-- Head commit and making that be the parent of the initial commmit
				-- but here this is the first commit so there will be no parent.

			create commit_id.make
			create gitcommit
			if gitcommit.git_commit_create_v (commit_id,
						a_repo, "HEAD", sig, sig, Void, "Initial commmit", tree, 0) < 0
			then
				print ("Could not create the initial commit")
				{EXCEPTIONS}.die (1)
			end
			gittree.git_tree_free (tree)
			signature.git_signature_free (sig)
		end


feature	{NONE} -- Process Arguments


	process_arguments
			-- Process command line arguments
		local
			shared_value: STRING
		do
			if match_long_option ("q") then
				consume_option
				options.set_quiet (True)
			end

			if match_long_option ("bare") then
				consume_option
				options.set_bare (True)
			end
			if match_long_option ("template") then
				if is_next_option_long_option and then has_next_option_value then
					options.set_template (next_option_value)
					consume_option
				else
					print("%N Missing command line parameter --template=<dir>")
					usage
					{EXCEPTIONS}.die (1)
				end
			end

			if match_long_option ("shared") then
				options.set_shared ({GIT_REPOSITORY_INIT_MODE_T_ENUM_API}.git_repository_init_shared_group)
				if is_next_option_long_option and then has_next_option_value then
					shared_value := next_option_value
					if shared_value.is_case_insensitive_equal_general ("false") or else shared_value.is_case_insensitive_equal_general ("umask") then
						options.set_shared ({GIT_REPOSITORY_INIT_MODE_T_ENUM_API}.git_repository_init_shared_umask)
					elseif shared_value.is_case_insensitive_equal_general ("true") or else shared_value.is_case_insensitive_equal_general ("group") then
						options.set_shared ({GIT_REPOSITORY_INIT_MODE_T_ENUM_API}.git_repository_init_shared_group)
					elseif shared_value.is_case_insensitive_equal_general ("all") or else shared_value.is_case_insensitive_equal_general ("world") then
						options.set_shared ({GIT_REPOSITORY_INIT_MODE_T_ENUM_API}.git_repository_init_shared_all)
					else
						print ("%N Unknown value for shared")
						usage
						{EXCEPTIONS}.die (1)
					end
					consume_option
				end
			end

			if match_long_option ("initial-commit") then
				consume_option
				options.set_initial_commit (True)
			end

			if match_long_option ("separate-git-dir") then
				options.set_gitdir (next_option_value)
				consume_option
			end
			if  has_next_option and then not is_next_option_long_option then
				options.set_dir (next_option)
			else
				print("%N Missing command line parameter <directory>%N")
				usage
				{EXCEPTIONS}.die (1)
			end

		end

	usage
		local
			str: STRING
		do
			str := "[
				%N
				git_init [--q] [--bare] [--template=<dir>]
					 [--shared[=perms]] [--initial-commit]
					 [--separate-git-dir] <directory>
					 ]"
			print("%N")
			print (str)
		end

feature -- Options

	options: OPTIONS
	grepository: LIBGIT2_REPOSITORY

end
