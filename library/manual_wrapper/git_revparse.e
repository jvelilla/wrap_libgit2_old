note
	description: "Summary description for {GIT_REVPARSE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_REVPARSE

inherit

	GIT_REVPARSE_API
		rename
			git_revparse_single as git_revparse_single_api
		end

feature -- Access

	git_revparse_single (a_out: GIT_OBJECT_STRUCT_API; repo: GIT_REPOSITORY_STRUCT_API; spec: STRING): INTEGER
		local
			spec_c_string: C_STRING
			l_ptr: POINTER
		do
			create spec_c_string.make (spec)
			Result := c_git_revparse_single ($l_ptr, repo.item, spec_c_string.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end
end
