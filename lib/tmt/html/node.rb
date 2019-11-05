class Tmt::HTML::Node
  attr_reader :content

  def initialize(content)
    @content = content || ''
  end

  def find(selector)
    result = self.class.new_result

    content = @content.clone
    position = self.class.position_tag(content, selector)

    while true
      break unless position
      result << self.class.new(content[position[0]..position[1]])
      content[position[0]..position[1]] = ""
      position = self.class.position_tag(content, selector)
    end
    result
  end

  def position_tag(tag_name)
    self.class.position_tag(@content, tag_name)
  end

  # Return pair of position where is nested a node of tag
  # If a node of tag didn't exist then we could get nil
  def self.position_tag(content, tag_name)
    begin_position = content.index(/<\s*#{tag_name}(\>|\s)/i)
    return if begin_position.nil?
    sub_content = content[begin_position, content.length]
    finish_position = sub_content.index(/<\s*\/#{tag_name}(\>|\s)/i)
    return if finish_position.nil?
    finish_position += sub_content[finish_position, sub_content.length].index('>')
    [begin_position, begin_position + finish_position]
  rescue
    nil
  end

  def attr(attr_name)
    @content.scan(/^\s*<[^>]*#{attr_name}=('([^']*)'|"([^"]*)")[^>]*>/i).flatten.first[1..-2]
  rescue
    nil
  end

  def text
    self.class.text(@content)
  end

  def self.text(content)
    content.scan(/<[^>]*>(.*)<[^<]*>/m).flatten.first
  end

  # We can replace node of tag on a content of new_content variable
  def replace!(tag_name, new_content="")
    position = position_tag(tag_name)
    while true
      break if position.nil?
      @content[position[0]..position[1]] = new_content
      position = position_tag(tag_name)
    end
    @content
  end

  private

  def self.new_result
    result = []

    def result.find(selector)
      result = ::Tmt::HTML::Node.new_result
      self.each do |node|
        ::Tmt::HTML::Node.new(node.content).find(selector).each do |element|
          result << element
        end
      end
      result
    end

    def result.text
      self.each do |node|
        return ::Tmt::HTML::Node.new(node.content).text
      end
      ''
    end

    result
  end

end
