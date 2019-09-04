note
	description: "Summary description for {OPTIONS}."
	date: "$Date$"
	revision: "$Revision$"

class
	OPTIONS


feature -- Access

	force: BOOLEAN

	progress: BOOLEAN

	perf: BOOLEAN


feature -- Change Element

	set_force (a_val: like force)
		do
			force := a_val
		end

	set_progress (a_val: like progress)
		do
			progress := a_val
		end

	set_perf (a_val: like perf)
		do
			perf := a_val
		end

end
