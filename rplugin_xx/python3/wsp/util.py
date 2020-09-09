import os
import yaml
import logging
import subprocess as sp
from pathlib import Path
import re

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

class NvimHelper(object):
    '''
    Helper functions for basic nvim ui interactions.
    '''

    def __init__(self, nvim):
        self.nv = nvim

    def echo(self, msg):
        self.nv.command('echo "' + msg + '"')

    def input_yesno(self, ques):
        ans = self.nv.funcs.input(ques + ' (y/n): ')
        return (re.match(r'^(yes|y)$', ans, flags=re.IGNORECASE) is not None)

def load_config(configdir):
    with open(configdir + '/config.yaml', 'r') as f:
        return yaml.load(f)

'''
Build a find command for excluded paths and included filetypes.

find . \
    -path exclude1 -prune -or \
    -path exclude2 -prune -or \
    ...
    -name filetype1 -print -or \
    -name filetype2 -print -or \
    ...
'''
def listfiles(config):
    log.info(config)
    dirs = config['dirs']
    if not dirs:
        return
    fs = []
    for d in config['dirs']:
        excludes = ' -or '.join([
            '-path "{}" -prune'.format(ex)
            for ex in config['exclude']
        ])
        filetypes = ' -or '.join([
            '-name "*.' + ft + '" -print'
            for ft in config['filetypes']
        ])
        cmd = 'find . -type f ' + excludes + ' -or ' + filetypes
        log.info(cmd)
        fs += sp.check_output(cmd, shell=True).splitlines()
    return fs

def listdirs(config):
    cmd = 'find {} -type d'.format(' '.join(config['dirs']))
    log.info(cmd)
    try:
        return sp.check_output(cmd, shell=True).splitlines()
    except sp.CalledProcessError as e:
        error(e.output)
    return []


def get_project_dir():
    d = (Path(os.getcwd()) / '.wsp')
    log.info(str(d))
    try:
        if d.is_dir():
            return str(d)
    except OSError as e:
        error(e)
    return None


# def create_tags_db(config):
#     tags_path = Path('/tmp/prjdb')
#     if (tags_path.exists()):
#         log.info('tags_path exists')
#         return
#     log.info('Creating tags database...')
#     tags_path.mkdir(parents=True, exist_ok=True)
#     cmd = 'gtags --file - ' + str(tags_path)
#     proc = sp.Popen(cmd, shell=True, stdin=sp.PIPE, stdout=sp.PIPE)
#     for name in listfiles(config):
#         proc.stdin.write(name + b'\n')
#     proc.stdin.close()
#     proc.wait()
#     log.info('done.')


# def find_definition(symbol):
#     cmd = ('GTAGSROOT=$(pwd) GTAGSDBPATH=/tmp/prjdb '
#             'global --result grep {}'.format(symbol))
#     log.info(cmd)
#     try:
#         return [
#             s.decode('utf-8')
#             for s in sp.check_output(cmd, shell=True).splitlines()
#         ]
#     except sp.CalledProcessError as e:
#         error(e.output)
#     return []


# def find_references(symbol):
#     cmd = ('GTAGSROOT=$(pwd) GTAGSDBPATH=/tmp/prjdb '
#             'global -r --result grep {}'.format(symbol))
#     log.info(cmd)
#     return [f.decode('utf-8')
#         for f in sp.check_output(cmd, shell=True).splitlines()]


# def parse_tagline(line):
#     m = re.match(r'(.*?):(.*?):.*', line)
#     fname = m.group(1)
#     lineno = int(m.group(2))
#     return (fname, lineno)
