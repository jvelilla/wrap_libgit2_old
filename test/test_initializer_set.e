note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_INITIALIZER_SET

inherit
	EQA_TEST_SET



feature -- Test routines


	test_initialize_shutdown
			-- New test routine
		local
			init: INTEGER
		do
			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			assert ("Expected 1 number of initialization of libgit2", init = 1)
			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			assert ("Expected 2 number of initialization of libgit2", init = 2)

			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_shutdown
			assert ("Expected 1 number of remaining initialization of libgit2", init = 1)

			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_shutdown
			assert ("Expected 0 number of remaining initialization of libgit2", init = 0)

		end

	test_version
		local
			major, minor, rev: INTEGER
		do
			{LIBGIT2_INITIALIZER_API}.c_git_libgit2_version ($major, $minor, $rev)
			assert ("Expected grether than or equal than zero", major >= 0 and then minor >=0 and then rev >=0)
		end
end


