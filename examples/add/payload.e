note
	description: "Summary description for {PAYLOAD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PAYLOAD

feature {ANY} -- Member Access

	options: INTEGER

	repo: GIT_REPOSITORY_STRUCT_API
		do
			create Result.make_by_pointer (pointer)
		end
		-- repository

feature -- Change Element

	set_options (a_val: INTEGER)
	 	do
			options := a_val
		end

	set_repository (a_repo: GIT_REPOSITORY_STRUCT_API)
		do
			pointer := a_repo.item
		end

	pointer: POINTER

end
