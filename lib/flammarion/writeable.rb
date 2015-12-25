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

    # @!macro [new] escape_options
    #  @option options [Boolean] :raw (false) Perform no escaping at all.
    #  @option options [Boolean] :colorize (true) Translate ANSI color escape
    #   codes into displayable colors.
    #  @option options [Boolean] :escape_html (true) Renders any html tags as
    #   plain text. If false, allows any arbitrary html to be rendered in the
    #   writeable area.
    #  @option options [Boolean] :escape_icons (false) If true, will translate
    #   any text between two `:` into a font-awesome icon. (E.g. :thumbs-up:)

    # @!macro [new] string_representation
    #   The string can be included in text for text-accepting methods (such as
    #   +#puts+, +#table+, etc).
    #   @note Don't forget to set the :escape_html option to false when including
    #    this string.

    def send_json(hash)
      @front_end.send_json({target: @pane_name}.merge(hash))
    end

    # Adds text to the writeable area without appending a newline.
    # @param str [String] The text to append
    # @macro escape_options
    def send(str, options = {})
      @front_end.send_json({action:'append', text:str, target:@pane_name}.merge(options))
    end
    alias_method :print, :send

    # Adds text to the writeable area and appends a newline.
    # @param str [String] The text to append
    # @macro escape_options
    def puts(str = "", options = {})
      send str, options
      send "\n"
      return nil
    end

    # Replaces the contents of the writeable area with text
    # @param str [String] The text to append
    # @macro escape_options
    def replace(str, options = {})
      send_json({action:'replace', text:str}.merge(options))
      return nil
    end

    # Clears the contents of the writeable area
    def clear
      send_json({action:'clear'})
      return nil
    end

    # Closes the pane or window
    def close
      send_json({action:'closepane'})
      return nil
    end

    # Creates a new plot to display single axis data
    # @param [Array<Number>] values A list of numbers to plot
    # TODO: @options
    # @return [Spectrum] A Spectrum object for manipulation after creation.
    def plot(values, options = {})
      id = @front_end.make_id
      send_json({action:'plot', data:values, id:id}.merge(options))
      return Spectrum.new(id, @pane_name, @front_end)
    end

    # @overload highlight(data, options)
    #   Adds a pretty-printed, highlighted display of data
    #   @param text [Hash, Array] A dataset to be displayed
    #   @macro escape_options
    # @overload highlight(text, options)
    #   Adds syntax-highlighted text or code to the writeable area
    #   @param text [String] Code to be highlighed
    #   @macro escape_options
    def highlight(text, options = {})
      output = text
      output = JSON.pretty_generate(text) if text.is_a? Hash or text.is_a? Array
      send_json({action:'highlight', text:output}.merge(options))
      nil
    end

    # Adds a clickable button which will call +block+ when clicked
    # @param label [String] The text of the button
    # @option options [Boolean] :inline (false) If true, creates a small button
    #    embedded in the text. If false, creates a button that spans the width
    #    of the writeable area.
    # @macro escape_options
    def button(label, options = {}, &block)
      id = @front_end.make_id
      send_json({action:'button', label:label, id:id}.merge(options))
      @front_end.callbacks[id] = block
      id
    end

    # Creates a string representing a button  will call the given block when it
    # is clicked.
    # @macro string_representation
    # @param label [String] The label on the button
    # @return A string representing the html for the button.
    def embedded_button(label, options = {}, &block)
      id = @front_end.make_id
      @front_end.callbacks[id] = block
      %|<a class="floating-button" href="#" onClick="$ws.send({id:'#{id}', action:'callback', source:'embedded_button'})">#{label}</a>|
    end

    # Creates a string representing a hyperlink that when clicked will call the
    # given block.
    # @macro string_representation
    # @param label [String] The text to become the link
    # @return a string representing the html for the link.
    def callback_link(label, options = {}, &block)
      id = @front_end.make_id
      @front_end.callbacks[id] = block
      %|<a href="#" onClick="$ws.send({id:'#{id}', action:'callback', source:'link'})">#{label}</a>|
    end

    # Creates a string representing a Font Awesome icon.
    # @macro string_representation
    # @param name [String] The name of a Font Awesome icon class. See
    # @see https://fortawesome.github.io/Font-Awesome/icons/ for the list.
    def icon(name, additional_classes = [])
      %|<i class="fa fa-#{name} #{additional_classes.collect{|c| "fa-#{c}"}.join(" ")}"></i>|
    end

    # Creates a new text-input field into which the user can enter text.
    # If a block is given, the block will be called when ever the text is
    # changed. If a block is not given, it will return a DeferredValue object
    # which can be used to get the value at any time.
    # @param label [String] The displayed placeholder text for the input. This
    #  does not set the actual value of the input field or the returned
    #  +DeferredValue+. Use the +:value+ option for that.
    # @option options [Boolean] :multiline (false) Creates a large text box if
    #  true; otherwise creates a single line input box.
    # @option options [Boolean] :autoclear (false) Automatically clears the
    #  input field every time the user changes the value. The callback will only
    #  be called for user initiated changes, not for auto-clear changes.
    # @option options [String] :value Sets the starting value of the field and
    #  the returned +DeferredValue+.
    # @option options [Boolean] :once (false) If true, then the input box will
    #  be converted into a normal line of text once the user has changed it.
    #  The callback will still be called, but the user will no longer be able
    #  to change the text.
    # @option options [Boolean] :keep_label (false) If +:once+ is also set, this
    #  will prepend +label+ when converting the input to plain text.
    # @overload input(label, options = {})
    #  @return [DeferredValue] An object representing the current value of the
    #   input, which can be converted to text using +#to_s+.
    # @overload input(label, options = {})
    #  @yield [message_hash] Invokes the block every time the text changes. The
    #   new text of the input can be obtained from the +"text"+ key of the
    #   +message_hash+.
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

    # Creates a dropdown menu for a user to choose a list of options
    # @param items [Array<#to_s>] The possible choices
    # @overload dropdown(items, options = {})
    #  @return [DeferredValue] An object representing the currently selected
    #   item, which can be converted to text using +#to_s+
    # @overload dropdown(item, options = {})
    #  @yield [message_hash] Invokes the block every time the user selects a
    #   different option. Current item text can be obtained from the +"text"+
    #   key of the +message_hash+
    def dropdown(items, options = {}, &block)
      id = @front_end.make_id
      send_json({action:'dropdown', id:id, options:items}.merge(options))
      if block_given?
        @front_end.callbacks[id] = block
      else
        d = DeferredValue.new
        @front_end.callbacks[id] = Proc.new {|v| d.__setobj__ v["text"]}
        return d
      end
    end

    # Creates a new checkbox which the user can click.
    # @param label [String] The placeholder text for the input
    # @macro escape_options
    # @overload checkbox(label, options = {})
    #  @return [DeferredValue] An object representing the current value of the
    #   checkbox. Use +#checked?+ to get the state of the checkbox.
    # @overload checkbox(label, options = {})
    #  @yield [message_hash] Invokes the block every time the checkbox is
    #   toggled. Use the "checked" field of +message_hash+ to get the new state
    #   of the checkbox.
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

    # Adds a horizontal rule
    def break(options = {})
      send_json({action:'break'}.merge(options))
    end

    # Adds raw html
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

    def subpane(name, options = {})
      send_json({action:'subpane', name:name}.merge(options))
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

    def button_box(name = "buttonbox")
      send_json({action:'buttonbox', name:name})
      return Pane.new(@front_end, name)
    end

    # Displays a message to the bottom status bar.
    # @param str [String] The message to display
    # @overload status(str, position)
    #  @param position [Symbol] Where to put it. May be +:left+ or +:right+
    # @overload status(str, options = {})
    #  @option options [Symbol] :position Where to put it. May be +:left+ or +:right+
    #  @escape_options
    def status(str, options = {})
      options = {position: options} if options.is_a? Symbol
      @front_end.send_json({action:'status', text: str}.merge(options))
    end

    def table(rows, options = {})
      send_json({action:'table', rows: rows}.merge(options))
    end

    # Prompts the user for a sting. Blocks until a string has been entered.
    # @param prompt [String] A prompt to tell the user what to input.
    # @param options (See #input)
    # @return [String] The text that the user has entered.
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

    def search(string)
      send_json({action:'search', text: string})
    end
  end
end
