note
	description: "Summary description for {GIT_COMMIT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GIT_COMMIT

inherit

	GIT_COMMIT_API
		rename
			git_commit_create_v as git_commit_create_v_api
		end


feature -- Access

	git_commit_create_v (id: GIT_OID_STRUCT_API; repo: GIT_REPOSITORY_STRUCT_API; update_ref: STRING; author: GIT_SIGNATURE_STRUCT_API; committer: GIT_SIGNATURE_STRUCT_API; message_encoding: detachable STRING; message: STRING; tree: GIT_TREE_STRUCT_API; parent_count: INTEGER): INTEGER
		local
			l_ptr: POINTER
			update_ref_c_string: C_STRING
			message_encoding_c_string: C_STRING
			message_c_string: C_STRING
			l_msg_encoding: POINTER
		do
			create update_ref_c_string.make (update_ref)
			if attached message_encoding then
				create message_encoding_c_string.make (message_encoding)
				l_msg_encoding := message_encoding_c_string.item
			end

			create message_c_string.make (message)
			Result := c_git_commit_create_v ($l_ptr, repo.item, update_ref_c_string.item, author.item, committer.item, l_msg_encoding, message_c_string.item, tree.item, parent_count)
			if l_ptr /= default_pointer then
				id.make_by_pointer (l_ptr)
			end
		end


end
