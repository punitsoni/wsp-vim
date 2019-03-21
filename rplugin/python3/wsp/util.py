# import pynvim
# import sys
import os
import yaml
import logging
import subprocess as sp
from pathlib import Path
import re
# import te)mpfile

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
error, debug, info, warn = (logger.error, logger.debug, logger.info,
        logger.warning)


def load_config(configdir):
    with open(configdir + '/prj.yaml', 'r') as f:
        return yaml.load(f)


def listfiles(config):
    fs = []
    for d in config['dirs']:
        cmd = 'find {} -type f {}'.format(d, ' -or '.join(
                    ['-name "*.' + ext + '"' for ext in config['filetypes']]))
        info(cmd)
        fs += sp.check_output(cmd, shell=True).splitlines()
    return fs


def listdirs(config):
    cmd = 'find {} -type d'.format(' '.join(config['dirs']))
    info(cmd)
    try:
        return sp.check_output(cmd, shell=True).splitlines()
    except sp.CalledProcessError as e:
        error(e.output)
    return []


def get_project_dir():
    d = (Path(os.getcwd()) / '.project')
    info(str(d))
    try:
        if d.is_dir():
            return str(d)
    except OSError as e:
        error(e)
    return None


def create_tags_db(config):
    tags_path = Path('/tmp/prjdb')
    if (tags_path.exists()):
        info('tags_path exists')
        return
    info('Creating tags database...')
    tags_path.mkdir(parents=True, exist_ok=True)
    cmd = 'gtags --file - ' + str(tags_path)
    proc = sp.Popen(cmd, shell=True, stdin=sp.PIPE, stdout=sp.PIPE)
    for name in listfiles(config):
        proc.stdin.write(name + b'\n')
    proc.stdin.close()
    proc.wait()
    info('done.')


def find_definition(symbol):
    cmd = ('GTAGSROOT=$(pwd) GTAGSDBPATH=/tmp/prjdb '
            'global --result grep {}'.format(symbol))
    info(cmd)
    try:
        return [
            s.decode('utf-8')
            for s in sp.check_output(cmd, shell=True).splitlines()
        ]
    except sp.CalledProcessError as e:
        error(e.output)
    return []


def find_references(symbol):
    cmd = ('GTAGSROOT=$(pwd) GTAGSDBPATH=/tmp/prjdb '
            'global -r --result grep {}'.format(symbol))
    info(cmd)
    return [f.decode('utf-8')
        for f in sp.check_output(cmd, shell=True).splitlines()]


def parse_tagline(line):
    m = re.match(r'(.*?):(.*?):.*', line)
    fname = m.group(1)
    lineno = int(m.group(2))
    return (fname, lineno)
