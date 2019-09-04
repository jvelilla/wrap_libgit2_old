note
	description: "[
		libgit2 "checkout" example -  shows how to perform checkouts.
		]"
	EIS: "name=git checkout", "src=https://github.com/libgit2/libgit2/blob/master/examples/checkout.c","protocol=uri"

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
			create options
			create git_repository
			create path.make_from_string (".")

			make_command_line_parser
			process_arguments
			checkout_repository
		end


feature -- Intiialize Repository

	checkout_repository
		local
			repo: GIT_REPOSITORY_STRUCT_API
			ini: INTEGER
			error: INTEGER
			iniopts: GIT_REPOSITORY_INIT_OPTIONS_STRUCT_API
			l_state: INTEGER
			checkout_target: GIT_ANNOTATED_COMMIT_STRUCT_API
			commit: GIT_ANNOTATED_COMMIT_API
		do
			ini := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			print ("%N Intializing Libgit2")
			create repo.make
			create commit
			if git_repository.git_repository_open (repo, (create {PATH}.make_from_string (path)).out) < 0 then
				print ("%NCould not open repository")
				{EXCEPTIONS}.die (1)
			end

			create checkout_target.make

				-- Make sure we're not about to checkout while something else is going on 			
			l_state := git_repository.git_repository_state (repo)

			if l_state /= {GIT_REPOSITORY_STATE_T_ENUM_API}.GIT_REPOSITORY_STATE_NONE then
				print ("%N Repository is in unexpected state -> " + l_state.out )
				commit.git_annotated_commit_free(checkout_target)
				{EXCEPTIONS}.die (1)
			end

			if attached checkout as l_checkout and then resolve_refish (checkout_target, repo, l_checkout ) /= 0 then
				print ("%NFailed to resolve")
				commit.git_annotated_commit_free(checkout_target)
			else
				error := perform_checkout_ref (repo, checkout_target, options)
			end

		end

	print_checkout_progress (a_path: POINTER; a_completed_steps: INTEGER; a_total_steps: INTEGER; a_playload: POINTER)
			--	This function is called to report progression, ie. it's called once with
			-- 	a NULL path and the number of total steps, then for each subsequent path,
			-- 	the current completed_step value.
		do
			if a_path = default_pointer then
				print("%Ncheckout started:" + a_total_steps.out + " steps" );
			else
				print ("%Ncheckout " + (create {C_STRING}.make_by_pointer (a_path)).string +" "  +a_completed_steps.out + " " + a_total_steps.out)
			end
		end


	print_perf_data (a_perfdata: POINTER; a_payload: POINTER)
			-- * This function is called when the checkout completes, and is used to report the
			-- * number of syscalls performed.
		local
			l_perfdata: GIT_CHECKOUT_PERFDATA_STRUCT_API
		do
			create l_perfdata.make_by_pointer (a_perfdata)
			print ("%N perf: stat: %"" +l_perfdata.stat_calls.out + "  %Nmkdir: " + l_perfdata.mkdir_calls.out + " %Nchmod" + l_perfdata.chmod_calls.out )
		end


	perform_checkout_ref (a_repo: GIT_REPOSITORY_STRUCT_API; a_target: GIT_ANNOTATED_COMMIT_STRUCT_API; a_otions: OPTIONS): INTEGER
			-- This is the main "checkout <branch>" function, responsible for performing
			-- a branch-based checkout.
		local
			l_checkout_opts: GIT_CHECKOUT_OPTIONS_STRUCT_API
			err: INTEGER
			target_commit: GIT_COMMIT_STRUCT_API
			cp_dispatcher: GIT_CHECKOUT_PROGRESS_CB_DISPATCHER
			cf_dispatcher: GIT_CHECKOUT_PERFDATA_CB_DISPATCHER
			git_commit: GIT_COMMIT
			git_an_commit: GIT_ANNOTATED_COMMIT
			git_object: GIT_OBJECT_STRUCT_API
			git_checkout: GIT_CHECKOUT_API
		do
			create cp_dispatcher.make (agent print_checkout_progress)
			create cf_dispatcher.make (agent print_perf_data)
			create l_checkout_opts.make
			l_checkout_opts.set_version (1) -- GIT_CHECKOUT_OPTIONS_VERSION
			l_checkout_opts.set_checkout_strategy ({GIT_CHECKOUT_STRATEGY_T_ENUM_API}.GIT_CHECKOUT_SAFE)
			create target_commit.make

				-- Setup our checkout options from the parsed options.
			if a_otions.force then
				l_checkout_opts.set_checkout_strategy ({GIT_CHECKOUT_STRATEGY_T_ENUM_API}.git_checkout_force)
			end

			if a_otions.progress then
				l_checkout_opts.set_progress_cb (cp_dispatcher.c_dispatcher)
			end

			if a_otions.perf then
				l_checkout_opts.set_perfdata_cb (cf_dispatcher.c_dispatcher)
			end

				-- Grab the commit we're interested to move to.
			create git_commit
			create git_an_commit
			Result := git_commit.git_commit_lookup (target_commit, a_repo, if attached git_an_commit.git_annotated_commit_id (a_target) as l_commit then l_commit else create {GIT_OID_STRUCT_API}.make end)
			if Result /= 0 then
				print ("%NFailed to lookup commit")
				git_commit.git_commit_free (target_commit)
			end


				-- Perform the checkout so the workdir corresponds to what target_commit contains. 			
				--Note that it's okay to pass a git_commit here, because it will be peeled to a tree.
			if Result = 0 then
				create git_checkout
				create git_object.make_by_pointer (target_commit.item)
				Result := git_checkout.git_checkout_tree (a_repo, git_object, l_checkout_opts)
				if Result /= 0 then
					print ("%NFailed to checkout tree")
				end
			end

			if Result = 0 then
				-- Now that the checkout has completed, we have to update HEAD.
				-- Depending on the "origin" of target (ie. it's an OID or a branch name), we might need to detach HEAD.

				if attached git_an_commit.git_annotated_commit_ref (a_target) as l_refname then
					Result := git_repository.git_repository_set_head (a_repo, l_refname)
				else
					Result := git_repository.git_repository_set_head_detached_from_annotated (a_repo, a_target)
				end

				if Result /= 0 then
					print ("%N failed to update HEAD reference")
					git_commit.git_commit_free (target_commit)
				end
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

			if match_long_option ("force") then
				consume_option
				options.set_force (True)
			end

			if match_long_option ("progress") then
				consume_option
				options.set_progress (True)
			end

			if match_long_option ("perf") then
				consume_option
				options.set_perf (True)
			end

			if  has_next_option and then not is_next_option_long_option then
				create checkout.make_from_string (next_option)
			else
				print("%N Missing command line parameter <checkout>%N")
				usage
				{EXCEPTIONS}.die (1)
			end
		end

	usage
		local
			str: STRING
		do
			str := "[
				git_checkout 
					[--git-dir]: use the following git repository. 
					[--force]: force the checkout.		
					[--progress]: show checkout progress
					[--perf]: show performance data
					<checkout>
				]"

			print("%N")
			print (str)
		end


	resolve_refish (a_target: GIT_ANNOTATED_COMMIT_STRUCT_API; a_repo: GIT_REPOSITORY_STRUCT_API; a_refish: STRING): INTEGER
			-- Convert a refish to an annotated commit.
		local
			ref: GIT_REFERENCE_STRUCT_API
			obj: GIT_OBJECT_STRUCT_API
			git_ref: GIT_REFERENCE
			err:  INTEGER
			gcommit: GIT_ANNOTATED_COMMIT
			grev: GIT_REVPARSE
			gobj: GIT_OBJECT_API
		do
			create gcommit
			create git_ref
			create ref.make
			Result := git_ref.git_reference_dwim (ref, a_repo, a_refish)
			if Result = {GIT_ERROR_CODE_ENUM_API}.GIT_OK  then
				err := gcommit.git_annotated_commit_from_ref (a_target, a_repo, ref)
				git_ref.git_reference_free (ref)
			else
				create grev
				create obj.make
				create gobj
				Result := grev.git_revparse_single (obj, a_repo, a_refish)
				if Result = {GIT_ERROR_CODE_ENUM_API}.GIT_OK  and then attached gobj.git_object_id (obj) as l_oid then
					Result := gcommit.git_annotated_commit_lookup (a_target, a_repo, l_oid )
					gobj.git_object_free(obj)
				else
					Result := -1
				end
			end
		end

feature -- Options

	options: OPTIONS
	git_repository: LIBGIT2_REPOSITORY
	path: STRING
	checkout: detachable STRING

end
