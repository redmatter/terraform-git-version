import subprocess

try:
    version = subprocess.check_output(['git', 'describe', '--tags', '--long', '--dirty', '--always'])
    print '{"version": "' + version.rstrip() + '"}'
except subprocess.CalledProcessError:
    print '{"version": "UNKNOWN"}'
