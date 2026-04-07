#!/bin/bash
echo "select the Apps ************"
echo "  1)Trilium"
echo "  2)Homepage"
echo "  3)operation 3"
echo "  4)operation 4" 

read n
case $n in
  1) podman start trilium;;
  2) echo "You chose Option 2";;
  3) echo "You chose Option 3";;
  4) echo "You chose Option 4";;
  *) echo "invalid option";;
esac