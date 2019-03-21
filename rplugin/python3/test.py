import logging
import os
import re
import pynvim

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

@pynvim.plugin
class TestPlugin(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.config = None
        self.nvh = NvimHelper(nvim)

    @pynvim.command('WspTest')
    def WspTest(self):
        self.nvh.echo('HELLO')

