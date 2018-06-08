require 'template'

-- :TODO: change it to utf-8 once luaforge support it
local charset = ([[
vi: encoding=iso-8859-1
]]):sub(14, -2):upper()

local lastversion = "1.0.2"
local file_index = "index.html"
local file_manual = "manual.html"
local file_examples = "examples.html"

local function manlink(name)
	return '<a href="http://www.lua.org/manual/5.1/manual.html#pdf-'..name..'"><code>'..name..'</code></a>'
end

local function manclink(name)
	return '<a href="http://www.lua.org/manual/5.1/manual.html#'..name..'"><code>'..name..'</code></a>'
end

------------------------------------------------------------------------------

print = template.print

function header()
	print([[
<?xml version="1.0" encoding="]]..charset..[["?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"
lang="en">
<head>
<title>LUSE</title>
<meta http-equiv="Content-Type" content="text/html; charset=]]..charset..[["/>
<link rel="stylesheet" href="luse.css" type="text/css"/>
</head>
<body>
]])
	print([[
<div class="chapter" id="header">
<img width="128" height="128" alt="LUSE" src="luse.png"/>
<p>A FUSE binding for Lua</p>
<p class="bar">
<a href="]]..file_index..[[">home</a> &middot;
<a href="]]..file_index..[[#download">download</a> &middot;
<a href="]]..file_index..[[#installation">installation</a> &middot;
<a href="]]..file_manual..[[">manual</a> &middot;
<a href="]]..file_examples..[[">examples</a>
</p>
</div>
]])
end

function footer()
	print([[
<div class="chapter" id="footer">
<small>Last update: ]]..os.date"%Y-%m-%d %T%z"..[[</small>
</div>
]])
	print[[
</body>
</html>
]]
end

local chapterid = 0

function chapter(title, text)
	chapterid = chapterid+1
	print([[
<div class="chapter">
<h1>]]..tostring(chapterid).." - "..title..[[</h1>
]]..text:gsub("%%chapterid%%", tostring(chapterid))..[[
</div>
]])
end

function chapterp(title, text) chapter(title, "<p>"..text.."</p>") end

------------------------------------------------------------------------------

io.output(file_index)

header()

chapter("About LUSE", [[
<p>LUSE is a Lua binding for <a href="http://fuse.sourceforge.net/">FUSE</a>, which is a library allowing creation filesystem drivers run in userspace. LUSE is a low level binding. FUSE itself it rather slow, so LUSE tries not to impede performance more than necessary. For that reason it is manipulating userdata and pointers directly rather than Lua strings, with the reduced safety implied.</p>

<p>LUSE tries to be complete, but is not supporting obsolete APIs. The binding is closely following the FUSE API, so in most case you can use FUSE documentation if the present page is not clear enough. The missing functions are missing because I've not used them yet. I can add them on request (a use case could be helpful for non-trivial ones).</p>

<p>LUSE module itself is very basic, so I developed several other modules to help the development of a complete filesystem.</p>

<p><em>errno</em> contains many constants representing POSIX error numbers. It also have an accessor to query the errno variable (which contains the last error number).</p>

<p><em>userdata</em> can create and manipulate untyped userdata, to be used as buffers for read and write commands of the filesystem.</p>

<p><em>posixio</em> is not strictly necessary, but it is very useful to implement many types of filesystem, which redirect I/O request to another filesystem. It contains bindings to many file and directory manipulation functions. Here again the read and write functions manipulate untyped userdata to keep overhead minimal.</p>

<h2>Support</h2>

<p>All support is done through the LUSE users mailing list:
<ul><li><a href="mailto:luse-users@lists.luaforge.net">luse-users@lists.luaforge.net</a></li></ul>
Feel free to ask for further developments. I can't guarantee that I'll develop everything you ask, but I want my code to be as useful as possible, so I'll do my best to help you. You can also send me request or bug reports (for code and documentation) directly at <a href="mailto:jerome.vuarand@gmail.com">jerome.vuarand@gmail.com</a>.</p>

<p>To subscribe visit the following web page:
<ul><li><a href="http://lists.luaforge.net/mailman/listinfo/luse-users">http://lists.luaforge.net/mailman/listinfo/luse-users</a></li></ul>
</p>

<h2>Credits</h2>

<p>This module is written and maintained by Jérôme Vuarand. It is inspired by <a href="http://code.google.com/p/luafuse/">luafuse</a> module by Gary Ng, but it has been rewritten completely from scratch.</p>

<p>This website, LUSE downloadable packages and LUSE mailing list are generously hosted by <a href="http://luaforge.net/">Luaforge.net</a>. Consider making a donation.</p>

<p>LUSE is available under a <a href="LICENSE.txt">MIT-style license</a>.</p>
]])

