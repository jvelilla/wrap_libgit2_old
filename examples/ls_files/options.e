note
	description: "Summary description for {OPTIONS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	OPTIONS

create
	make

feature {NONE} -- Initialization

	make
		do
			create {ARRAYED_LIST [STRING]} files.make (5)
		end

feature -- Access

	files: LIST [STRING]

	error_unmatch: BOOLEAN

feature -- Change element

	add_file (a_element: STRING)
		do
			files.force (a_element)
		end


	set_error_unmatch (a_val: BOOLEAN)
		do
			error_unmatch := a_val
		end

end
