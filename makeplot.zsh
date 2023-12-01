pathForDataFile="${1? Error: No path to data file given}"
title="${2? Error: No plot title given}"
xlabel="${3? Error: xlabel given}"
ylabel="${4? Error: ylabel given}"


cd ~
touch gpcommands

# Echo commands to the file
echo "set xlabel '${xlabel}' font 'Times-Roman,20,bold'" >> gpcommands
echo "set ylabel '${ylabel}' font 'Times-Roman,20,bold'" >> gpcommands
echo "set title '${title}' font 'Times-Roman,25,bold'" >> gpcommands
echo "set key autotitle columnheader" >> gpcommands
echo "set key font 'Times-Roman 12'" >> gpcommands
echo "set key left top" >> gpcommands
echo "set grid linecolor rgb 'black'" >> gpcommands
echo "num_columns=$(awk '{print NF; exit}' "$pathForDataFile")" >> gpcommands

# Loop over each curve and plot, and append to the file
echo "plot for [i=2:num_columns] '${pathForDataFile}' using 1:i with linespoints" >> gpcommands

gnuplot --persist gpcommands
rm gpcommands