chapter('<a name="download">Download</a>', [[
<p>LUSE is available on its <a href="http://luaforge.net/frs/?group_id=303">Luaforge project page</a>.</p>

<p>Latest version is ]]..lastversion..[[.</p>
]])

chapterp('<a name="installation">Installation</a>', [[
See README.txt inside the LUSE source package. Further installation instruction can be put here on request.]])

footer()

------------------------------------------------------------------------------

io.output(file_manual)

header()

local functions = { {
	name = "luse_functions";
	title = "luse module";
	doc = "These functions are global to the LUSE module.";
	functions = { {
		name = "luse.main";
		parameters = {"argv", "fs"};
		doc = [[
Starts a new filesystem daemon. <code>argv</code> is an array containing additionnal parameters to pass to the FUSE library. <code>fs</code> is a table (or any indexable object) containing methods of the FUSE filesystem you are trying to create.
<pre>
     local luafs = {}
     function luafs:getattr(path, stat) return -errno.ENOSYS end
     local argv = {"luafs", select(2, ...)}
     luse.main(argv, fs)
</pre>
]];
	}
} }, {
	name = "fuse_functions";
	title = "Filesystem methods";
	doc = [[<p>These methods may be present in the <code>fs</code> object passed to <code>luse.main</code>. They are all optionnal, though without them your filesystem may not work properly. See example filesystems available in LUSE packages for minimal requirements.</p>

<p>Unless otherwise noted, all these functions should return 0 on success. On error, they should returned a negated error number (for example <code>-errno.EINVAL</code>, see errno module below). Each function will receive the object passed to <code>luse.main</code> as first parameter, that's why they are documented with the colon notation below.</p>

<p>As of FUSE 2.6, there are six FUSE methods that are not bound by LUSE: and <code>init</code>, <code>destroy</code>, <code>lock</code> and <code>bmap</code> which I haven't used yet and are a bit complicated to bind, and <code>getdir</code> and <code>utime</code> which are obsolete.</p>]];
	functions = { {
		name = "fs:getattr";
		parameters = {"path", "st"};
		doc = [[Get file attributes. <code>st</code> is a <code>stat</code> structure as described in the <code>posixio.new</code> function below. The <code>'dev'</code> a <code>'blksize'</code> fields are ignored. The <code>'ino'</code> field is ignored except if the <code>'use_ino'</code> mount option is given.]];
	},{
		name = "fs:readlink";
		parameters = {"path", "buf", "size"};
		doc = [[Read the target of a symbolic link. The userdata buffer <code>buf</code> should be filled with a null terminated string. You can use <code>userdata.memcpy</code> to write the content of a string to it.
<pre>
     function luafs:readlink(path, buf, size)
          local link = "/foo"
          userdata.memcpy(buf, link, math.min(size-1, #link)+1)
     end
</pre>]];
	},{
		name = "fs:mknod";
		parameters = {"path", "mode", "redev"};
		doc = [[Create a file node. This is called for creation of all non-directory, non-symlink nodes. If the filesystem defines a <code>create</code> method, then for regular files that will be called instead. <code>mode</code> is a Lua set (see description of <code>stat</code> structure in <code>posixio.new</code> documentation).]];
	},{
		name = "fs:mkdir";
		parameters = {"path", "mode"};
		doc = [[Create a directory.]];
	},{
		name = "fs:unlink";
		parameters = {"path"};
		doc = [[Remove a file.]];
	},{
		name = "fs:rmdir";
		parameters = {"path"};
		doc = [[Remove a directory.]];
	},{
		name = "fs:symlink";
		parameters = {"from", "to"};
		doc = [[Create a symbolic link.]];
	},{
		name = "fs:rename";
		parameters = {"from", "to"};
		doc = [[Rename a file.]];
	},{
		name = "fs:link";
		parameters = {"from", "to"};
		doc = [[Create a hard link to a file.]];
	},{
		name = "fs:chmod";
		parameters = {"path", "mode"};
		doc = [[Change the permission bits of a file. <code>mode</code> is a Lua set (see description of <code>stat</code> structure in <code>posixio.new</code> documentation).]];
	},{
		name = "fs:chown";
		parameters = {"path", "uid", "gid"};
		doc = [[Change the owner and group of a file.]];
	},{
		name = "fs:truncate";
		parameters = {"path", "size"};
		doc = [[Change the size of a file.]];
	},{
		name = "fs:open";
		parameters = {"path", "fi"};
		doc = [[<p>File open operation. <code>fi</code> is a <code>fuse_file_info</code> structure (see below). No creation, or truncation flags (<code>'CREAT'</code>, <code>'EXCL'</code>, <code>'TRUNC'</code>) will be passed to <code>fs:open</code>. Open should check if the operation is permitted for the given flags. Optionally open may also return an arbitrary file handle in the fuse_file_info structure, which will be passed to all subsequent operations on that file.</p>
<p>The <code>fuse_file_info</code> structure has the following members:<ul>
	<li><code>flags</code>, table, this table is a lua set, see the documentation of <code>posixio.open</code></li>
	<li><code>writepage</code>, number</li>
	<li><code>direct_io</code>, boolean</li>
	<li><code>keep_cache</code>, boolean</li>
	<li><code>flush</code>, boolean</li>
	<li><code>fh</code>, number, the file handle that the filesystem can write to</li>
	<li><code>lock_owner</code>, number</li>
</ul></p>]];
	},{
		name = "fs:read";
		parameters = {"path", "buf", "size", "offset", "fi"};
		doc = [[<p>Read data from an open file. <code>buf</code> is a lightuserdata pointing to a buffer of size <code>size</code>. <code>offset</code> is a position inside the file.</p>
<p>Read should return exactly the number of bytes requested except on end of file or on error, otherwise the rest of the data will be substituted with zeroes. An exception to this is when the <code>direct_io</code> mount option is specified, in which case the return value of the read system call will reflect the return value of this operation.</p>]];
	},{
		name = "fs:write";
		parameters = {"path", "buf", "size", "offset", "fi"};
		doc = [[<p>Write data to an open file. <code>buf</code> is a lightuserdata pointing to a buffer of size <code>size</code>. <code>offset</code> is a position inside the file.</p>
<p>Write should return exactly the number of bytes requested except on error. An exception to this is when the <code>direct_io</code> mount option is specified (see read operation).</p>]];
	},{
		name = "fs:statfs";
		parameters = {"path", "st"};
		doc = [[Get file system statistics. <code>st</code> is a <code>statvfs</code> structure (see <code>posixio.new</code> documentation).The <code>'frsize'</code>, <code>'favail'</code>, <code>'fsid'</code> and <code>'flag'</code> fields are ignored.]];
	},{
		name = "fs:flush";
		parameters = {"path", "fi"};
		doc = [[<p>Possibly flush cached data</p>
<p>BIG NOTE: This is not equivalent to fsync(). It's not a request to sync dirty data.</p>
<p>Flush is called on each <code>fs:close</code> of a file descriptor. So if a filesystem wants to return write errors in <code>fs:close</code> and the file has cached dirty data, this is a good place to write back data and return any errors. Since many applications ignore <code>fs:close</code> errors this is not always useful.</p>
<p>NOTE: The <code>fs:flush</code> method may be called more than once for each <code>fs:open</code>. This happens if more than one file descriptor refers to an opened file due to dup(), dup2() or fork() calls. It is not possible to determine if a flush is final, so each flush should be treated equally. Multiple write-flush sequences are relatively rare, so this shouldn't be a problem.</p>
<p>Filesystems shouldn't assume that <code>fs:flush</code> will always be called after some writes, or that if will be called at all.</p>]];
	},{
		name = "fs:release";
		parameters = {"path", "fi"};
		doc = [[<p>Release an open file.</p>
<p>Release is called when there are no more references to an open file: all file descriptors are closed and all memory mappings are unmapped.</p>
<p>For every open() call there will be exactly one release() call with the same flags and file descriptor. It is possible to have a file opened more than once, in which case only the last release will mean, that no more reads/writes will happen on the file. The return value of release is ignored.</p>]];
	},{
		name = "fs:fsync";
		parameters = {"path", "datasync", "fi"};
		doc = [[Synchronize file contents. If the <code>datasync</code> parameter is <code>true</code>, then only the user data should be flushed, not the meta data.]];
	},{
		name = "fs:setxattr";
		parameters = {"path", "name", "value", "size", "flags"};
		doc = [[Set extended attributes.]];
	},{
		name = "fs:getxattr";
		parameters = {"path", "name", "value", "size", "flags"};
		doc = [[Get extended attributes.]];
	},{
		name = "fs:listxattr";
		parameters = {"path", "list", "size"};
		doc = [[List extended attributes.]];
	},{
		name = "fs:removexattr";
		parameters = {"path", "name"};
		doc = [[Remove extended attributes.]];
	},{
		name = "fs:opendir";
		parameters = {"path", "fi"};
		doc = [[Open directory. This method should check if the open operation is permitted for this directory.]];
	},{
		name = "fs:readdir";
		parameters = {"path", "filler", "off", "fi"};
		doc = [[<p>Read directory. <code>filler</code> is a function with the prototype <code>filler(name, off, fi)</code> that must be called for each directory entry.</p>
<p>The filesystem may choose between two modes of operation:<ol>
	<li>The readdir implementation ignores the offset parameter, and passes zero to the filler function's offset. The filler function will not return 1 (unless an error happens), so the whole directory is read in a single readdir operation.</li>
	<li>The readdir implementation keeps track of the offsets of the directory entries. It uses the offset parameter and always passes non-zero offset to the filler function. When the buffer is full (or an error happens) the filler function will return 1.</li>
</ol></p>
<p>NOTE: This LUSE binding currently only support the first mode of operation. You must pass <code>nil</code> as <code>off</code> parameter to the <code>filler</code> function.</p>]];
	},{
		name = "fs:releasedir";
		parameters = {"path", "fi"};
		doc = [[Release directory.]];
	},{
		name = "fs:fsyncdir";
		parameters = {"path", "datasync", "fi"};
		doc = [[Synchronize directory contents. If the <code>datasync</code> parameter is <code>true</code>, then only the user data should be flushed, naot the meta data.]];
	},{
	--[=[
		name = "fs:init";
		parameters = {};
		doc = [[Initialize filesystem. The return value will passed in the private_data field of fuse_context to all file operations and as a parameter to the fs:destroy method.]];
	},{
		name = "fs:destroy";
		parameters = {"conn"};
		doc = [[Clean up filesystem. Called on filesystem exit.]];
	},{
	--]=]
		name = "fs:access";
		parameters = {"path", "mask"};
		doc = [[<p>Check file access permissions. This will be called for the <code>access()</code> system call. If the <code>'default_permissions'</code> mount option is given, this method is not called.</p>
<p>This method is not called under Linux kernel versions 2.4.x.</p>]];
	},{
		name = "fs:create";
		parameters = {"path", "mode", "fi"};
		doc = [[<p>Create and open a file.</p>
<p>If the file does not exist, first create it with the specified mode, and then open it.</p>
<p>If this method is not implemented or under Linux kernel versions earlier than 2.6.15, the mknod() and open() methods will be called instead.</p>]];
	},{
		name = "fs:ftruncate";
		parameters = {"path", "size", "fi"};
		doc = [[<p>Change the size of an open file.</p>
<p>This method is called instead of the <code>fs:truncate</code> method if the truncation was invoked from an <code>ftruncate()</code> system call.</p>
<p>If this method is not implemented or under Linux kernel versions earlier than 2.6.15, the <code>fs:truncate</code> method will be called instead.</p>]];
	},{
		name = "fs:fgetattr";
		parameters = {"path", "st", "fi"};
		doc = [[<p>Get attributes from an open file.</p>
<p>This method is called instead of the <code>fs:getattr</code> method if the file information is available.</p>
<p>Currently this is only called after the <code>fs:create</code> method if that is implemented (see above). Later it may be called for invocations of <code>fstat()</code> too.</p>]];
	--[=[
	},{
		name = "fs:lock";
		parameters = {"path", "fi", "cmd", "lock"};
		doc = [[]];
	--]=]
	},{
		name = "fs:utimens";
		parameters = {"path", "tv"};
		doc = [[Change the access and modification times of a file with nanosecond resolution. <code>tv</code> is a Lua array containing two other tables, the new access time and modification time respectively. These subtables have two fields each:<ul>
<li><code>sec</code>, number, time in seconds</li>
<li><code>nsec</code>, number, the sub-second portion of the time, in nanoseconds</li>
</ul>]];
	--[=[
	},{
		name = "fs:bmap";
		parameters = {};
		doc = [[]];
	--]=]
	}
} }, {
	name = "errno_functions";
	title = "errno module";
	doc = [[The module contains a number of constants taken from various C, POSIX and Linux headers. Not all error codes are there, but the most common for filesystem operation are defined. Ask if you need more. The bound error codes are: EPERM, ENOENT, ESRCH, EINTR, EIO, ENXIO, E2BIG, ENOEXEC, EBADF, ECHILD, EAGAIN, ENOMEM, EACCES, EFAULT, ENOTBLK, EBUSY, EEXIST, EXDEV, ENODEV, ENOTDIR, EISDIR, EINVAL, ENFILE, EMFILE, ENOTTY, ETXTBSY, EFBIG, ENOSPC, ESPIPE, EROFS, EMLINK, EPIPE, EDOM, ERANGE, ENOSYS.]];
	functions = { {
		name = "errno.errno";
		doc = [[This pseudo-variable is a getter that can retrieve the last C errno number. It can be compared to other errno constants, or returned to LUSE.]];
	},{
		name = "errno.strerror";
		parameters = {"err"};
		doc = [[Returns a string corresponding to the error number <code>err</code>.]];
	}
} }, {
	name = "userdata_functions";
	title = "userdata module";
	doc = "This module exposes some functions to manipulate userdata. It also provides a generic way to create a buffer userdata (without metatable or environment).";
	functions = { {
		name = "userdata.memcpy";
		parameters = {"to", "from", "size"};
		doc = [[Writes data to a userdata. <code>to</code> must be a userdata (full or light). <code>from</code> can be a userdata or a string. <code>size</code> is the number of bytes copied. No check of the destination or source size is made (it's impossible for light userdata), so this function may read past data end or overwrite memory. Use it with care.]];
	},{
		name = "userdata.new";
		parameters = {"size"};
		doc = [[Creates a new userdata buffer of the specified <code>size</code>. This is a full userdata allocated by Lua. It has two fields: <code>data</code>, which is a lightuserdata containing the address of the buffer, and size, which is a number containing the size of the buffer. You can also index the buffer with a number key to offset the buffer address (0-based offset). The userdata also have a <code>__tostring</code> metamethod which converts the content of the userdata to a Lua string.
<pre>
     local ud = userdata.new(2) -- create a 2 byte userdata
     print(ud.size) -- size of userdata (2)
     print(ud.data) -- address of first byte
     print(ud[1]) -- address of second byte
     print(tostring(ud)) -- print content of the userdata
</pre>
]];
	},{
		name = "userdata.tostring";
		parameters = {"ud"};
		doc = [[This functions converts the content of the full userdata <code>ud</code> to a string.]];
	}
} }, {
	name = "posixio_functions";
	title = "posixio module";
	doc = [[<p>This module provides some function to manipulate files and directories. It's a light binding over the POSIX API for files and directories. Unless otherwise stated, these functions return an errno error number. You can compare them with constants in the <code>errno</code> module or return them to LUSE.</p>
<p>Except for posixio.new, all files are direct binding to POSIX functions. You can get their documentation through your system manual. Some portions of a Linux manual have been copied here.</p>]];
	functions = { {
		name = "posixio.new";
		parameters = {"type [", "count]"};
		doc = [[<p>Allocates a POSIX structure. Type must be the name of a supported POSIX struct among: <code>'stat'</code>, <code>'statvfs'</code> and <code>'timeval'</code>. <code>count</code> can be used to allocate more than one structure. This is currently only supported with <code>timeval</code> structures.</p>
<p>The <code>stat</code> structure has the following members:<ul>
	<li><code>dev</code>, number, ID of device containing file</li>
	<li><code>ino</code>, number, inode number</li>
	<li><code>mode</code>, table, protection; this table is a lua set, with the following keys possibly present and true: <code>IFBLK</code>, <code>IFCHR</code>, <code>IFIFO</code>, <code>IFREG</code>, <code>IFDIR</code>, <code>IFLNK</code>, <code>IFSOCK</code>, <code>IRUSR</code>, <code>IWUSR</code>, <code>IXUSR</code>, <code>IRGRP</code>, <code>IWGRP</code>, <code>IXGRP</code>, <code>IROTH</code>, <code>IWOTH</code>, <code>IXOTH</code>, <code>ISUID</code>, <code>ISGID</code>, <code>ISVTX</code>.</li>
	<li><code>nlink</code>, number, number of hard links</li>
	<li><code>uid</code>, number, user ID of owner</li>
	<li><code>gid</code>, number, group ID of owner</li>
	<li><code>rdev</code>, number, device ID (if special file)</li>
	<li><code>size</code>, number, total size, in bytes</li>
	<li><code>blksize</code>, number, blocksize for filesystem I/O</li>
	<li><code>blocks</code>, number, number of blocks allocated</li>
	<li><code>atime</code>, number, time of last access</li>
	<li><code>mtime</code>, number, time of last modification</li>
	<li><code>ctime</code>, number, time of last status change</li>
</ul></p>
<p>The <code>statvfs</code> structure has the following members:<ul>
	<li><code>bsize</code>, number, file system block size</li>
	<li><code>frsize</code>, number, fragment size</li>
	<li><code>blocks</code>, number, size of fs in f_frsize units</li>
	<li><code>bfree</code>, number, # free blocks</li>
	<li><code>bavail</code>, number, # free blocks for non-root</li>
	<li><code>files</code>, number, # inodes</li>
	<li><code>ffree</code>, number, # free inodes</li>
	<li><code>favail</code>, number, # free inodes for non-root</li>
	<li><code>fsid</code>, number, file system ID</li>
	<li><code>flag</code>, number, mount flags</li>
	<li><code>namemax</code>, number, maximum filename length</li>
</ul></p>
<p>The <code>timeval</code> structure has the following members:<ul>
	<li><code>sec</code>, number, seconds</li>
	<li><code>usec</code>, number, microseconds</li>
</ul></p>]];
	},{
		name = "posixio.stat";
		parameters = {"path", "st"};
		doc = [[Get file status. <code>path</code> is the path to a file. <code>st</code> is a <code>stat</code> userdata created with <code>posixio.new('stat')</code>.]];
	},{
		name = "posixio.fstat";
		parameters = {"fd", "st"};
		doc = [[Get file status. <code>fd</code> is the fd of an open file. <code>st</code> is a <code>stat</code> structure that is filled by <code>posixio.stat</code>.]];
	},{
		name = "posixio.opendir";
		parameters = {"path"};
		doc = [[<p>Open a directory.</p>
<p>Returns nil on error, or a <code>directory</code> userdata on success. See below for the methods of this userdata.</p>]];
	},{
		name = "directory:readdir";
		parameters = {};
		doc = [[<p>Read a file entry from a directory.</p>
<p>Returns nil on error or end of directory listing, or a <code>dirent</code> structure (as a userdata) on success. The <code>dirent</code> structure has the following fields:<ul>
	<li><code>ino</code>, number, inode number</li>
	<li><code>off</code>, number, offset to this dirent</li>
	<li><code>reclen</code>, number, length of this <code>name</code></li>
	<li><code>name</code>, string, filename</li>
</ul></p>]];
	},{
		name = "directory:closedir";
		parameters = {};
		doc = [[Close directory.]];
	},{
		name = "posixio.mkdir";
		parameters = {"path"};
		doc = [[Create a directory.]];
	},{
		name = "posixio.rmdir";
		parameters = {"path"};
		doc = [[Delete a directory.]];
	},{
		name = "posixio.mknod";
		parameters = {"path", "mode", "dev"};
		doc = [[Create a file. <code>mode</code> is a Lua set (see description of <code>stat</code> structure in <code>posixio.new</code> documentation). <code>dev</code> is the device number.]];
	},{
		name = "posixio.unlink";
		parameters = {"path"};
		doc = [[Delete a name and possible the file it refers to.]];
	},{
		name = "posixio.open";
		parameters = {"path", "flags"};
		doc = [[<p>Open a file. <code>flags</code> is a Lua set. The set must contain one of these three flags: <code>'RDWR'</code>, <code>'RDONLY'</code> or <code>'WRONLY'</code>. The following optionnal flags are also recognized: <code>APPEND</code>, <code>ASYNC</code>, <code>CREAT</code>, <code>DIRECT</code>, <code>DIRECTORY</code>, <code>EXCL</code>, <code>LARGEFILE</code>, <code>NOATIME</code>, <code>NOCTTY</code>, <code>NOFOLLOW</code>, <code>NONBLOCK</code>, <code>NDELAY</code>, <code>SYNC</code>, <code>TRUNC</code>.</p>
<p>Returns -1 on error, or a non-negative number on success. That number is a file descriptor and can be used in subsequent access to this file.</p>]];
	},{
		name = "posixio.close";
		parameters = {"fd"};
		doc = [[Close a file. <code>fd</code> is a file descriptor of an open file.]];
	},{
		name = "posixio.read";
		parameters = {"fd", "buf", "size"};
		doc = [[Read from a file descriptor. <code>posixio.read</code> attempts to read up to <code>size</code> bytes from file descriptor <code>fd</code> into the userdata buffer <code>buf</code>. <code>buf</code> can be a light or a full userdata; in either case no size check is performed, so use this function with care.]];
	},{
		name = "posixio.write";
		parameters = {"fd", "buf", "size"};
		doc = [[Write to a file descriptor. <code>posixio.write</code> writes up to <code>size</code> bytes to the file referenced by the descriptor <code>fd</code> from the userdata buffer <code>buf</code>. <code>buf</code> can be a light or a full userdata; in either case no size check is performed, so use this function with care.]];
	},{
		name = "posixio.lseek";
		parameters = {"fd", "offset", "whence"};
		doc = [[<p>Reposition read/write offset. The <code>posixio.lseek</code> function repositions the offset of the open file associated with the file descriptor fildes to the argument offset according to the directive whence as follows:<ul>
	<li><code>'SET'</code>: The offset is set to offset bytes.</li>
	<li><code>'CUR'</code>: The offset is set to its current location plus offset bytes.</li>
	<li><code>'END'</code>: The offset is set to the size of the file plus offset bytes.</li>
</ul></p>
<p>The lseek() function allows the file offset to be set beyond the end of the file (but this does not change the size of the file). If data is later written at this point, subsequent reads of the data in the gap (a "hole") return null bytes ('\0') until data is actually written into the gap.</p>]];
	},{
		name = "posixio.statvfs";
		parameters = {"path", "st"};
		doc = [[Get file system statistics. The function <code>posixio.statvfs</code> returns information about a mounted file system. <code>path</code> is the pathname of any file within the mounted filesystem. <code>st</code> is a <code>statvfs</code> userdata created with <code>posixio.new('statvfs')</code>.]];
	},{
		name = "posixio.utimes";
		parameters = {"path", "times"};
		doc = [[<p>Change access and modification times of an inode, with resolution of 1 microsecond. <code>path</code> is the path of the file to change times, while <code>times</code> is an array of 2 <code>timeval</code> structures created with <code>posixio.new('timeval', 2)</code>.</p>
<p>Note that this function accepts microsecond resolution, while the <code>fs:utimens</code> method of a FUSE filesystem receives nanosecond resolution times. Make the appropriate conversion.</p>]];
	},{
		name = "posixio.rename";
		parameters = {"oldpath", "newpath"};
		doc = [[Change the name or location of a file.]];
	},{
		name = "posixio.getcwd";
		parameters = {"buf", "size"};
		doc = [[
<p>Put the path of the current working directory in the userdata buffer <code>buf</code> of size <code>size</code>.</p>
<p>Returns the address of <code>buf</code> as a light userdata on success, a NULL light userdata on error.</p>
<p><pre>
     local buf = userdata.new(posixio.PATH_MAX)
     local result = posixio.getcwd(buf.data, buf.size)
     if result~=buf.data then error(errno.strerror(errno.errno)) end
</pre></p>]];
	},{
		name = "posixio.PATH_MAX";
		doc = [[This constant is the maximum number of characters allowed in a path on the current system. It may be useful to allocate some buffers passed to other <code>posixio</code> functions.]];
	}
} } }

local funcstr = ""
for sectionid,section in ipairs(functions) do
	funcstr = funcstr..[[
	<div class="section">
	<h2><a name="]]..section.name..[[">%chapterid%.]]..tostring(sectionid).." - "..section.title..[[</a></h2>
]]..section.doc..[[
]]
	for _,func in ipairs(section.functions) do
		funcstr = funcstr..[[
		<div class="function">
		<h3><a name="]]..func.name..[["><code>]]..func.name
		if func.parameters then
			funcstr = funcstr..' ('..table.concat(func.parameters, ", ")..")"
		end
		funcstr = funcstr..[[</code></a></h3>
		<p>]]..func.doc..[[</p>
		</div>
]]
	end
	funcstr = funcstr..[[
	</div>
]]
end

local manual = [[
<p>Here you can find a list of the functions present in the module and how to use them. LUSE main module follows Lua 5.1 package system, see the <a href="http://www.lua.org/manual/5.1/">Lua 5.1 manual</a> for further explanations.</p>
<p>Quick links:<ul>
]]
for _,section in ipairs(functions) do
	manual = manual..'<li><a href="#'..section.name..'">'..section.title..'</a></li>\n'
end
manual = manual..[[
</ul>
</p>
]]
manual = manual..funcstr
chapter('<a name="manual">Manual</a>', manual)

footer()

------------------------------------------------------------------------------

io.output(file_examples)

header()

chapter('<a name="examples">Examples</a>', [[
<p>Here are some filesystem examples.<code>hellofs</code> is just a minimal example. <code>luafs</code> is a basic filesystem that exposes a Lua table as a directory. It can be used as a model to expose some data from a Lua state in your own applications. <code>fwfs</code> is a forwarding filesystem, that can be used as a base to make on the fly operations on file I/O.</p>
<div class="section">
<h2><a name="hellofs">%chapterid%.1 - hellofs</a></h2>
<p><code>hellofs</code> is the Hello World! of FUSE filesystems. It creates a directory with a single file called <code>hello</code> that contain the string <code>"Hello World!"</code>.</p>
<p>Example:
<pre>
$ mkdir tmpdir
$ ./hellofs.lua tmpdir
$ ls tmpdir
hello
$ cat tmpdir/hello
Hello World!
$ fusermount -u tmpdir
</pre></p>
<p>Source code: <a href="hellofs.lua">hellofs.lua</a></p>
</div>

<div class="section">
<h2><a name="luafs">%chapterid%.2 - luafs</a></h2>
<p><code>luafs</code> expose a table as a directory. The subtables are exposed as subdirectories, while the string and userdata fields are exposed as regular files. You can create new files, and write to them: that will create new strings in the table hierarchy.</p>
<p>Example:
<pre>
$ mkdir tmpdir
$ ./luafs.lua tmpdir
$ ls tmpdir
$ echo Hello World! > tmpdir/hello
$ ls tmpdir
hello
$ cat tmpdir/hello
Hello World!
$ mkdir tmpdir/subdir
$ ls tmpdir
hello subdir/
$ echo foo > tmpdir/subdir/bar
$ ls tmpdir/subdir
bar
$ cat tmpdir/subdir/bar
foo
$ fusermount -u tmpdir
</pre></p>
<p>Source code: <a href="luafs.lua">luafs.lua</a></p>
</div>

<div class="section">
<h2><a name="luafs">%chapterid%.3 - fwfs</a></h2>
<p><code>fwfs</code> creates a directory that will forward all I/O to another directory. It's meant to be used as a base for any filesystem that is backed on disk, and that is doing something to the files on the fly. For example it can do filesystem encryption, it can make several directories on different disks appear as a single one, etc.</p>
<p>Example:
<pre>
$ mkdir srcdir
$ echo Hello World! > srcdir/hello
$ mkdir dstdir
$ ./fwfs.lua srcdir dstdir
$ ls dstdir
hello
$ cat dstdir/hello
Hello World!
$ mkdir dstdir/subdir
$ ls srcdir
hello subdir/
$ echo foo > dstdir/subdir/bar
$ ls srcdir/subdir
bar
$ cat srcdir/subdir/bar
foo
$ fusermount -u dstdir
</pre></p>
<p>Source code: <a href="fwfs.lua">fwfs.lua</a></p>
</div>]])

footer()

------------------------------------------------------------------------------

-- vi: ts=4 sts=4 sw=4

