note
	description: "Summary description for {LIBGIT2_CONSTANTS}."
	date: "$Date$"
	revision: "$Revision$"

class
	LIBGIT2_CONSTANTS

feature -- Access

	GIT_STATUS_OPTIONS_VERSION: INTEGER = 1

	GIT_STATUS_OPTIONS_INIT: INTEGER
		do
			Result := GIT_STATUS_OPTIONS_VERSION
		ensure
			is_class: class
		end

end
