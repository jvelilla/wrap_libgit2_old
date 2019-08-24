note
	description: "Summary description for {GIT_TREE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_TREE

inherit
	GIT_TREE_API
		rename
			git_tree_lookup as git_tree_lookup_api
		end

feature -- Access

	git_tree_lookup (a_out: GIT_TREE_STRUCT_API; repo: GIT_REPOSITORY_STRUCT_API; id: GIT_OID_STRUCT_API): INTEGER
		local
			l_ptr: POINTER
		do
			Result := c_git_tree_lookup ($l_ptr, repo.item, id.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

end
