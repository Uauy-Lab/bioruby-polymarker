require 'redcarpet'

module MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template)
    compiled_source = erb.call(template)
    "Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_intra_emphasis: true, autolink: true).render(begin;#{compiled_source};end).html_safe"
  end

  def self.compile_md(compiled_source)
  	Redcarpet::Markdown.new(
  		Redcarpet::Render::HTML, no_intra_emphasis: true, autolink: true
  		).render(compiled_source).html_safe
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler