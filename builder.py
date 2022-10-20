"""
Replaces ##PYTHON_EXE## for sys.executable

Replaces ##INSTALL_DIR## for sys.argv[2]

runs over argv[1] doing the above replacements
"""
import sys
import os

build_filename = sys.argv[1]
install_dir = sys.argv[2]

build_path,build_basename = os.path.split(build_filename)
build_name,build_ext = os.path.splitext(build_basename)

out_filename = os.path.join(install_dir,build_name+'.py')

with open(build_filename,'r') as build_file:
    with open(out_filename,'w') as out_file:
        print("Building to "+out_filename)
        for line in build_file:
            line = line.replace('##INSTALL_DIR##',install_dir).replace('##PYTHON_EXE##',sys.executable)
            out_file.write(line)







