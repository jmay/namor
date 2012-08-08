require "namor/version"

module Namor
  def self.extract(name, args = {})
    return [] if name.nil?

    suppression_list = args[:suppress] || []
    suppression_re = suppression_list.join('|')

    detitled_name = name.upcase.gsub(/\b(#{suppression_re})\b/i, '').gsub(/\b(MD|JR|SR|I+|IV)\b/i, '').gsub(/\([^\(]*\)/, '').gsub(/[_.'-]/, '').gsub(/,\s*$/, '').gsub(/ +/, ' ').strip

    if detitled_name =~ /,/
      # "last, first[ middle]"
      lastname, firstname = detitled_name.split(/\s*,\s*/)
      lastname.gsub!(/ /, '')
      middlename = nil
      if firstname && firstname =~ / /
        pieces = firstname.split(/ +/)
        firstname = pieces.shift
        middlename = pieces.join if pieces.any?
      end
    else
      # "first [middle ]last"
      pieces = detitled_name.split(' ')
      firstname = pieces.shift
      middlename = nil
      if pieces.count > 1 && pieces.first.length == 1
        # assume this is a middle initial
        middlename = pieces.shift
      end

      lastname = pieces.join
    end

    firstname = nil if firstname.empty?
    middlename = nil if middlename && middlename.empty?
    lastname = nil if lastname.empty?

    fm = [firstname, middlename].compact.join(' ')
    fullname = [lastname, fm].compact.join(',')

    [firstname, middlename, lastname, fullname]
  end

  def self.extract_with_cluster(name, args = {})
    ary = extract(name, args)
    return [] if ary.empty?
    ary << ary.last.gsub(/\W/, '_')
  end
end
