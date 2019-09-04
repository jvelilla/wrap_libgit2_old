note
	description: "Summary description for {GIT_REFERENCE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_REFERENCE

inherit

	GIT_REFERENCE_API
		rename
			git_reference_shorthand as git_reference_shorthand_api,
			git_reference_dwim as git_reference_dwim_api
		end


feature -- Access

	git_reference_shorthand (ref: GIT_REFERENCE_STRUCT_API): STRING
		local
			l_ptr: POINTER
		do
			l_ptr := c_git_reference_shorthand (ref.item)
			if l_ptr /= default_pointer then
				Result := (create {C_STRING}.make_by_pointer (l_ptr)).string
			else
				Result := ""
			end
		end

	git_reference_dwim (a_out: GIT_REFERENCE_STRUCT_API; repo: GIT_REPOSITORY_STRUCT_API; shorthand: STRING): INTEGER
		local
			shorthand_c_string: C_STRING
			l_ptr: POINTER
		do
			create shorthand_c_string.make (shorthand)
			Result := c_git_reference_dwim ($l_ptr, repo.item, shorthand_c_string.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

end
