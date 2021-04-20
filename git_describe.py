import os
import subprocess
import sys

version = None

# We only accept a single argument, so parse it manually rather than introducing a dependency on argparse, for now.
if len(sys.argv) >= 2:
    version = os.environ.get(sys.argv[1])

if not version:
    try:
        out = subprocess.check_output(['git', 'describe', '--tags', '--long', '--dirty', '--always'])
        version = out.rstrip().decode()
    except subprocess.CalledProcessError:
        version = 'UNKNOWN'

print('{"version": "' + version + '"}')
