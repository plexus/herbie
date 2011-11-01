module Herbie
  module Filename
    def directory?
      File.directory? self
    end

    def file?
      File.file? self
    end

    def basename
      File.basename self
    end
  end
end
