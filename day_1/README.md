**Date - 04/07/2023**

* The .sdc file need to be converted to .timing format which is understood by openTimer which is responsible to create the performance chart as shown in the briefing.

* tcsh is used to build the UI, it also processes the .csv file.

1. User did not provide CSV file

   ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/b717f60c-81ca-4b4f-a942-9c92a74aa9c1)


2. User provided incorrect/did not exist CSV file.

    ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/15139899-3bad-4e94-a49b-c6613c694e01)


3. User wants to know how to use the UI, passes "-help"

    ![image](https://github.com/venkys8/VSD-TCL_Workshop/assets/138795338/2cc86f92-697c-4afd-bd8a-e55148431cb2)

   
* Sample code would look like -


  if ($#argv == " ") then

	  echo "You have not provided .csv file";
 
	  exit 1	
 
  endif


  if(! -f $argv[1] || $argv[1] == "-help") then

	  if($argv[1] != "-help") then
 
		  echo "ERROR: Cannot find csv file $argv[1], Exiting..."
  
		  exit 1
  
	  else ............

