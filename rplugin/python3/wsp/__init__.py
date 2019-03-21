import logging
import os
import re
import pynvim

import wsp.util as util
from wsp.nvim_helper import NvimHelper

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)


@pynvim.plugin
class WspPlugin(object):
    def __init__(self, nvim):
        log.info('[ ---- WSP PLUGIN LOAD ---- ]')
        self.nvim = nvim
        self.config = None
        self.nvh = NvimHelper(nvim)

    def echo_not_in_wsp_mode(self):
        if not self.nvim.vars['wsp_mode']:
            self.nvh.echo('not in wsp mode.')
            return True
        return False

    @pynvim.function('WspInit')
    def WspInit(self, args):
        nv = self.nvim
        wsp_dir = util.get_project_dir()
        log.info(wsp_dir)
        if wsp_dir:
            self.config = util.load_config(wsp_dir)
            nv.vars['wsp_mode'] = True
            nv.vars['wsp_configdir'] = wsp_dir
        else:
            nv.vars['wsp_mode'] = False
        nv.funcs._wsp_load_keymappings()

    @pynvim.command('WspFiles')
    def WspFiles(self):
        if (self.echo_not_in_wsp_mode()):
            return
        fs = util.listfiles(self.config)
        if (len(fs) == 0):
            self.nvh.echo('No files in project.')
        else:
            self.nvim.funcs._wsp_fzf_files(fs)

    @pynvim.command('WspDirs')
    def WspDirs(self):
        if (self.echo_not_in_wsp_mode()):
            return
        ds = util.listdirs(self.config)
        if (len(ds) == 0):
            self.nvh.echo('No directories in project.')
        else:
            self.nvim.funcs._wsp_fzf_files(ds)

    @pynvim.command('WspEditConfig')
    def WspEditConfig(self):
        if (self.echo_not_in_wsp_mode()):
            return
        nv = self.nvim
        nv.command('split ' + nv.vars['wsp_configdir'] + '/wsp.yaml')

    @pynvim.command('WspCreateProject')
    def WspCreateProject(self):
        if self.nvim.vars['wsp_mode']:
            self.nvh.echo('Already in project.')
            return
        d = os.getcwd()
        yes = self.nvh.input_yesno('Create project in {}?'.format(d))
        if not yes:
            self.nvh.echo('')
            return
        try:
            os.mkdir(d + '/.project')
        except OSError:
            self.nvh.echo('failed to create dir')
        else:
            self.WspInit([])
            self.nvh.echo('project created.')

