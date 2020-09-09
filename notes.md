---

Use built-in LUA interface for implementing the wsp plugin.

Each workspace contains a list of directories which is 


---

Redefining the context

Name of this project is now wsp-vim. Making (neo)vim a great workspace tool.
Things will revolve around a concept of "Workspace" which is a root directory
which provides a context in which the editor is used. This terminology is inline
with what other editors / IDEs call workspace.

Reducing the scope

We are focusing on a clean user experience instead of adding a lot of
half-functioning "advanced" features. Main goal is to make vim a place where you
can live and navigate the files in your workspace efficiently. Focus is more on
editing and navigations rather than integration with all development tools. Such
integration might be a good idea to add in future, once we have a solid
foundation for the editing experience.

This project will provide a complete setup of neovim. General init.vim
configuration along with advanced features implemented in plugin. Some of the
plugin features are implemened in python.

---


# prj

Vim plugin to manage projects with (very) large codebase.


We assume in real large codebases, one does not work on more than a handful
number of files and directories at a time. Hence, we need to provide a way to
work with a carefully configured subset of files when managing a project.

## configuration file prj.yaml

List of directories

List of file extensions

Config for running tasks

At vim startup in prj mode, config file is parserd and saved in a data
structure.

Provide a command to refresh project config if it gets changed,

Provide a command to edit prj config inside vim. Refresh config on save.

Use yaml format for storing project config. That is easier to read and write
manually compared to format like JSON.


plugin flow

At vim startup, `prj_mode` is enabled if .project config directory is found.
prj.yaml file is loaded by the plugin and parsed.


## P1 goals

* File navigation Searching and moving to interesting files in the project
  quickly.

* Code navigation Go to definition Find references Navigating back and forth
  from definitions and call-sites.

* Project configuration Provide a way to select which files and directories to
  track as part of the project.

* Autoformat Automatically reformat code with keyboard shortcut for python, c,
  c++

* Refactoring Provide a semantically aware way to rename variable / function
  names.

---

creating tags using global gtags --file .project/files /tmp/prjdb

searching using gnu global GTAGSROOT=/tmp/prjdb global main --path-style
through GTAGSDBPATH=/tmp/prjdb GTAGSROOT=`pwd`  global main -x

---

Code jumping and navigation

ppj-d goto definition s-j-r find references s-j-h navigation history s-j-b go
back s-j-f go forward

every jump command should store the current location in a stack and then jump.
On an explicit jump, forward-history should be reset and latest location should
become the top of stack.

when there are multiple definitions, all of them should be shown in fzf and
user can select where he wants to go. Similarly for references. If only one
item is found, automatically jump to that place.

---

Add support for creating project. PrjCreate command, if current directory is
not part of a project, create a .project directory and add a default prj.yaml
file.  Open this file in editor and ask to add interesting directories.

---

Supporting autoformat and code styling

vim-autoformat is a good external plugin that can perform the code formatting
for various different languages. So, I think just using that plugin with an
appropriate keybinding should be good enough. I don't think we need to do
anything special to support this in prj mode.

However, a project should have its own setup for coding style. We need to
figure out how to make sure autoformat picks up correct styling options for a
language when editing in prj mode.

---

Autocompletion of code while typing is also a very important feature for serious
software development. We will be using deoplete.nvim plugin for providing Autocompletion
features. At this time, nothing much to be done in the prj plugin for this.

---

Jump history

When doing code-navigation across files using GotoDef and FindRefs, its very easy to
lose track of where you came from. A shortcut to go back in your jump history can be
very useful. We can maintain a 1D stack like structure to maintain this history
information.

When jumping to new tag, push current position in history stack.

GoBack command will take you to the latest position in history, and move the back
pointer 1 step down. So, this will enable GoForward command to jump 1 step ahead
in history.

To make sure that we dont fork the history paths. When any jump command other than
back or forward is used, the history above current back pointer is deleted and
current position is added to the top.

---

Saving the source tag database and other persistant data

We need to store project specific data that is persistant across sessions to
make things like source navigation to work. One option is to store this in
project directory itself somewhere under .project. However, one downside of this
is if source filesystem is not fast or local or otherwise not suitable for
reading and writing data programmatically, it will incur some cost. So, a
generic solution is to have a local cache directory where we can store data that
is hidden from the user, such as tag database.


/tmp : Fast because its ramfs, but going to be wiped out on reboot
/var : seems to be the right place for applications to store their data. need
to check how permissions will work in this case.
$HOME/.local: This can be a good solution. User specific. No special permissions
required. Neovim itself stores its persistant data here.

---

Language Server Protocol (LSP) seems to be the future of the source code
navigation. It is lot more advanced than ctags, etags, etc. and supports much
more than just tagging. This needs to be investigated in favor of a simple tag
based source navigation system. 

Hence, I am thinking of reducing the scope of
prj plugin to be just about file navigation at this time. We could use the term
workspace instead of project in this context. As, a single individual checkout
of a source repo where we do all the work (development, build, test etc) is a
workspace. Term project is not very clear.


