note
	description: "Summary description for {GIT_INDEX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_INDEX

inherit

	GIT_INDEX_API
		rename
			git_index_write_tree as git_index_write_tree_api
		end


feature -- Access

	git_index_write_tree (a_out: GIT_OID_STRUCT_API; index: GIT_INDEX_STRUCT_API): INTEGER
		local
			l_ptr: POINTER
		do
			Result := c_git_index_write_tree ($l_ptr, index.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

end
