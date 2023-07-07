**Date - 07/07/2023**


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

 


 
                


  

      









