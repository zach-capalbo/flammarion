module Flammarion
  module Writeable
    attr_reader :front_end
    class DeferredValue < Delegator
      def initialize
        super @value
      end
      def __setobj__(value)
        @value = value
      end

      def value
        @value
      end

      def __getobj__
        @value
      end

      def inspect
        "#R#{@value.inspect}"
      end

      def checked?
        return @value
      end
    end

    class Spectrum
      attr_reader :front_end
      def initialize(id, target, front_end)
        @id = id
        @target = target
        @front_end = front_end
      end

      def plot(data, options = {})
        @front_end.send_json({action:'plot', id:@id, target:@target, data:data}.merge(options))
      end
    end

    def send_json(hash)
      @front_end.send_json({target: @pane_name}.merge(hash))
    end

    def send(str, options = {})
      @front_end.send_json({action:'append', text:str, target:@pane_name}.merge(options))
    end
    alias_method :print, :send

    def puts(str = "", options = {})
      send str, options
      send "\n"
      return nil
    end

    def replace(str, options = {})
      send_json({action:'replace', text:str}.merge(options))
      return nil
    end

    def clear
      send_json({action:'clear'})
      return nil
    end

    def close
      send_json({action:'closepane'})
    end

    def plot(values, options = {})
      id = @front_end.make_id
      send_json({action:'plot', data:values, id:id}.merge(options))
      return Spectrum.new(id, @pane_name, @front_end)
    end

    def highlight(text, options = {})
      output = text
      output = JSON.pretty_generate(text) if text.is_a? Hash or text.is_a? Array
      send_json({action:'highlight', text:output}.merge(options))
      nil
    end

    def button(label, options = {}, &block)
      id = @front_end.make_id
      send_json({action:'button', label:label, id:id}.merge(options))
      @front_end.callbacks[id] = block
      id
    end

    def embedded_button(label, options = {}, &block)
      id = @front_end.make_id
      @front_end.callbacks[id] = block
      %|<a class="floating-button" href="#" onClick="$ws.send({id:'#{id}', action:'callback', source:'embedded_button'})">#{label}</a>|
    end

    def callback_link(label, options = {}, &block)
      id = @front_end.make_id
      @front_end.callbacks[id] = block
      %|<a href="#" onClick="$ws.send({id:'#{id}', action:'callback', source:'link'})">#{label}</a>|
    end

    def icon(name, additional_classes = [])
      %|<i class="fa fa-#{name} #{additional_classes.collect{|c| "fa-#{c}"}.join(" ")}"></i>|
    end

    def input(label, options = {}, &block)
      id = @front_end.make_id
      send_json({action:'input', label:label, id:id}.merge(options))
      if block_given?
        @front_end.callbacks[id] = block
      else
        d = DeferredValue.new
        @front_end.callbacks[id] = Proc.new {|v| d.__setobj__ v["text"] }
        return d
      end
    end

    def checkbox(label, options = {}, &block)
      id = @front_end.make_id
      send_json({action:'checkbox', label:label, id:id}.merge(options))
      if block_given?
        @front_end.callbacks[id] = block
      else
        d = DeferredValue.new
        d.__setobj__(options[:value] || options['value'])
        @front_end.callbacks[id] = Proc.new {|v| d.__setobj__(v["checked"])}
        return d
      end
    end

    def break(options = {})
      send_json({action:'break'}.merge(options))
    end

    def html(data)
      send_json({action:'replace', text:data, raw:true})
    end

    def script(coffee, options = {})
      data = options.fetch(:coffee, true) ? CoffeeScript.compile(coffee) : coffee
      send_json({action:'script', data:data}.merge(options))
    end

    def style(attribute, value)
      send_json({action: 'style', attribute: attribute, value: value})
    end

    def template(file)
      data = Slim::Template.new(file).render
      send_json({action:'replace', text:data, raw:true})
    end

    def live_reload_template(file)
      FileWatcher.new(file).watch {|file| template(file) }
    end

    def markdown(text, options = {})
      markdown_html = Redcarpet::Markdown.new(Redcarpet::Render::HTML, {
        tables: true,
        fenced_code_blocks: true,
        autolink: true,
        strikethrough: true,
        superscript: true,
      }.merge(options[:markdown_extensions] || {})).render(text)
      send_json({action:'markdown', text: markdown_html}.merge(options))
    end

    def hide
      send_json({action:'hidepane'})
    end

    def show
      send_json({action:'showpane'})
    end

    def subpane(name)
      send_json({action:'subpane', name:name})
      return Pane.new(@front_end, name)
    end

    def pane(name)
      send_json({action:'addpane', name:name})
      return Pane.new(@front_end, name)
    end

    def orientation=(orientation)
      raise ArgumentError.new("Orientation must be :horizontal or :vertical") unless [:horizontal, :vertical].include?(orientation)
      send_json({action:'reorient', orientation:orientation})
    end

    def button_box(name)
      send_json({action:'buttonbox', name:name})
      return Pane.new(@front_end, name)
    end

    def status(str, position = :right)
      @front_end.send_json({action:'status', text: str, position:position})
    end

    def table(rows, options = {})
      send_json({action:'table', rows: rows}.merge(options))
    end

    def gets(prompt = "", options = {})
      str = nil
      input(prompt, {once:true, focus:true}.merge(options)) {|msg| str = msg["text"]}
      sleep 0.1 while str.nil?
      return str
    end

    def map(*args)
      case (args.size)
      when 1
        if args[0].respond_to? :keys then
          options = args[0]
        else
          options = {address:args[0].to_s}
        end
      when 2
        if args[1].respond_to? :keys then
          options = {address:args[0]}.merge(args[1])
        else
          options = {latitude:args[0], longitude:args[1]}
        end
      when 3
        options = {latitude:args[0], longitude:args[1]}.merge(args[2])
      else
        raise ArgumentError.new("Expected 1..3 arguments")
      end
      send_json({action:'map'}.merge(options))
    end
  end
end
