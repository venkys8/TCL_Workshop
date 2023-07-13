#!/usr/bin/tclsh
#----------------------------------------------------------------#
#---------Checks whether vsdsynth usage is correct or not--------#
#----------------------------------------------------------------#
#DAY2
set enable_prelayout_timing 1
set working_dir [exec pwd]
set vsd_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $vsd_array_length-1]

if {![regexp {^csv} $input] || $argc != 1} {
	puts "Error in usage"
	puts "Usage : ./vsdsynth <.csv>"
	puts "where <.csv> files has below inputs"
	exit
} else {
	#puts " This is else part\n"
#---------------------------------------------------------------------------------------------------------------------#
#--------------converts .csv to matrix and re-creates the variables provided in the first column of the .csv as-------#
#-------------"DesignLibrary, OutputDirectory, NetlistDirectory etc..." Incase of modification, use above variables---# 
#------------------------as starting point. Use "puts" command to report above variables------------------------------#
#---------------------------------------------------------------------------------------------------------------------#
	#filename becomes the .csv file, filemame = openMSP430_design_details.csv
	set filename [lindex $argv 0]
	package require csv
	package require struct::matrix
	struct::matrix m
	#$fp would be an openend filename i.e, the _.csv file
	set fp [open $filename r]
	#identify size of matrix based on , (columns,rows)
	csv::read2matrix $fp m , auto
	close $fp
	#extract num_cols=2
	set cols [m columns]
	m link m_arr
	#extract num_rows=6
	set num_rows [m rows]
	set i 0
	#loop thru col=0 to set/create variable name
	while {$i < $num_rows} {
		puts "\nINFO: Setting $m_arr(0,$i) as '$m_arr(1,$i)'"
		#first row is a design name, all others are path/files
		if {$i == 0} {
			#replace space with no-space, set it to value of next cell
			set [string map {" " ""} $m_arr(0,$i)] $m_arr(1,$i)
		} else {
			set [string map {" " ""} $m_arr(0,$i)] [file normalize $m_arr(1,$i)]
		}
		incr i
	}
	#while loop exits after $i=0,1,2,3,4,5
}
puts "\nINFO: After processing input .csv file, below are the list of initial variables & their values"
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"
#----------------------------------------------------------------------------------------------#
#-------Below script checks if directories & files mentioned in .csv file, exists or not-------#
#----------------------------------------------------------------------------------------------#
# Check if paths and files exist or not, break when not present
if {![file isdirectory $OutputDirectory]} {
	puts "\nINFO: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
	file mkdir $OutputDirectory
} else {
	puts "\nINFO: Output directory found in path $OutputDirectory"
}

if {![file exists $NetlistDirectory]} {
	puts "\nERROR: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting..."
	exit
} else {
	puts "\nINFO: RTL netlist directory found in path $NetlistDirectory"
}

if {![file exists $EarlyLibraryPath]} {
	puts "\nERROR: Cannot find early library cell in path $EarlyLibraryPath. Exiting..."
	exit
} else {
	puts "\nINFO: Early cell library found in path $EarlyLibraryPath"
}

if {![file exists $LateLibraryPath]} {
	puts "\nERROR: Cannot find late library cell in path $LateLibraryPath. Exiting..."
	exit
} else {
	puts "\nINFO: Late cell library found in path $LateLibraryPath"
}

if {![file exists $ConstraintsFile]} {
	puts "\nERROR: Cannot find constraints file in path $ConstraintsFile. Exiting..."
	exit
} else {
	puts "\nINFO: Constraints file found in path $ConstraintsFile"
}
#puts "Coded till file/directory checking, update pending"
#----------------------------------------------------------------------------------------------#
#-------------------------------Constraints FILE creation, SDC Format--------------------------#
#----------------------------------------------------------------------------------------------#

