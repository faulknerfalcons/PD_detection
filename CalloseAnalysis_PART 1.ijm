// Author: Matthew Johnston, Faulkner Group
// 13/08/19
// Callose Analysis

//modified by Annalisa 12/02/2020 to add the following features:
//possibility to select PD based on shape, in oreder to exclude signals that are long and thin (see shape factor)
//possibility to automatically split the channels of your Z stacks - this is useful if you recorderd z stacks with more than one channel. If you run Matt's script on those multichannels files the script will get confusd on which channel to consider
//possibility to define the extension of the files to process: this is useful if your files are not .czi, for example once you splitted your channels the extension it is not .czi anymore but .tif

//this script is now made of two sections that can be run separtely or as one unique analysis process. If you want to run a section, highlight it and hit 'run selected code'. If you want to run all, just hit 'run'
//both sections of the script will ask you to select an input and output folder

//--------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------SPLIT CHANNELS SECTION ---------------------------------------------------------------------------------------------------------


// Author: Annalisa Bellandi, Faulkner Group
// 12/02/2020
// Split channels and saves channel 1 as a stack with extension .tif in the output folder

input_folder = getDirectory("Choose input folder, multi-channels files to be split")
output_folder = getDirectory("Choose output folder, channel-split files")

setBatchMode(true);

list = getFileList(input_folder);
		for (i=0; i<list.length; i++) {
            print(list[i]);
            path = input_folder+list[i];
            run("Bio-Formats Importer", "open=[" + path + "] autoscale color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			run("Duplicate...", "duplicate");
			dupTitle = getTitle();
			run("Split Channels");
	        selectWindow("C1-"+dupTitle); //be aware this assumes your callose in in channel 1, change it if not
	        saveAs("Tiff",  output_folder + list[i] + "-callose.tif");
	        close();
}



//----------------------------------------- split channel section finished --------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------




//start here if you don't need to split channels, but remeber to cange the file extension accordingly to .czi or whatever your file extension is




//--------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------PD detection SECTION ---------------------------------------------------------------------------------------------------------


dir = getDirectory("Choose input folder, files ready for PD detection")
file_extension = ".tif" //this has to match the extension of the files you want to process
threshold = 5000;
minsize = 8;
maxsize = 250;
shape = 0.00 //this controls the circularity of the items that you want to select: 0 is thin and long, 1 is perfect circle. Change to 0.00 if you don't wish to exclude anything based on the shape, increase up to 1 for selecting only more circular items
printOut = true; //change to false if you wish (quicker run time, not saving mask with selected PD)
if (printOut) {
	output = getDirectory("Choose output folder");
}

run("Clear Results");
roiManager("reset");
run("Set Measurements...", "area mean min integrated display redirect=None decimal=3");
setBatchMode(true);


   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

   function processFiles(dir, slow) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i], slow);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             if (slow){
             	processFileSlow(path);
             }else{
             	processFileQuick(path);
             }
          }
      }
  }



  function processFileQuick(path) {
       if (endsWith(path, file_extension)) {
			run("Bio-Formats Importer", "open=[" + path + "] autoscale color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			run("Duplicate...", "duplicate");
			setThreshold(threshold, 65535);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity="+shape+"-1.00 pixel add stack");
			close();
			roiManager("Measure");
			roiManager("reset");
			close();
      }
  }

  function processFileSlow(path) {
       if (endsWith(path, file_extension)) {
			run("Bio-Formats Importer", "open=[" + path + "] autoscale color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			run("Duplicate...", "duplicate");
			setThreshold(threshold, 65535);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			run("Analyze Particles...", "size="+minsize+"-"+maxsize+" circularity="+shape+"-1.00 pixel add stack");
			close();
			roiManager("Measure");
			run("From ROI Manager");
			run("Overlay Options...", "stroke=none width=0 fill=none");
			saveAs("Tiff",  output + File.getName(path) + "-PD.tif");
			close();
			roiManager("reset");
      }
  }

	
count = 0;
countFiles(dir);
n = 0;
processFiles(dir, printOut);

saveAs("results",  dir + "results.csv"); 
run("Clear Results");
setBatchMode(false);


//----------------------------------------- PD detection section finished --------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------