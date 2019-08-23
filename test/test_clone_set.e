note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_CLONE_SET

inherit
	EQA_TEST_SET
		redefine
			on_prepare,
			on_clean
		select
			default_create
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
				l_env.system ("rmdir /q /s " + (create {PATH}.make_current).extended ("test_wrapc").out)
			else
				-- Linux
				l_env.system ("rm -rf " + (create {PATH}.make_current).extended ("test_wrapc").out)
			end
		end


feature -- Test routines

	test_clone
		local
			rep: GIT_REPOSITORY_STRUCT_API
			opts: GIT_CLONE_OPTIONS_STRUCT_API
			error: INTEGER
		do
			create rep.make
			error := git_clone (rep, "https://github.com/eiffel-wrap-c/WrapC",  (create {PATH}.make_current).extended ("test_wrapc").out, Void)
			assert ("Expected 0 ", error = 0)
		end

end