puts "\nInfo: Dumping SDC constraints for $DesignName"
struct::matrix constraints
set chan [open $ConstraintsFile r]
csv::read2matrix $chan constraints , auto
close $chan
#get the num_rows of the matrix 
set num_rows [constraints rows]
puts "num of rows = $num_rows"
set num_columns [constraints columns]
puts "num of columns = $num_columns"
#check row num for CLOCKS & col nuw for "IO delays and slew section" in constraints.csv
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
puts "clock_start = $clock_start"

set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "clock_start_column = $clock_start_column"

set clock_period_start [lindex [lindex [constraints search all frequency] 0] 0]
puts "clock_period_start = $clock_period_start"

set duty_cycle_start [lindex [lindex [constraints search all duty_cycle] 0] 0]
puts "duty_cycle_start = $duty_cycle_start"

#check row num for INPUTS 
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "input_ports_start = $input_ports_start"

#check row num for OUTPUTS
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "output_ports_start = $output_ports_start"

#DAY3
#--------------------------------------------------------------------------------------#
#---------------------------------clock constraints------------------------------------#
#---------------------------------clock latency constraints----------------------------#
#--------------------------------------------------------------------------------------#

#constraints search rect 0 0 [11-1] [4-1] early rise delay ->[lindex {3 0}]
set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]


#--------------------------------------------------------------------------------------#
#---------------------------------clock transition constraints-------------------------#
#--------------------------------------------------------------------------------------#
set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$num_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]

#read the constraints file for .csv and convert to SDC format
#open new sdc file in write mode, it never existed, we are creating a new file
set sdc_file [open $OutputDirectory/$DesignName.sdc w]
#set i 1
set i [expr {$clock_start+1}]
#end_of_ports = 4-1 = 3
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints............."

#while { 1<3 }
while { $i < $end_of_ports } {
	#puts "working on clock [constraints get cell 0 $i]"
	puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
	
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"

	puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	incr i
}
#puts "Before creating input delay & slew constraints"
#puts "End of processing CLOCKS "

#--------------------------------------------------------------------------------------#
#---------------------------------create input delay & slew constraints----------------#
#--------------------------------------------------------------------------------------#
#puts "Begin : processing INPUTS section of .csv"
#puts "setting-up search space for INPUTS"
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
puts "early_rise_delay = $input_early_rise_delay_start"
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
	puts "early_fall_delay is $input_early_fall_delay_start"
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
	puts "late_rise_delay is $input_late_rise_delay_start"
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]
	puts "late_fall_delay is $input_late_fall_delay_start"

set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
	puts "early_rise_slew is $input_early_rise_slew_start"
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
	puts "early_fall_slew is $input_early_fall_slew_start"
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
	puts "late_rise_slew is $input_late_rise_slew_start"
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]
	puts "late_fall_slew is $input_late_fall_slew_start"

#get column number for clocks param of INPUT also-> lindex [10 26 clocks]=> related_clock = 9
set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$num_columns-1}] [expr {$output_ports_start-1}] clocks] 0] 0]

#set i [4+1]
set i [expr {$input_ports_start+1}]
#end_of_ports [27-1]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nInfo-SDC: Working on IO constraints......."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"

