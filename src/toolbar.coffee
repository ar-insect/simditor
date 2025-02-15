
class Toolbar extends SimpleModule

  @pluginName: 'Toolbar'

  opts:
    toolbar: true
    toolbarFloat: true
    toolbarHidden: false
    toolbarFloatOffset: 0

  _tpl:
    wrapper: '<div class="simditor-toolbar"><ul></ul></div>'
    separator: '<li><span class="separator"></span></li>'

  _init: ->
    @editor = @_module
    return unless @opts.toolbar

    unless $.isArray @opts.toolbar
      @opts.toolbar = ['bold', 'italic', 'underline', 'strikethrough', '|',
        'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image', '|',
        'indent', 'outdent']

    @_render()

    @list.on 'click', (e) ->
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor' + @editor.id, (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if not @opts.toolbarHidden and @opts.toolbarFloat
      @wrapper.css 'top', @opts.toolbarFloatOffset
      toolbarHeight = 0

      # unless @editor.util.os.mobile
      $(window).on 'resize.simditor-' + @editor.id, (e) =>
        @wrapper.css 'position', 'static'
        @wrapper.width 'auto'
        @editor.util.reflow @wrapper
        @wrapper.width @wrapper.outerWidth()
        @wrapper.css 'left', @wrapper.offset().left
        @wrapper.css 'position', ''
        toolbarHeight = @wrapper.outerHeight()
        @editor.placeholderEl.css 'top', toolbarHeight
      .resize()

      $(window).on 'scroll.simditor-' + @editor.id, (e) =>
        topEdge = @editor.wrapper.offset().top
        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 80
        scrollTop = $(document).scrollTop() + @opts.toolbarFloatOffset

        if scrollTop <= topEdge or scrollTop >= bottomEdge
          @editor.wrapper.removeClass('toolbar-floating')
            .css('padding-top', '')
          if @editor.util.os.mobile
            @wrapper.css 'top', @opts.toolbarFloatOffset
        else
          @editor.wrapper.addClass('toolbar-floating')
            .css('padding-top', toolbarHeight)
          if @editor.util.os.mobile
            @wrapper.css 'top', scrollTop - topEdge + @opts.toolbarFloatOffset

    @editor.on 'destroy', =>
      @buttons.length = 0

    $(document).on "mousedown.simditor-#{@editor.id}", (e) =>
      @list.find('li.menu-on').removeClass('menu-on')

  _render: ->
    @buttons = []
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error "simditor: invalid toolbar button #{name}"
        continue

      @buttons.push new @constructor.buttons[name]
        editor: @editor

    @wrapper.hide() if @opts.toolbarHidden

  findButton: (name) ->
    button = @list.find('.toolbar-item-' + name).data('button')
    button ? null

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}
