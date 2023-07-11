# VSD-TCL_Workshop
***Author: Venkatesh Iyer***

***Acknowledgement: TCL Workshop by [Mr. Kunal Ghosh](https://github.com/kunalg123) , [VLSI System Design](https://www.vlsisystemdesign.com/)***

**BRIEFING -**

Input is a .csv file which contains path for design_constraints.csv, outputDirectory path, netlist paths, library paths etc along with the designName. 
Our task is to take these inputs, parse the file and come up with .sdc file, and also give out the the datasheet like a characteristics of the input .csv provided. 
Below is the sample image as per expectation. 

![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/52ecd2aa-0340-4405-9bd6-cfe234da8896)


### **Languages used - tcsh and TCL**

Post .sdc file, we run synthesis and timing using opensource tool like yosys and openTimer. Final is the preLayout timing results which would be our requirement. 
Further details of the steps and lab outputs are recorded in each corresponding day. Feel free to checkout.

**Venkatesh**

## **DAY_1, Date - 04/07/2023**
* The .sdc file need to be converted to .timing format which is understood by openTimer which is responsible to create the performance chart as shown in the briefing.

* tcsh is used to build the UI, it also processes the .csv file.

1. User did not provide CSV file

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b717f60c-81ca-4b4f-a942-9c92a74aa9c1)


2. User provided incorrect/did not exist CSV file.

    ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/15139899-3bad-4e94-a49b-c6613c694e01)


3. User wants to know how to use the UI, passes "-help"

    ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/2cc86f92-697c-4afd-bd8a-e55148431cb2)

   
* Sample code would look like -
  ```
  if ($#argv == " ") then

	  echo "You have not provided .csv file";
    
	  exit 1
   
  endif
  ```
  ```
  if(! -f $argv[1] || $argv[1] == "-help") then

    if($argv[1] != "-help") then
 
	  echo "ERROR: Cannot find csv file $argv[1], Exiting..."
  
	  exit 1
  
	else ............
  ```

  ## **DAY_2, Date - 06/07/2023**

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

  ## **DAY_3, Date - 07/07/2023**

  - We start by finding column number for a paramter of CLOCKS, then loop using variables set in DAY_2 and assign values, rather "puts" the content of cell

  - after getting values of various parameters, we create a new file and append lines/write certain commands into the SDC format using "puts"

  - code to extract frequency and duty cycle for the 2 types of clock, sample format -> create_clock =name dco_clk -period 1500 -waveform {0 750} [get_ports dco_clk]


  1. Process CLOCK paramters
   
       ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/8e5ac623-de3e-4077-8f54-0cf980215f1b)

  2. Check if commands appended to created .sdc file [ OpenMSP430.sdc is the file name ]

       ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/dda9fa5a-c85c-4513-943c-605b0f2af429)

  3. Classify as bussed or bit signal

       ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/c988e403-b126-46aa-aba1-6fe9cc612bf9)

       ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/4e7c9c2c-8f3d-4a8d-8b60-4e52720a85bc)

       ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/aa3edba2-22f4-425f-8f07-760c2f73f8ef)

  ## **DAY_4, Date - 07/07/2023 - 08/07/2023**

    **PART - 2**
  
  - Look into EDA tools(yosys and opentimer), manipulate the output report, pass on the outputs of yosys to opentimer etc

  1.  Processing OUTPUT section of the input constraints.csv file. Post processing CLOCKS, INPUTS, OUTPUTS, directing user to checkout .sdc file alongwith path

 
        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/69bd8bd3-f266-4a24-82e2-8df995d63ebf)


        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/70c97610-e7bd-46d4-8ca7-abaf896af194)



  2. Designer gives RTL, we automate it. Read the library, all netlists, hierarchical check and gives output ( synthesized netlist )

        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b5b3405f-a273-4564-b4ab-f6a345475304)


    - creating hierarchy. creating file with read_verilog appended;

         ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/18cf62da-90e9-40a3-bfab-f9113a3cb18f)

         ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/96fa2b27-fd78-4b88-893c-c34a4246cae7)

  3. Error handling for hierarchy check. Modified name of a module in top module and error is thrown in hierarchy log file

     	![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/45328b51-133b-43f4-a47a-f9e1526196b1)


  4.  No errors in hierarchy

        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b4f4b78e-cd0f-4ecb-9fd1-6729b434b5ce)


  5. introduce error in module name and check for error in hierarchy

        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/e18c1532-2b38-4b88-a9b5-ecee3aa509c5)

        ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/28cc3e50-56ba-444e-9651-c4045d6cbecd)


## **DAY_5, Date - 08/07/2023 - 11/07/2023**

## 1. Synthesis successful

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/49885c25-9ba5-4025-a68a-0fa813ce6747)

## 2. get final .synth.v, after clean-up to be used by opentimer

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b22e4395-f59e-4fae-be80-e6c7c2a58055)
    
   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/98b2c423-d833-4e52-8273-0dbff7c9d907)

 ## 4. Procs:

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/5a48082e-30d8-48d1-bb04-1c458990c368)

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/6273fb0e-6e51-4fc5-82bb-3495a63859f1)

 ## 5. Create .timing file, replace square brackets by 'null'; eval clk period and port name from processed SDC file; eval duty cycle & create clk in openTimer format(till 	converting create_clock constraints in /proc/read_proc.sdc)

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/7c3bb640-1635-448c-a787-48b0d4f4afce)


   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/263bfe3b-aac0-4c91-8739-931987301433)

## 6. clock latency and port name from SDC file

   we have in SDC file : set_clock_latency -source -early -rise 150 get_clocks dco_clk

   In openTimer format,we need to have like this : at dco_clk 150 151 152 153

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b730a44e-2cd1-44a2-9c67-ab351190dadb)

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b878d589-4dbe-48a0-a1f6-e72f2fc693ea)


## 7. clock_transition & input delay to openTimer format

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/c3231f84-9a24-4bb5-8c71-1d5369d48719)


   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/c1bb3428-0c4b-4737-bbc0-569501352fc9)

## 8. Output delay constraints to openTimer format

   at : arrival time ; rat : required arrival time ; equivalent command of set_load in openTimer is load

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/270acf0c-a559-47c1-a6b9-7fc37f879989)

## 9. We have bussed ports in /tmp/3 ; Bussed ports to be expanded based on final synthesized netlist (to find out how many bits the * gets expanded into) ;

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/76e6997e-73ae-4a47-97d7-e2f38825b6be)

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/1a0597a2-fe77-4e8e-96f8-ab268f4f0f21)

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/d2c25dfd-9104-4792-a0f3-1558a450aaaa)

   .conf file is needed for running the openTimer, it is used as input


## 10. master file suppied to openTimer -> .conf file

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/2c680a64-a8e6-4113-8404-b74f9b61cf37)

  ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/8e81f321-4485-43c1-a5c2-f57eee23451d)


## 11. QOR (Quality of results)

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/f2b3514d-9e86-4ee4-8153-4207299cbec5)

   


###  updated with another iterations 

 ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/030b700e-0385-49d4-8737-9d18850f326b)


 ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b92aa1e2-55a9-4bdd-b31f-a6129bb02c0f)


 ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/1059784a-88ca-4378-b3da-20c374cc067b)
 

 ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/4d5549f9-f16d-4404-8bbc-d2a56ad3a414)

 ## FINAL 

![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/5b7eb387-0515-4971-b674-b67e97e1646c)

 




    	




