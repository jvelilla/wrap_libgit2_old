note
	description: "Summary description for {GIT_CLONE}."
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_CLONE

inherit

	GIT_CLONE_API
		rename
			git_clone as git_clone_api
		end


feature -- Access

	git_clone (a_out: GIT_REPOSITORY_STRUCT_API; url: STRING; local_path: STRING; options: detachable GIT_CLONE_OPTIONS_STRUCT_API): INTEGER
		local
			url_c_string: C_STRING
			local_path_c_string: C_STRING
			l_ptr: POINTER
			l_options: POINTER
		do
			if attached options then
				l_options := options.item
			end
			create url_c_string.make (url)
			create local_path_c_string.make (local_path)
			Result := c_git_clone ($l_ptr, url_c_string.item, local_path_c_string.item, l_options)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end


end
