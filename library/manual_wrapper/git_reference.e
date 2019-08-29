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
			git_reference_shorthand as git_reference_shorthand_api
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


end
