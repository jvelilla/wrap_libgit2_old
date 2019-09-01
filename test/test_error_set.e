note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_ERROR_SET

inherit
	EQA_TEST_SET
		select
			default_create
		end
	LIBGIT2_REPOSITORY_API
		rename
			default_create as defaul_create_lg
		end
	LIBGIT2_ERROR_API  -- At the moment libgit version 0.28.3 report undefined reference to `git_error_clear', `git_error_set_oom', `git_error_last', `git_error_set_str'
		rename
			default_create as defaul_create_er
		end

feature -- Test routines

	test_open
			-- New test routine
		local
			l_error: INTEGER
			l_rep: GIT_REPOSITORY_STRUCT_API
			init: INTEGER
		do
			init := {LIBGIT2_INITIALIZER_API}.git_libgit2_init
			create l_rep.make
			l_error := git_repository_open (l_rep, "")
			assert ("Error < 0", l_error < 0)
-- TODO check
-- Issue with version 0.28.3 on Linux.			
--			if attached {GIT_ERROR_STRUCT_API} git_error_last as l_gerror then
--				print ("%NMessage: " + if attached l_gerror.message as l_message then l_message else "" end)
--			end
		end

end


