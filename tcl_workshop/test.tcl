proc set_multi_cpu_usage {args} {
	array set options {-localCpu <num_of_threads> -help "" }
	foreach {switch value} [array get options] {
		puts "Option $switch is $value"
	}
	#puts "llength is [llength $args]"
	#return
	
	while {[llength $args]} {
		puts "llength is [llength $args]"
		puts "lindex 0 of \"$args\" is [lindex $args 0]"
		switch -glob -- [lindex $args 0] {
			-localCpu {
				puts "old args is $args"
				set args [lassign $args - options(-localCpu)]
				puts "new args is \"$args\""
				puts "set_num_threads $options(-localCpu)"
			}
			-help {
				puts "old args is $args"
				set args [lassign $args - options(-localCpu)]
				puts "new args is \"$args\""
				puts "set_num_threads $options(-localCpu)"
			}
		}
	}
}
set_multi_cpu_usage -localCpu 8 -help

