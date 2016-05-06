module Flammarion
  module Writeable
    # @api private
    attr_reader :engraving

    # A way to retrieve the current value of a user interacterive component.
    # @see Writeable#input
    # @see Writeable#checkbox
    # @see Writeable#dropdown
    class DeferredValue < Delegator
      # @api private
      def initialize
        super @value
      end

      # @api private
      def __setobj__(value)
        @value = value
      end

      # @return [Object] the current value of the remote component
      def value
        @value
      end

      # @api private
      def __getobj__
        @value
      end

      # @return [String] a string representing the remote component's value
      def inspect
        "#R#{@value.inspect}"
      end

      # @return [Boolean] true if the component is checked and false if it is
      #  not. Undefined if the component is not a checkbox.
      def checked?
        return @value
      end
    end

    # A representation of a plot in a writeable area. See {Writeable#plot}
    class Plot
      attr_reader :engraving
      def initialize(id, target, engraving)
        @id = id
        @target = target
        @engraving = engraving
      end

      def plot(data, options = {})
        if data.respond_to?(:keys)
          options = options.merge(data)
          data = [data]
        elsif not data.first.respond_to?(:keys)
          data = [{y:data, x:(1..data.size).to_a}.merge(options)]
        end
        @engraving.send_json({action:'plot', id:@id, target:@target, data:data}.merge(options))
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

    # @!macro [new] add_options
    # @option options [Boolean] :replace If true, will replace any existing
    #  contents of the writeable area.
    # @option options [Hash] :style A map of css style attributes and values to
    #  be applied to the element before it is added.

    # @api private
    def send_json(hash)
      @engraving.send_json({target: @pane_name}.merge(hash))
    end

    # Adds text to the writeable area without appending a newline.
    # @param str [String] The text to append
    # @macro escape_options
    def send(str, options = {})
      @engraving.send_json({action:'append', text:str, target:@pane_name}.merge(options))
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
    # @macro add_options
    # @return [Plot] A Plot object for manipulation after creation.
    # @overload plot(array, options)
    #   @param [Array<Number>] values A list of numbers to plot
    # @overload plot(dataset, options)
    def plot(data, options = {})
      id = @engraving.make_id
      p = Plot.new(id, @pane_name, @engraving)
      p.plot(data, options)
      return p
    end

    # Adds a pretty-printed, colorful display of data or code
    # @overload highlight(data, options)
    #   Adds a pretty-printed, highlighted display of data
    #   @param text [Hash, Array] A dataset to be displayed
    #   @macro escape_options
    # @overload highlight(text, options)
    #   Adds syntax-highlighted code to the writeable area
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
      id = @engraving.make_id
      send_json({action:'button', label:label, id:id}.merge(options))
      @engraving.callbacks[id] = block
      id
    end

    # Creates a string representing a button  will call the given block when it
    # is clicked.
    # @macro string_representation
    # @param label [String] The label on the button
    # @return A string representing the html for the button.
    def embedded_button(label, options = {}, &block)
      id = @engraving.make_id
      @engraving.callbacks[id] = block
      %|<a class="floating-button" href="#" onClick="$ws.send({id:'#{id}', action:'callback', source:'embedded_button'})">#{label}</a>|
    end

    # Creates a string representing a hyperlink that when clicked will call the
    # given block.
    # @macro string_representation
    # @param label [String] The text to become the link
    # @return a string representing the html for the link.
    def callback_link(label, options = {}, &block)
      id = @engraving.make_id
      @engraving.callbacks[id] = block
      %|<a href="#" onClick="$ws.send({id:'#{id}', action:'callback', source:'link'})">#{label}</a>|
    end

    # Creates a string representing a Font Awesome icon.
    # @macro string_representation
    # @param name [String] The name of a Font Awesome icon class. See
    # @see https://fortawesome.github.io/Font-Awesome/icons/
    def icon(name, additional_classes = [])
      %|<i class="fa fa-#{name} #{additional_classes.collect{|c| "fa-#{c}"}.join(" ")}"></i>|
    end

    # Creates a new text-input field into which the user can enter text.
    # If a block is given, the block will be called when ever the text is
    # changed. If a block is not given, it will return a DeferredValue object
    # which can be used to get the value at any time.
    # @param label [String] The displayed placeholder text for the input. This
    #  does not set the actual value of the input field or the returned
    #  {DeferredValue}. Use the +:value+ option for that.
    # @option options [Boolean] :multiline (false) Creates a large text box if
    #  true; otherwise creates a single line input box.
    # @option options [Boolean] :autoclear (false) Automatically clears the
    #  input field every time the user changes the value. The callback will only
    #  be called for user initiated changes, not for auto-clear changes.
    # @option options [Boolean] :history (false) Keeps track of entered values,
    #  letting the user choose betwen them with the up and down keys.
    # @option options [String] :value Sets the starting value of the field and
    #  the returned {DeferredValue}.
    # @option options [Boolean] :once (false) If true, then the input box will
    #  be converted into a normal line of text once the user has changed it.
    #  The callback will still be called, but the user will no longer be able
    #  to change the text.
    # @option options [Boolean] :keep_label (false) If +:once+ is also set, this
    #  will prepend +label+ when converting the input to plain text.
    # @option options [Boolean] :enter_only (false) Only accept the users input
    #  when the enter key is pressed, not merely when it changes.
    # @overload input(label, options = {})
    #  @return [DeferredValue] An object representing the current value of the
    #   input, which can be converted to text using +#to_s+.
    # @overload input(label, options = {})
    #  @yield [message_hash] Invokes the block every time the text changes. The
    #   new text of the input can be obtained from the +"text"+ key of the
    #   +message_hash+.
    def input(label, options = {}, &block)
      id = @engraving.make_id
      send_json({action:'input', label:label, id:id}.merge(options))
      if block_given?
        @engraving.callbacks[id] = block
      else
        d = DeferredValue.new
        @engraving.callbacks[id] = Proc.new {|v| d.__setobj__ v["text"] }
        return d
      end
    end

    # Creates a dropdown menu for a user to choose a list of options
    # @param items [Array<#to_s>] The possible choices
    # @overload dropdown(items, options = {})
    #  @return [DeferredValue] An object representing the currently selected
    #   item, which can be retrieved using {DeferredValue#value}
    # @overload dropdown(item, options = {})
    #  @yield [message_hash] Invokes the block every time the user selects a
    #   different option. Current item text can be obtained from the +"text"+
    #   key of the +message_hash+
    def dropdown(items, options = {}, &block)
      id = @engraving.make_id
      send_json({action:'dropdown', id:id, options:items}.merge(options))
      if block_given?
        @engraving.callbacks[id] = block
      else
        d = DeferredValue.new
        d.__setobj__(items[0]) if items.is_a? Array
        d.__setobj__(items[items.keys.first]) if items.is_a? Hash
        @engraving.callbacks[id] = Proc.new {|v| d.__setobj__ v["value"]}
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
      id = @engraving.make_id
      send_json({action:'checkbox', label:label, id:id}.merge(options))
      if block_given?
        @engraving.callbacks[id] = block
      else
        d = DeferredValue.new
        d.__setobj__(options[:value] || options['value'])
        @engraving.callbacks[id] = Proc.new {|v| d.__setobj__(v["checked"])}
        return d
      end
    end

    # Adds a horizontal rule
    def break(options = {})
      send_json({action:'break'}.merge(options))
    end

    # Renders raw html into the writeable area
    def html(data)
      send_json({action:'replace', text:data, raw:true})
    end

    # Runs a script in the engraving window.
    # @param text [String] The script to run. Lanuage of the script depends on
    #  the options given. Defaults to CoffeeScript
    # @option options [Boolean] :coffee (true) If true, will compile +text+ from
    #  CoffeeScript to JavaScript. If false, will pass text as plain JavaScript
    def script(text, options = {})
      data = options.fetch(:coffee, true) ? CoffeeScript.compile(text) : text
      send_json({action:'script', data:data}.merge(options))
    end

    # Sets CSS styles attributes on the current pane.
    # @overload style(attribute, value)
    #   @param attribute [String] The css attribute to set. Currently does not
    #    support selectors or anything.
    #   @param value [#to_s] The value to set the attribute to. (Don't forget
    #    units!)
    # @overload style(attributes)
    #   @param attributes [Hash] Table of css attribute to value mapping to set.
    def style(*args)
      case args.length
      when 1
        # @todo Pass this as a whole hash, rather than individually.
        args[0].each{|a,v| send_json({action: 'style', attribute: a, value: v})}
      when 2
        send_json({action: 'style', attribute: args[0], value: args[1]})
      else
        raise ArgumentError.new("Invalid number of arguments (Expected 1 or 2)")
      end
    end

    # Will render the given Slim template into the Writeable area. This is
    # useful for creating complex or custom application layouts components
    # beyond what's built into Flammarion.
    # @note If you just want to include html (or outut from another template
    #  engine, you can just use {#html})
    # @param file [String] Path to the Slim file to render
    # @see http://slim-lang.com/
    def template(file)
      data = Slim::Template.new(file).render
      send_json({action:'replace', text:data, raw:true})
    end

    # Reloads a template every time the file changes. This is mostly just useful
    # when developing a template file.
    # @see #template
    def live_reload_template(file)
      FileWatcher.new(file).watch {|file| template(file) }
    end

    # Renders the given markdown text into the pane.
    # @param text [String] The markdown text to render.
    # @option options [Hash] :markdown_extensions Additional Redcarpet
    #  extensions to enable.
    # @macro add_options
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

    # Hides (but doesn't close) the pane. This allows the pane to be written
    # to without it opening up again.
    # @see show
    def hide
      send_json({action:'hidepane'})
    end

    # Shows a hidden pane.
    # @see hide
    def show
      send_json({action:'showpane'})
    end

    # @!macro [new] pane_difference
    #  @note The difference between pane and subpane is that a pane is
    #   automatically scaled depending on the number of other panes and the
    #   current orientation, while subpanes are automatically the size of their
    #   contents.
    #   Another way to think about it might be that pane creates structural
    #   layout elements, while subpane creates embedded sections within other
    #   panes.

    # Creates a writeable area within the current writeable area. This lets you
    # update the contents of the writeable later, without disturbing the rest
    # of the curent pane. If a pane or subpane with the given name already
    # exists, it will just use that one instead.
    # @param name [String] an identifier for the subpane. All panes and subpanes
    #  share the same scope, so you want to be careful with your naming.
    # @return [Pane] The newly created or already existing pane.
    # @macro pane_difference
    # @see #pane
    def subpane(name, options = {})
      send_json({action:'subpane', name:name}.merge(options))
      return Pane.new(@engraving, name)
    end

    # Creates a scaled pane within the current writeable area. Where it goes
    # depends on the orientation.
    # @param name [String] an identifier for the subpane. All panes and subpanes
    #  share the same scope, so you want to be careful with your naming.
    # @return [Pane] The newly created or already existing pane.
    # @macro pane_difference
    # @see #pane
    # @see #orientation=
    def pane(name, options = {})
      send_json({action:'addpane', name:name}.merge(options))
      return Pane.new(@engraving, name)
    end

    # Changes the orientation of the panes within this Writeable area. If
    # +orientation+ is +:vertical+ (the default), the panes will be stacked on
    # top of each other, each occupying 1/nth of the height (where n is the
    # number of panes) and 100% of the width. If +orientation+ is +:horizontal+,
    # the panes will be placed next to each other, with each pane occupying 1/n of
    # the width (where n is the number of panes) and 100% of the heigh.
    # @note This applies only to panes, not to subpanes.
    # @see #pane
    # @param orientation [Symbol]  can be +:horizontal+ or +:vertical+
    # @raise ArgumentError if the orientation is not one of the allowed values
    def orientation=(orientation)
      raise ArgumentError.new("Orientation must be :horizontal or :vertical") unless [:horizontal, :vertical].include?(orientation)
      send_json({action:'reorient', orientation:orientation})
    end

    # Pops up a little floating writeable pane for buttons and stuff.
    # @overload button_box()
    #  @return [Pane] The {Writeable} associated with the button box
    # @overload button_box(name)
    #  @deprecated
    def button_box(name = "buttonbox")
      send_json({action:'buttonbox', name:name})
      return Pane.new(@engraving, name)
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
      @engraving.send_json({action:'status', text: str}.merge(options))
    end

    # Displays a table of data
    # @param rows [Array<Array<#to_s>>] an array of rows, where each row is an
    #  array of objects which will be converted to a string and diplayed in the
    #  table.
    # @macro escape_options
    # @option options [Array<#to_s>] :headers An array of column headers to put
    #  at the top of the table.
    # @option options [Boolean] :interactive (true) Allows the user to mouse
    #  over the table and have it styled. Set to false if you experience
    #  performance issues with large datasets.
    def table(rows, options = {})
      send_json({action:'table', rows: rows}.merge(options))
    end

    # Prompts the user for a sting. Blocks until a string has been entered.
    # @param prompt [String] A prompt to tell the user what to input.
    # @param options Same as {#input}
    # @return [String] The text that the user has entered.
    # @see #input
    def gets(prompt = "", options = {})
      str = nil
      input(prompt, {once:true, focus:true}.merge(options)) {|msg| str = msg["text"]}
      sleep 0.1 while str.nil?
      return str
    end

    # Adds an interactive street map of a specified location.
    # @option options [Integer] :zoom (13) The initial zoom level
    # @option options [Boolean] :marker (true) Display a marker on the
    #  identified address or coordinates
    # @macro add_options
    # @overload map(options)
    # @overload map(address, options = {})
    #  @param address [String] The address or landmark to look up and display.
    # @overload map(latitude, longitude, options = {})
    #  @param latitude [Float] The latitude to display
    #  @param longitude [Float] The longitude to display
    # @note Street map provided by http://openstreetmap.org
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

    # Searches for and highlights the string in the engraving.
    def search(string)
      send_json({action:'search', text: string})
    end
  end
end
