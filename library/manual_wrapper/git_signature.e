note
	description: "Summary description for {GIT_SIGNATURE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_SIGNATURE

inherit

	GIT_SIGNATURE_API
		rename
			git_signature_default as git_signature_default_api
		end

feature -- Access

	git_signature_default (a_out: GIT_SIGNATURE_STRUCT_API; repo: GIT_REPOSITORY_STRUCT_API): INTEGER
		local
			l_ptr: POINTER
		do
			Result := c_git_signature_default ($l_ptr, repo.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end


end
