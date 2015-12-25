module Flammarion
  def self.about
    f = Engraving.new(close_on_exit:true)
    f.title "Flammarion #{VERSION}"
    readme = "#{File.absolute_path(File.dirname(__FILE__))}/../../Readme.md"
    license = "#{File.absolute_path(File.dirname(__FILE__))}/../../LICENSE"
    f.markdown(File.read(readme))
    f.break
    f.markdown(File.read(license))
  end
end