while { $i < $end_of_ports} {
#differentiating input ports as bussed or bits
	#$netlist collection of all *.v in serial format,separated by space
	set netlist [glob -dir $NetlistDirectory *.v]
	#open file 1 in tmp directory
	set tmp_file [open /tmp/1 w]

	#to access each space separated netlist,assigned to fp. or, get hold of all netlist and store it in fp
	foreach fp $netlist {
		#open each netlist in read mode, fd is each netlist one by one
		set fd [open $fp r]
		puts "reading file $fp"
		#reads every line of netlist, -1 referred to as end of line
		while {[gets $fd line] != -1} {
			#pattern1 for cpu_en will look like => " cpu_en;"
			set pattern1 " [constraints get cell 0 $i];"
			#-all : search in entire line, search for pattern1 in $line, when found 
			if {[regexp -all -- $pattern1 $line]} {
				puts "pattern1 \"$pattern1\" found & matching line in verilog file \"$fp\" is \"$line\""
				#split based on ;, we get 2 elements of the list, get the 0th element of list
				set pattern2 [lindex [split $line ";"] 0]
				puts "creating pattern2 by splitting pattern1 using semicolon as delimiter => \"$pattern2\""
				#S+ : multiple spaces
				if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
					puts "out of all patterns, \"$pattern2\" has matching string \"input\", so preserving this line and ignoring others"
					#split pattern2 based on spaces
					set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
					puts "printing first 3 elements of pattern2 as \"$s1\" using space as delimiter"
					#replace xle spaces with a single space
					puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
					puts "replace multiple spaces in s1 by single space & reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
			}
		}
		close $fd
	}
	close $tmp_file


	#open /tmp/1 in r mode
	set tmp_file [open /tmp/1 r]
	#puts "reading [read $tmp_file]"
	#puts "reading /tmp/1 file as [split [read $tmp_file] \n]"
	#puts "sorting /tmp/1 contents as [lsort -unique [split [read $tmp_file] \n ]]"
	#puts "joining /tmp/1 as [join [lsort -unique [split [read $tmp_file] \n ]] \n]"
	set tmp2_file [open /tmp/2 w]
	puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
	close $tmp_file
	close $tmp2_file

	set tmp2_file [open /tmp/2 r]
	#puts "count is [llength [read $tmp2_file]]"
	#set count to check for bussed/bit ports
	#length of the string is 2 for - input cpu_en, llength is used to get count of string
	set count [llength [read $tmp2_file]]
	#puts "splitting content of tmp_2 using space and counting number of elements as $count"
	if {$count > 2} {
		set inp_ports [concat [constraints get cell 0 $i]*]
		puts "bussed"
	} else 	{
		set inp_ports [constraints get cell 0 $i]
		puts "not bussed"
	}
	puts "input port name is $inp_ports since count is $count\n"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts "early_rise_delay is $input_early_rise_delay_start"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
	puts "early_fall_delay is $input_early_fall_delay_start"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i]  \[get_ports $inp_ports\]"
	puts "late_rise_delay is $input_late_rise_delay_start"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i]  \[get_ports $inp_ports\]"
	puts "late_fall_delay is $input_late_fall_delay_start"
		
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
	puts "early_rise_slew is $input_early_rise_slew_start"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
	puts "early_fall_slew is $input_early_fall_slew_start"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start  $i] \[get_ports $inp_ports\]"
	puts "late_rise_slew is $input_late_rise_slew_start"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start  $i] \[get_ports $inp_ports\]"
	puts "late_fall_slew is $input_late_fall_slew_start"

	incr i
}
close $tmp2_file
#DAY4
#--------------------------------------------------------------------------------------#
#--------------------------------create output delay & load constraints----------------#
#--------------------------------------------------------------------------------------#

puts "Begin : processing OUTPUTS section of .csv"
puts "setting-up search space again "
set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$num_columns-1}] [expr {$num_rows-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$num_columns-1}] [expr {$num_rows-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$num_columns-1}] [expr {$num_rows-1}] late_rise_delay] 0] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$num_columns-1}] [expr {$num_rows-1}] late_fall_delay] 0] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$num_columns-1}] [expr {$num_rows-1}] load] 0] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$num_columns-1}] [expr {$num_rows-1}] clocks] 0] 0]

