brainViewer

A MATLAB package for generating 3D figures of the mouse brain using the Allen reference atlas.

brainViewer uses built-in MATLAB functionality to convert boundaries between brain regions (as defined in the Allen atlas) to 3D patch objects for easy plotting. Several functions are adapted from the SHARP-Track histological alignment pipeline developed by The Cortical Processing Laboratory at UCL (Cortex Lab).

Requirements:
- MATLAB Image Processing Toolbox
-3D brain volume and annotation table, provided by Cortex Lab. Download all files from the following URL:
http://data.cortexlab.net/allenCCF/
Alternatively, see https://github.com/cortex-lab/allenCCF for other methods of accessing the reference atlas.
- npy-matlab for loading .npy files:
https://github.com/kwikteam/npy-matlab
- the Tree Data Structure package, developed by Jean-Yves Tinevez. Available at MathWorks file exchange and on GitHub. This is used to parse through the annotation table.
https://www.mathworks.com/matlabcentral/fileexchange/35623-tree-data-structure-as-a-matlab-class
https://github.com/tinevez/matlab-tree

Getting Started:
After downloading the required files, add all brainViewer files to your MATLAB path.
Run the brainViewer_setup script to tell brainViewer where the reference atlas files are saved and to set up a default output folder.
Next, run the brainViewer_saveWholeBrainVolume script to create a file depicting the surface of the entire brain. 
This is the slowest and most computationally intensive step, and will take several minutes. After running, brainViewer will save the output so that it need not be run again and the volume information can be loaded into all other plots. 
Once you have generated the full 3D volume, run the ExampleHippocampusPlot3D script. This will walk you through
the basic steps in generating 3D brain volumes and plotting them.

--- Coming Soon ---
- 2D plots projecting over coronal, sagittal, or dorsal slices of the brian
- Animations of rotating 3D plots
- Guide for plotting probe locations and scattering cell locations in both 2D and 3D 
