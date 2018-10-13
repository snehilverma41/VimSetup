#!/bin/bash
for file in $(find .nvim/ -type f -name "_travis.yml") 
do
    mv $file $(echo "$file" | sed 's|_|.|g')
done
for file in $(find .nvim/ -type f -name "_gitignore") 
do
    mv $file $(echo "$file" | sed 's|_|.|g')
done
