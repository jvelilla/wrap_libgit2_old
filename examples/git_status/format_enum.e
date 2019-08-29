note
	description: "Summary description for {FORMAT_ENUM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FORMAT_ENUM


feature -- Status Report

	is_valid (a_value: INTEGER): BOOLEAN
			-- Is `a_value' a valid integer code for this enum ?
		do
			Result := a_value = FORMAT_DEFAULT or a_value = FORMAT_LONG or a_value = FORMAT_SHORT or a_value = FORMAT_PORCELAIN
		end

feature -- Access

	FORMAT_DEFAULT: INTEGER = 0
	FORMAT_LONG   : INTEGER = 1
	FORMAT_SHORT  : INTEGER = 2
	FORMAT_PORCELAIN: INTEGER = 3
end
