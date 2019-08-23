note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_REPOSITORY_SET

inherit
	EQA_TEST_SET
		redefine
			on_prepare,
			on_clean
		select
			default_create
		end

	LIBGIT2_REPOSITORY
		rename
			default_create as default_create_rp
		end
	GIT_CLONE
		rename
			default_create as default_create_cl
		end


feature {NONE} -- Events

	on_prepare
			-- <Precursor>
		local
			init: INTEGER
		do
			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			assert ("Expected 1 number of initialization of libgit2", init = 1)
		end

	on_clean
			-- <Precursor>
		local
			init: INTEGER
			l_env: EXECUTION_ENVIRONMENT
		do
			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_shutdown
			assert ("Expected 0 number of remaining initialization of libgit2", init = 0)
			create l_env
			if {PLATFORM}.is_windows then
				l_env.system ("rmdir /q /s " + (create {PATH}.make_current).extended ("tmp").out)
				l_env.system ("rmdir /q /s " + (create {PATH}.make_current).extended ("test_wrapc").out)
			else
					-- Linux
				l_env.system ("rm -rf " + (create {PATH}.make_current).extended ("tmp").out)
				l_env.system ("rm -rf " + (create {PATH}.make_current).extended ("test_wrapc").out)
			end
		end

feature -- Test routines

	test_repository_init_wiht_working_directory
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_repository_init (l_rep, (create {PATH}.make_current).extended ("tmp").out,False)
			assert ("Expected 0", error = 0)
		end

	test_repository_init_bare
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_repository_init (l_rep, (create {PATH}.make_current).extended ("tmp").out,True)
			assert ("Expected 0", error = 0)
		end

	test_repository_init_options
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
			opts: GIT_REPOSITORY_INIT_OPTIONS_STRUCT_API
		do
			create opts.make
				--Customize options
			opts.set_version (1)
				--Mkdir as needed to create repo
			opts.set_flags (opts.flags| {GIT_REPOSITORY_INIT_FLAG_T_ENUM_API}.git_repository_init_mkpath)
			opts.set_description ("My repository has a custom description")
			create l_rep.make
			error := git_repository_init_ext (l_rep, (create {PATH}.make_current).extended ("tmp").out, opts)
			assert ("Expected 0", error = 0)
		end

	test_repository_open_working_directory_success
			-- New test routine
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_repository_init (l_rep, (create {PATH}.make_current).extended ("tmp").out,False)
			assert ("Expected 0", error = 0)

			create l_rep.make
			error := git_repository_open (l_rep, (create {PATH}.make_current).extended ("tmp").out)
			assert ("Expected 0", error = 0)
		end


	test_repository_open_bare_success
			-- New test routine
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_repository_init (l_rep, (create {PATH}.make_current).extended ("tmp").out,True)
			assert ("Expected 0", error = 0)

			create l_rep.make
			error := git_repository_open (l_rep, (create {PATH}.make_current).extended ("tmp").out)
			assert ("Expected 0", error = 0)
		end

	test_repository_open_failure
			-- New test routine
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_repository_open (l_rep, (create {PATH}.make_current).extended ("error").out)
			assert ("Expected error code", error < 0)
		end


	test_repository_open_options
			-- New test routine
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_clone (l_rep, "https://github.com/eiffel-wrap-c/WrapC",  (create {PATH}.make_current).extended ("test_wrapc").out, Void)
			assert ("Expected 0 ", error = 0)

				-- Open repository, walking up from given directory to find root
			create l_rep.make
			error := git_repository_open_ext (l_rep, (create {PATH}.make_current).extended ("test_wrapc").extended("src").out, 0, Void)
			assert ("Expected error code", error = 0)

				-- Open repository, in given directory
			create l_rep.make
			error := git_repository_open_ext (l_rep, (create {PATH}.make_current).extended ("test_wrapc").out, {GIT_REPOSITORY_OPEN_FLAG_T_ENUM_API}.git_repository_open_no_search, Void)
			assert ("Expected error code", error = 0)
		end

	test_repository_open_bare
			-- New test routine
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_clone (l_rep, "https://github.com/eiffel-wrap-c/WrapC",  (create {PATH}.make_current).extended ("test_wrapc").out, Void)
			assert ("Expected 0 ", error = 0)

				-- Open repository, walking up from given directory to find root
			create l_rep.make
			error := git_repository_open_bare (l_rep, (create {PATH}.make_current).extended ("test_wrapc").extended(".git").out)
			assert ("Expected error code", error = 0)
		end

	test_repository_find
			-- New test routine
		local
			l_rep: GIT_REPOSITORY_STRUCT_API
			l_buf: GIT_BUF_STRUCT_API
			error: INTEGER
		do
			create l_rep.make
			error := git_clone (l_rep, "https://github.com/eiffel-wrap-c/WrapC",  (create {PATH}.make_current).extended ("test_wrapc").out, Void)
			assert ("Expected 0 ", error = 0)

				-- Check if a given path is inside a repository and return the repository root if found.
			create l_buf.make
			error := git_repository_discover (l_buf, (create {PATH}.make_current).extended ("test_wrapc").extended("src").extended ("library").out, 0, Void)
			assert ("Expected error code", error = 0)
		end



end


