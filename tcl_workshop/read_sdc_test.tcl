#sdc file name is passed in arg1
#we want to get rif of square backets i.e., "[" and "]"
proc read_sdc {arg1} {
#arg1 is the sdc file name, op as the directory where the file is present
set sdc_dirname [file dirname $arg1]
#tail of the $arg1, split based on . as your delimiter(we will get 2 parts : openMSP430 sdc), 0th element is openMSP430.
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
#open sdc file in read mode
set sdc [open $arg1 r]
#whatever processing we do to sdc file that needs to be dumped somewhere, we do that in a file in /tmp/ area in w mode
set tmp_file [open /tmp/1 w]
puts "sdc_dirname is $sdc_dirname"
puts "arg1 is $arg1"
puts "part1 is [file tail $arg1]"
puts "part2 is [split [file tail $arg1] .]"
puts "part3 is [lindex [split [file tail $arg1] .] 0 ]"
puts "sdc_filename is $sdc_filename"

puts -nonewline $tmp_file [string map {"\[" "" "\]" " "} [read $sdc]]     
#op is sdc file without square backets with some {} brackets in between somewhere
close $tmp_file

#-----------------------------------------------------------------------------#
#----------------converting create_clock constraints--------------------------#
#-----------------------------------------------------------------------------#

#converting create_clock statements to one that is needed by openTimer tool
#we hhad closed the below file in w mode, now we are opening it in r mode
set tmp_file [open /tmp/1 r]
#dump the processed output in the below file
set timing_file [open /tmp/3 w]
set lines [split [read $tmp_file] "\n"]
puts $lines
#lsearch-list search; search out all those elements which has "create_clock"
set find_clocks [lsearch -all -inline $lines "create_clock*"]
puts "break1"
puts $find_clocks
puts "break2"
foreach elem $find_clocks {
puts "break3"
#$elem to get index number of "get_ports"=7, +1 would then be = 8, $elem 8 = dco_clk;
	set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
	puts "part1 is [lsearch $elem "get_ports"]"
	puts "part2 is [expr {[lsearch $elem "get_ports"]+1}]"
	puts "part3 is $clock_port_name"
	puts "clock_port_name is $clock_port_name"
	#3,3+1=4,value=1500
	set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
	puts "cp_part1 is [lsearch $elem "-period"]"
	puts "cp_part2 is [expr {[lsearch $elem "-period"]+1}]"
	puts "cp_part3 is $clock_period"
	puts "clock_period is $clock_period"
	#
	set duty_cycle [expr {100 - [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]}]
	puts "dc_part1 is [lsearch $elem "-waveform"]"
	puts "dc_part2 is [expr {[lsearch $elem "-waveform"]+1}]"
	puts "dc_part3 is [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]]"
	puts "dc_part4 is [lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]"
	puts "dc_part5 is [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]"
	puts "dc_part6 is $duty_cycle"
	puts $timing_file "clock $clock_port_name $clock_period $duty_cycle"
	puts "clock $clock_port_name $clock_period $duty_cycle\n"
	}
close $tmp_file
#-----------------------------------------------------------------------------#
#----------------converting set_clock_latency constraints---------------------#
#-----------------------------------------------------------------------------#

#to implement conversion from SDC to openTImer format for set_clock_latency in SDC file
puts "clock_latency"
set find_keyword [lsearch -all -inline $lines "set_clock_latency*"]
puts $find_keyword
set tmp2_file [open /tmp/2 w]
#dummy port name, giving it a value of null
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
	puts "pn_part1 is [lsearch $elem "get_clocks"]"
	puts "pn_part2 is [expr {[lsearch $elem "get_clocks"]+1}]"
	puts "pn_part3 is $port_name"
	puts "port_name is $port_name"
	#if new_port_name matches with port_name,inverse iof 0 is 1 and we enter into the loop
	if {![string match $new_port_name $port_name]} {
        	set new_port_name $port_name
		puts "dont match"
		puts "new_port_name changed to $new_port_name"
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		puts "dl_part1 is [list "*" " " $port_name " " "*"]"
		puts "dl_part2 is [join [list "*" " " $port_name " " "*"] ""]"
		puts "delays_list is $delays_list"
		#dummy value of delay_value
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
			puts "old delay_value is $delay_value"
			puts "port_index is $port_index"
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
			puts "new delay_value $delay_value"
        	}
		puts "entering"
		puts -nonewline $tmp2_file "\nat $port_name $delay_value"
		puts "at $port_name $delay_value\n"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_clock_transition constraints------------------#
#-----------------------------------------------------------------------------#

puts "clock_transition"
set find_keyword [lsearch -all -inline $lines "set_clock_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
        if {![string match $new_port_name $port_name]} {
		set new_port_name $port_name
		set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		puts "delays_list is $delays_list"
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_input_delay constraints-----------------------#
#-----------------------------------------------------------------------------#

puts "input_delay"
set find_keyword [lsearch -all -inline $lines "set_input_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		puts "delays_list is $delays_list"
		set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_input_transition constraints------------------#
#-----------------------------------------------------------------------------#

puts "input_transition"
set find_keyword [lsearch -all -inline $lines "set_input_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		puts "delays_list is $delays_list"
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#---------------converting set_output_delay constraints-----------------------#
#-----------------------------------------------------------------------------#

puts "set_output_delay"
set find_keyword [lsearch -all -inline $lines "set_output_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nrat $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#-------------------converting set_load constraints---------------------------#
#-----------------------------------------------------------------------------#

puts "set_load"
set find_keyword [lsearch -all -inline $lines "set_load*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*" ] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        	set port_index [lsearch $new_elem "get_ports"]
        	lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $timing_file "\nload $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file  [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
close $timing_file

#create .timing file
set ot_timing_file [open $sdc_dirname/$sdc_filename.timing w]
puts "sdc_filename is $sdc_filename"
puts "sdc_dirname is $sdc_dirname"
puts "ot_timing_file is $ot_timing_file"
#/tmp/3 consists of final set of at,rat, etc
set timing_file [open /tmp/3 r]
#read the file till the end of line/file
while {[gets $timing_file line] != -1} {
        if {[regexp -all -- {\*} $line]} {
                set bussed [lindex [lindex [split $line "*"] 0] 1]
		puts "bussed is $bussed in \"$line\""
                set final_synth_netlist [open $sdc_dirname/$sdc_filename.final.synth.v r]
                while {[gets $final_synth_netlist line2] != -1 } {
                        if {[regexp -all -- $bussed $line2] && [regexp -all -- {input} $line2] && ![string match "" $line]} {
				puts "bussed $bussed matches line2 $line2 in $sdc_dirname/$sdc_filename.final.synth.v"
				puts "string \"input\" found in $line2"
				puts "null string \"\" doesn't match $line in $timing_file"

                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
			puts "ot_part1 is [split $line "*"]"
			puts "input_ot_part1 is [lindex [lindex [split $line2 "*"] 0 ] 0 ]"
			puts "input_ot_part2 is [lindex [lindex [split $line2 ";"] 0 ] 1 ]"
			puts "input_ot_part3 is [lindex [split $line "*"] 1 ]"
			puts "input_ot_part is [lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"

                        } elseif {[regexp -all -- $bussed $line2] && [regexp -all -- {output} $line2] && ![string match "" $line]} {
				puts "string \"output\" matches line2 $line2 inin $sdc_dirname/$sdc_filename.final.synth.v"
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
			puts "output_ot_part is [lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        }
                }
        } else {
        puts -nonewline $ot_timing_file  "\n$line"
        }
}

close $timing_file
puts "set_timing_fpath $sdc_dirname/$sdc_filename.timing"
}
read_sdc /home/vsduser/vsdsynth/outdir_openMSP430/openMSP430.sdc
