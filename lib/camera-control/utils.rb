require 'fileutils'
require 'tempfile'

class << Tempfile
  # open_auto_rename opens a temporary file for writing, executes the block,
  # and on success renames the temporary file as the intended file.
  def open_auto_rename filename
    path = File.expand_path filename
    stat = File.stat path rescue nil
    ret  = nil

    self.open path, '' do |io|
      ret = yield io
      if stat
        io.chmod stat.mode rescue nil
        io.chown stat.uid, stat.gid rescue nil
      end
      io.close
      FileUtils.mv io.path, path
    end

    ret
  end
end
