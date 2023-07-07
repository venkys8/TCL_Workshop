**Date - 07/07/2023**

- We start by finding column number for a paramter of CLOCKS, then loop using variables set in DAY_2 and assign values, rather "puts" the content of cell

- after getting values of various parameters, we create a new file and append lines/write certain commands into the SDC format using "puts"

- code to extract frequency and duty cycle for the 2 types of clock, sample format -> create_clock =name dco_clk -period 1500 -waveform {0 750} [get_ports dco_clk]

- 

1. Process CLOCK paramters
   
     ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/8e5ac623-de3e-4077-8f54-0cf980215f1b)

2. Check if commands appended to created .sdc file [ OpenMSP430.sdc is the file name ]

     ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/dda9fa5a-c85c-4513-943c-605b0f2af429)

3. Classify as bussed or bit signal

     ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/c988e403-b126-46aa-aba1-6fe9cc612bf9)

     ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/4e7c9c2c-8f3d-4a8d-8b60-4e52720a85bc)

     ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/aa3edba2-22f4-425f-8f07-760c2f73f8ef)





