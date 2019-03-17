import logging
import os
import re
import pynvim

import prj.util as util

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
error, debug, info, warn = (
    logger.error,
    logger.debug,
    logger.info,
    logger.warning
)


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
class PrjPluginHandler(object):
    def __init__(self, nvim):
        info('[ ---- PRJ PLUGIN LOAD ---- ]')
        self.nvim = nvim
        self.config = None
        self.nvh = NvimHelper(nvim)

    def echo_not_in_prj_mode(self):
        if not self.nvim.vars['prj_mode']:
            self.nvh.echo('Not in project mode.')
            return True
        return False

    @pynvim.function('PrjInit')
    def PrjInit(self, args):
        """
        Initializes the plugin when requested.
        This function is called using autocmd on vim startup.
        """
        nv = self.nvim
        prj_dir = util.get_project_dir()
        info(prj_dir)
        if prj_dir:
            self.config = util.load_config(prj_dir)
            nv.vars['prj_mode'] = True
            nv.vars['prj_configdir'] = prj_dir
            nv.funcs._prj_enable_maps()
            nv.async_call(util.create_tags_db, self.config)
        else:
            nv.vars['prj_mode'] = False

    @pynvim.command('ProjectFiles')
    def ProjectFiles(self):
        if (self.echo_not_in_prj_mode()):
            return
        fs = util.listfiles(self.config)
        if (len(fs) == 0):
            self.nvh.echo('No files in project.')
        else:
            self.nvim.funcs._prj_fzf_files(fs)

    @pynvim.command('ProjectDirs')
    def ProjectDirs(self):
        if (self.echo_not_in_prj_mode()):
            return
        ds = util.listdirs(self.config)
        if (len(ds) == 0):
            self.nvh.echo('No directories in project.')
        else:
            self.nvim.funcs._prj_fzf_files(ds)

    @pynvim.command('PrjEditConfig')
    def PrjEditConfig(self):
        if (self.echo_not_in_prj_mode()):
            return
        nv = self.nvim
        nv.command('split ' + nv.vars['prj_configdir'] + '/prj.yaml')

    @pynvim.function('_prj_jumptag')
    def _prj_jumptag(self, args):
        if (len(args) == 0):
            return
        fname, num = util.parse_tagline(args[0])
        self.nvim.command('edit +{} {}'.format(num, fname))
        self.nvim.command('normal! zz')

    @pynvim.command('PrjGotoDef', nargs='?')
    def PrjGotoDef(self, args):
        if (self.echo_not_in_prj_mode()):
            return
        if (len(args) == 0):
            word = self.nvim.funcs.expand('<cword>')
        else:
            word = args[0]
        defs = util.find_definition(word)
        if (len(defs) == 0):
            self.nvh.echo('Symbol \'{}\' not found.'.format(word))
        elif (len(defs) == 1):
            self._prj_jumptag(defs)
        else:
            self.nvim.funcs._prj_fzf_select(defs, '_prj_jumptag')

    @pynvim.command('PrjFindRefs', nargs='?')
    def PrjFindRefs(self, args):
        if (self.echo_not_in_prj_mode()):
            return
        if (len(args) == 0):
            word = self.nvim.funcs.expand('<cword>')
        else:
            word = args[0]
        refs = util.find_references(word)
        if (len(refs) == 0):
            self.nvh.echo('No references for symbol \'{}\''.format(word))
        else:
            self.nvim.funcs._prj_fzf_select(refs, '_prj_jumptag')

    @pynvim.command('PrjCreateProject')
    def PrjCreateProject(self):
        if self.nvim.vars['prj_mode']:
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
            self.PrjInit([])
            self.nvh.echo('project created.')

