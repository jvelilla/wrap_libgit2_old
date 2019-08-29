note
	description: "Summary description for {GIT_STATUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_STATUS

inherit

	GIT_STATUS_API
		rename
			git_status_list_new as git_status_list_new_api
		end

feature -- Access

	git_status_list_new (a_out: GIT_STATUS_LIST_STRUCT_API; repo: GIT_REPOSITORY_STRUCT_API; opts: GIT_STATUS_OPTIONS_STRUCT_API): INTEGER
		local
			l_ptr: POINTER
		do
			Result := c_git_status_list_new ($l_ptr, repo.item, opts.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end


end