set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$num_rows}]
puts "\Info-SDC: Working on IO constraints........"
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports} {
#differentiating input ports as bussed or bits
	#puts "reading file, inside while loop"
	#$netlist collection of all *.v in serial format
	set netlist [glob -dir $NetlistDirectory *.v]
	#open file 1 in tmp directory
	set tmp_file [open /tmp/1 w]

	#to access each space separated netlist,assigned to fp
	foreach fp $netlist {
		set fd [open $fp r]
		#puts "reading file $fp inside netlist foreach loop"
		#reads every line of netlist, -1 is end of line
		while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i];"
			#-all : search in entire line, search for pattern1 in $line, when found 
			if {[regexp -all -- $pattern1 $line]} {
				#puts "pattern1 \"$pattern1\" found & matching line in verilog file \"$fp\" is \"$line\""
				#split based on ;, we get 2 elements of the list, get the 0th element of list
				set pattern2 [lindex [split $line ";"] 0]
				#puts "creating pattern2 by splitting pattern1 using semicolon as delimiter => \"$pattern2\""
				#S+ : multiple spaces
				if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
					#puts "out of all patterns, \"$pattern2\" has matching string \"input\", so preserving this line and ignoring others"
					#split pattern2 based on spaces
					set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
					puts "printing first 3 elements of pattern2 as \"$s1\" using space as delimiter"
					#replace xle spaces with a single space
					puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
					puts "replace multiple spaces in s1 by single space & reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
			}
		}
		close $fd
	}
	close $tmp_file


	#open /tmp/1 in r mode
	set tmp_file [open /tmp/1 r]
	#puts "reading [read $tmp_file]"
	#puts "readng /tmp/1 file as [split [read $tmp_file] \n]"
	#puts "sorting /tmp/1 contents as [lsort -unique [split [read $tmp_file] \n ]]"
	#puts "joining /tmp/1 as [join [lsort -unique [split [read $tmp_file] \n ]] \n]"
	set tmp2_file [open /tmp/2 w]

	puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
	close $tmp_file
	close $tmp2_file

	set tmp2_file [open /tmp/2 r]
	#puts "count is [llength [read $tmp2_file]]"
	#set count to check for bussed/bit ports
	#length of the string is 2 for - input cpu_en
	set count [split [llength [read $tmp2_file]] " "]
	#puts "splitting content of tmp_2 using space and counting number of elements as $count"
	if {$count > 2} {
		set op_ports [concat [constraints get cell 0 $i]*]
		puts "bussed"
	} else 	{
		set op_ports [constraints get cell 0 $i]
		puts "not bussed"
	}
	puts "output port name is $op_ports since count is $count\n"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i]  \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i]  \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i]  \[get_ports $op_ports\]"
		
	incr i
}
close $tmp2_file
close $sdc_file
puts "\nINFO : SDC Created, please use constraints in path $OutputDirectory/$DesignName.sdc"

