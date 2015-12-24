module Flammarion
  def self.about
    f = Engraving.new(close_on_exit:true)
    f.title "Flammarion #{VERSION}"
    readme = "#{File.absolute_path(File.dirname(__FILE__))}/../../Readme.md"
    f.markdown(File.read(readme))
  end
end
