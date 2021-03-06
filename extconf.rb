=begin
  top-level extconf.rb for Ruby-GNOME2

  $Id: extconf.rb,v 1.17 2007/10/22 12:19:17 ktou Exp $

  Copyright (C) 2003-2005 Ruby-GNOME2 Project Team
=end

require 'English'
require 'mkmf'
require 'fileutils'
require 'pathname'

priorlibs = [
  "glib2",
  "gio2",
  "gdk_pixbuf2",
  "pango",
  "atk",
  "gtk2",
  "gdk3",
  "gtk3",
]

#
# detect sub-directories
#
$ruby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['RUBY_INSTALL_NAME'] + RbConfig::CONFIG['EXEEXT'])
$ruby = arg_config("--ruby", $ruby)

rm = "rm -f"
if /mswin32/ =~ RUBY_PLATFORM
  rm = "del"
end


$srcdir = File.dirname(__FILE__)
$topsrcdir = $configure_args["--topsrcdir"] ||= $srcdir
$topdir = $configure_args["--topdir"] ||= Dir.pwd
$strict = $configure_args["--strict"] ? "--strict" : ""

$srcdir = File.expand_path($srcdir)
$topsrcdir = File.expand_path($topsrcdir)
$topdir = File.expand_path($topdir)

subdirs = ARGV.select{|v|  /^--/ !~ v}

if subdirs.size == 0
  subdirs = Dir.glob($topsrcdir+"/*/extconf.rb")
  subdirs.collect! do |subdir|
    subdir[0..$topsrcdir.size] = ""
    File.dirname(subdir)
  end
  priorlibs &= subdirs
  subdirs -= priorlibs
  subdirs = priorlibs + subdirs #Change the order
end

#
# generate sub-directory Makefiles
#
target_modules = []
ignore_modules = []

ruby, *ruby_args = Shellwords.shellwords($ruby)
if ARGV.grep(/\A--ruby=/)
  extra_args = ["--ruby=#{$ruby}"] + ARGV.reject {|arg| /\A--ruby=/ =~ arg}
else
  extra_args = ARGV.dup
end

subdirs.each do |subdir|
  STDERR.puts("#{$0}: Entering directory `#{subdir}'")
  FileUtils.mkdir_p(subdir)
  topdir = File.join(*([".."] * subdir.split(/\/+/).size))
  dir = $topsrcdir
  dir = File.join(topdir, dir) unless Pathname.new(dir).absolute?
  srcdir = File.join(dir, subdir)
  args = ruby_args + ["-C", subdir, File.join(srcdir, "extconf.rb"),
                      "--topsrcdir=#{dir}", "--topdir=#{topdir}",
                      *extra_args]
  ret = system(ruby, *args)
  STDERR.puts("#{$0}: Leaving directory '#{subdir}'")
  if ret
    target_modules << subdir
  else
    ignore_modules << subdir
  end
end
puts "\n-----"
unless target_modules.empty?
  puts "Target libraries: #{target_modules.join(', ')}"
end
unless ignore_modules.empty?
  puts "Ignored libraries: #{ignore_modules.join(', ')}"
end

#
# generate top-level Makefile
#

def run_make_in_sub_dir(sub_dir, target)
  if /mswin32/ =~ RUBY_PLATFORM
    "	$(COMMAND) '#{sub_dir}' $(MAKE) #{target}"
  else
    "	(cd '#{sub_dir}' && $(MAKE) #{target})"
  end
end


File.open("Makefile", "w") do |makefile|
  makefile.print(<<-EOM)
TOPSRCDIR = #{$topsrcdir}
COMMAND = #{$ruby} #{$topsrcdir}/exec_make.rb #{$strict}
RM = #{rm}
EOM

  ["all", "install", "site-install", "clean", "distclean"].each do |target|
    makefile.print(<<-EOM)
#{target}:
EOM
    target_modules.each do |target_module|
      sub_target = "#{target}-#{target_module}"
      makefile.print(<<-EOM)
#{target}: #{sub_target}
#{sub_target}:
	#{run_make_in_sub_dir(target_module, target)}

EOM
    end
  end

  makefile.print(<<-EOM)
distclean: distclean-toplevel
distclean-toplevel:
	$(RM) Makefile mkmf.log
EOM
end

puts "-----"
puts "Done."

$makefile_created = true
