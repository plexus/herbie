module Herbie
  module Escape
    def glob(str)
      %w<[ ] * ? { }>.each do |p|
        str = str.gsub(p, '\\' + p)
      end
      str
    end

    self.extend self
  end
end
