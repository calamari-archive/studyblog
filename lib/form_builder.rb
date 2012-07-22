module Studyblog
  class FormBuilder < ActionView::Helpers::FormBuilder
    def text_field(name, options={})
      options[:class] = 'text' + (options[:class].nil? ? '' : ' ' + options[:class])
      super(name, options)
    end

    def password_field(name, options={})
      options[:class] = 'text' + (options[:class].nil? ? '' : ' ' + options[:class])
      super(name, options)
    end

    alias :super_label :label

    def label(name, text=nil, options={})
      options[:class] = 'label' + (options[:class].nil? ? '' : ' ' + options[:class])
      super(name, text, options)
    end

    def plain_label(name, text=nil, options={})
      super_label(name, text, options)
    end

    def submit(value=nil, options={})
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value
      button value, options.reverse_merge(:type => 'submit')
    end

    def button(text, options={})
      @template.content_tag :button, text, options
    end
  end
end
