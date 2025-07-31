import os
import sys
from distutils import sysconfig;

print(f"Python version: {sys.version}")

lib_dir = sysconfig.get_config_var("LIBDIR")
print(f"LIBDIR: {lib_dir}")
paths = os.listdir(lib_dir)
for path in sorted(paths):
    print( path )
print("-------------------------------")
print(f"({len(paths)} paths total)")

import Draft

