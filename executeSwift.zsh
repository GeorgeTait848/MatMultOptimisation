pathToDirectoryFromHome="${1? Error: No path from home directory given}"
fileName="${2? Error: No file name for data given}"
title="${3? Error: No plot title given}"
xlabel="${4? Error: xlabel given}"
ylabel="${5? Error: ylabel given}"

pathForFile="$pathToDirectoryFromHome$fileName"
swiftc -assert-config Release -O -o tc MMOptimisation/MMOptimisation/*
./tc $pathForFile

cd ~

plotScriptPath="${pathToDirectoryFromHome}.myplot"

# Check if the file already exists and remove it
if [ -e "$plotScriptPath" ]; then
  rm "$plotScriptPath"
fi

touch $plotScriptPath

# Echo commands to the file
echo "set xlabel '${xlabel}' font 'Times-Roman,20,bold'" >> "$plotScriptPath"
echo "set ylabel '${ylabel}' font 'Times-Roman,20,bold'" >> "$plotScriptPath"
echo "set title '${title}' font 'Times-Roman,25,bold'" >> "$plotScriptPath"
echo "set key autotitle columnheader" >> "$plotScriptPath"
echo "set key font 'Times-Roman 12'" >> $plotScriptPath
echo "set key left top" >> $plotScriptPath
echo "set grid linecolor rgb 'black'" >> $plotScriptPath
echo "num_columns=$(awk '{print NF; exit}' "$pathForFile")" >> "$plotScriptPath"

# Loop over each curve and plot, and append to the file
echo "plot for [i=2:num_columns] '${pathForFile}' using 1:i with linespoints" >> "$plotScriptPath"

gnuplot --persist $plotScriptPath