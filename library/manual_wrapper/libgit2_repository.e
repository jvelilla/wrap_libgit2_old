note
	description: "Summary description for {LIBGIT2_REPOSITORY}."
	date: "$Date$"
	revision: "$Revision$"
	EIS:"name=repository", "src=https://libgit2.org/libgit2/#HEAD/group/repository", "protocol=uri"

class
	LIBGIT2_REPOSITORY

inherit

	LIBGIT2_REPOSITORY_API
		rename
			git_repository_init as git_repository_init_api,
			git_repository_init_ext as git_repository_init_ext_api,
			git_repository_open as git_repository_open_api,
			git_repository_open_ext as git_repository_open_ext_api,
			git_repository_open_bare as git_repository_open_bare_api,
			git_repository_discover as git_repository_discover_api
		end

feature -- Access

	git_repository_open (a_out: GIT_REPOSITORY_STRUCT_API; path: STRING): INTEGER
		local
			path_c_string: C_STRING
			l_ptr: POINTER
		do
			create path_c_string.make (path)
			Result := c_git_repository_open ($l_ptr, path_c_string.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

	git_repository_open_ext (a_out: GIT_REPOSITORY_STRUCT_API; path: STRING; flags: INTEGER; ceiling_dirs: detachable STRING): INTEGER
		local
			path_c_string: C_STRING
			ceiling_dirs_c_string: C_STRING
			l_str_ptr: POINTER
			l_ptr: POINTER
		do
			if attached ceiling_dirs then
				create ceiling_dirs_c_string.make (path)
				l_str_ptr := ceiling_dirs_c_string.item
			end
			create path_c_string.make (path)
			Result := c_git_repository_open_ext ($l_ptr, path_c_string.item, flags, l_str_ptr)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end


	git_repository_init (a_out: GIT_REPOSITORY_STRUCT_API; path: STRING; is_bare: BOOLEAN): INTEGER
		local
			path_c_string: C_STRING
			l_ptr: POINTER
		do
			create path_c_string.make (path)
			Result := c_git_repository_init ($l_ptr, path_c_string.item, is_bare.to_integer)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

	git_repository_init_ext (a_out: GIT_REPOSITORY_STRUCT_API; repo_path: STRING; opts: GIT_REPOSITORY_INIT_OPTIONS_STRUCT_API): INTEGER
		local
			repo_path_c_string: C_STRING
			l_ptr: POINTER
		do
			create repo_path_c_string.make (repo_path)
			Result := c_git_repository_init_ext ($l_ptr, repo_path_c_string.item, opts.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

	git_repository_open_bare (a_out: GIT_REPOSITORY_STRUCT_API; bare_path: STRING): INTEGER
		local
			bare_path_c_string: C_STRING
			l_ptr: POINTER
		do
			create bare_path_c_string.make (bare_path)
			Result := c_git_repository_open_bare ($l_ptr, bare_path_c_string.item)
			if l_ptr /= default_pointer then
				a_out.make_by_pointer (l_ptr)
			end
		end

	git_repository_discover (a_out: GIT_BUF_STRUCT_API; start_path: STRING; across_fs: INTEGER; ceiling_dirs: detachable STRING): INTEGER
		local
			start_path_c_string: C_STRING
			ceiling_dirs_c_string: C_STRING
			l_ceiling_ptr: POINTER
			l_ptr: POINTER
		do
			create start_path_c_string.make (start_path)
			if attached ceiling_dirs then
				create ceiling_dirs_c_string.make (ceiling_dirs)
				l_ceiling_ptr := ceiling_dirs_c_string.item
			end
			Result := c_git_repository_discover (a_out.item, start_path_c_string.item, across_fs, l_ceiling_ptr)
		end

end
