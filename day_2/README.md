**DATE - 06/07/2023**

- Begin by creating variables out of rows and columns in CSV file

- Checks for paths provided if they exist or not, else break the script, prompt the user 

- if you cat *.csv in the terminal, it will be listed contents separated by ",". "," will be used to process (as a channel seaprator)

- [file normalize $m_arr(1,$i)]. $m_arr(1,$i) represents a file/path. After file normalize we get absolute path. '~'/ extra variables get removed

* Sample outputs for script ( script is updated continuosuly over a period of 5 days)
    1. Assign paths/file name to created variables

        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/03d1c179-8083-400f-9379-611e548c7747)

    2. Break script when file not found/create output directory if not present
 
         ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/a5cbd7c4-c19f-4a65-9c3c-0ef28bc729e6)

* Convert constraints file (.csv) into SDC(Synopsys Design Constraints) format [Identify bit/bussed signal from the *.v netlists provided]. Step remains same, read the .csv into a matrix type, get rows & columns automatically with the help of package

    3.  Get number of rows and columns of the constraints.csv file. clock_start & clock_start_column = {0,0} represents in matrix format,
        for us to loop from 0-56 for rows and 0-10 for columns

          ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/518bc847-22a8-45d5-a0d1-832b14d0bb9c)

    4. we need to have the latency for CLOCKS in the below format :
       
       set_clock_latency -source -early -rise 150 [get_clocks dco_clk]
       
       set_clock_latency -source -late -fall 153 [get_clocks dco_clk]
       
       This is how it is understood by most of the industry standard tools.

        





