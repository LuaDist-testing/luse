==============================================================================
 LUSE 1.0.2
==============================================================================
------------------------------------------------------------------------------
 About
------------------------------------------------------------------------------

This is the first release of LUSE, a Lua binding for FUSE library. You can
find documentation about LUSE at the following web address:

  http://luse.luaforge.net/

------------------------------------------------------------------------------
 Build instructions
------------------------------------------------------------------------------

To build luse edit config.mak and then run make in the top directory:

$ vi config.mak
$ make
$ make install

------------------------------------------------------------------------------
 FUSE
------------------------------------------------------------------------------

To use LUSE you need FUSE. It is available at:

  http://fuse.sourceforge.net/

------------------------------------------------------------------------------
 Examples
------------------------------------------------------------------------------

There are three provided examples in the doc directory: hellofs.lua, luafs.lua
and fwfs.lua. hellofs.lua is a simple Hello World! filesystem. luafs.lua
exposes the content of a Lua table (root) as a filesystem. Tables are
directories, strings are readable and writable, userdata are only writable.
fwfs.lua is a simple forwarding filesystem. It redirects all API calls to
another directory (root).  It can be used as a base to develop your own
filesystems.

------------------------------------------------------------------------------
 Documentation & Support
------------------------------------------------------------------------------

Documentation is available online at:

  http://luse.luaforge.net/

All support is done through the LUSE users mailing list:

  luse-users@lists.luaforge.net

To subscribe visit the following web page:

  http://lists.luaforge.net/mailman/listinfo/luse-users

------------------------------------------------------------------------------
 Credits & license
------------------------------------------------------------------------------
This module is written by Jérôme Vuarand. It is inspired by luafuse by Gary
Ng, but it has been rewritten from scratch.

LUSE is available under a MIT-style license. See LICENSE.txt.