#--------------------------------------------------------------------------------------#
#-------------------------------------Hierarchy Check----------------------------------#
#--------------------------------------------------------------------------------------#
puts "\nInfo: Creating hierarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
puts "data is \"$data\""
set filename "$DesignName.hier.ys"
puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
puts "open \"$OutputDirectory/$filename\" in write mode"
#dump $data into $fileId which has called $filename in write mode
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
puts "netlist is \"$netlist\""
foreach f $netlist {
	set data $f
	puts "data is \"$f\""
	#string on the right gets dumped to $fileId
	puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId 

puts "\nclose \"$OutputDirectory/$filename\"\n"
puts "\nInfo: Checking hierarchy ....."
# [catch {...} msg] to find any errors/exceptions; exec to run a UNIX shell command ;>& to dump execution text in <file>
set my_err [catch { exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "error flag is $my_err"

if { $my_err } {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	#puts "log file name is $filename"
	set pattern "referenced in module"
	#puts "pattern is $pattern"
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		# -- used to say end of command options. everything after this is args
		incr count [regexp -all -- $pattern $line]
		if {[regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'"
			puts "\nInfo: Hierarchy check FAIL"
		}
	}
	close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check in details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"
cd $working_dir

#----------------------------------------------------------------------------#
#--------------------------Main synthesis script-----------------------------#
#----------------------------------------------------------------------------#
puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
#puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
#puts "open \"$OutputDirectory/$filename\" in write mode"
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
	set data $f
	puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge \niopadmap -outpad BUFX2 A:Y -bits \nopt \nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from path $OutputDirectory/$DesignName.ys"
puts "\nInfo: Running synthesis............."

#----------------------------------------------------------------------------#
#----------------------Run synthesis script using yosys----------------------#
#----------------------------------------------------------------------------#
if { !$my_err } {
	set my_err1 [catch { exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]
	if { $my_err1 } {
	puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
	puts "\nInfo: Please refer to $OutputDirectory/$DesignName.synthesis.log"
	exit
	} else {
	puts "\nInfo: Synthesis finished successfully"
	puts "\nInfo: Please refer to $OutputDirectory/$DesignName.synthesis.log"
	}
} else {
	puts "Refer to [file normalize $OutputDirectory/$DesignName.hierarchy_check.log]. Need to ensure Hierachy Check Pass "
}

#----------------------------------------------------------------------------#
#----------------Edit synth.v to be usable by Opentimer----------------------#
#----------------------------------------------------------------------------#

#open a new file
set fileId [open /tmp/1 w]
#dump lines not having "*" into $fileId
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
	while {[gets $fid line] != -1} {
	#replace backslash 
	puts -nonewline $output [string map {"\\" " "} $line]
	puts -nonewline $output "\n"
}
close $fid 
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"

#----------------------------------------------------------------------------#
#-------------------------STA using Opentimer--------------------------------#
#----------------------------------------------------------------------------#

puts "\nInfo: Timing Analysis Started ... "
puts "\nInfo: initializing number of threads, libraries, sdc, verilog netlist path..."
source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4

source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib

read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib

source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v

source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

if {$enable_prelayout_timing == 1} {
	puts "\nInfo: enable prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
	puts $spef_file "*SPEF \"IEEE 1481-1998\""
	puts $spef_file "*DESIGN \"$DesignName\""
	puts $spef_file "*DATE \"Sun Jun 11 11:59:00 2023\""
	puts $spef_file "*VENDOR \"VLSI System Design\""
	puts $spef_file "*PROGRAM \"TCL Workshop\""
	puts $spef_file "*DATE \"0.0\""
	puts $spef_file "*DESIGN FLOW \"NETLIST_TYPE_VERILOG\""
	puts $spef_file "*DIVIDER /"
	puts $spef_file "*DELIMITER : "
	puts $spef_file "*BUS_DELIMITER [ ]"
	puts $spef_file "*T_UNIT 1 PS"
	puts $spef_file "*C_UNIT 1 FF"
	puts $spef_file "*R_UNIT 1 KOHM"
	puts $spef_file "*L_UNIT 1 UH"
}
close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_tns"
puts $conf_file "report_worst_paths -numPaths 10000 " 
close $conf_file

#------------------------find STA runtime--------------------------------#
set tcl_precision 3
#time is a TCL command, exec is a command to run shell script from within TCL shell
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} 1]
puts "time_elapsed_in_us is $time_elapsed_in_us"
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "time_elapsed_in_sec is $time_elapsed_in_sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"


#-------------------------find worst output violation--------------------------------#
#WNS - worst negative slack, FEP - failing end point violations
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
	#pattern should match the line that we are reading over here
	if {[regexp $pattern $line]} {
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of output violations--------------------------------#	
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

#-------------------------find worst setup violation--------------------------------#
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Setup}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of setup violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

#-------------------------find worst hold violation--------------------------------#
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Hold}
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

#-------------------------find number of hold violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

#-------------------------find number of instances--------------------------------#

set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r] 
while {[gets $report_file line] != -1} {
	if {[regexp $pattern $line]} {
		set Instance_count "[lindex [join $line " "] 4 ]"
		break
	} else {
		continue
	}
}
close $report_file

#puts "DesignName is \{$DesignName\}"
#puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
#puts "Instance_count is \{$Instance_count\}"
#puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
#puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
#puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
#puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
#puts "worst_RAT_slack is \{$worst_RAT_slack\}"
#puts "Number_output_violations is \{$Number_output_violations\}"

puts "\n"
puts "						****PRELAYOUT TIMING RESULTS**** 					"
set formatStr "%15s %15s %15s %15s %15s %15s %15s %15s %15s"

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "DesignName" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"
