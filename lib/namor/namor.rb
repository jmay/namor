class Namor::Namor
  def initialize(opts = {})
    config(opts)
    @re_cache = {}
  end

  def config(opts)
    @config = opts
  end


  def suppression_re(supp_list)
    suppression_list = (@config[:suppress] || []) + (supp_list || [])

    re = '\b(' + suppression_list.compact.map{|s| s.chomp('.')}.map(&:upcase).join('|') + ')\b'
    Regexp.new(re)
    # bits = suppression_list.compact.map do |s|
    #   '\b' + s.upcase.chomp('.') + '\b'
    # end
    # Regexp.new(bits.join('|'))
  end

  # clean up a single name component
  # * output all converted to uppercase
  # * strip leading ZZ+ or XX+ (frequently used as invalid-account prefixes)
  # * remove any words that are in the user-provided suppression list
  # * remove words from list of common suffixes (Jr, Sr etc)
  # * remove anything inside parenthesis
  # * remove punctuation
  # * squeeze whitespace & trim spaces from ends
  def scrub(name, opts = {})
    @re_cache[opts[:suppress]] ||= suppression_re(opts[:suppress])

    name && name.upcase.gsub(/^[ZX]{2,}/, '').gsub(@re_cache[opts[:suppress]], '').gsub(/\b(JR|SR|II|III|IV)\b/i, '').gsub(/\([^\(]*\)/, '').gsub(/\./, ' ').gsub(/[_'\&]/, '').gsub(/,\s*$/, '').gsub(/ +/, ' ').strip
  end

  def fullscrub(name, opts = {})
    final_cleaning(scrub(name, opts))
  end

  def demaiden(lastname)
    return [nil,nil] unless lastname && !lastname.empty?
    if lastname =~ /\-/
      [lastname.gsub(/ /, ''), lastname.split(/\-/).last.gsub(/ /, '')]
    else
      [lastname.gsub(/ /, ''), lastname.split(/ /).last]
    end
  end

  def final_cleaning(name)
    if name && !name.empty?
      name.gsub(/\-/, '')
    else
      nil
    end
  end

  def extract(name, opts = {})
    return [] if name.nil?

    detitled_name = scrub(name, opts)

    if detitled_name =~ /,/
      # "last, first[ middle]"
      lastname, firstname = detitled_name.split(/\s*,\s*/)
      lastname, de_maidened_last = demaiden(lastname)
      middlename = nil
      if firstname && firstname =~ / /
        pieces = firstname.split(/ +/)
        firstname = pieces.shift
        middlename = pieces.join if pieces.any?
      end
    else
      # "first [middle-initial ]last" or "first everything-else-is-the-lastname"
      pieces = detitled_name.split(' ')
      firstname = pieces.shift
      if pieces.count > 1 && pieces.first.length == 1
        # assume this is a middle initial
        middlename = pieces.shift
      else
        middlename = nil
      end

      lastname, de_maidened_last = demaiden(pieces.join(' '))
    end

    firstname = final_cleaning(firstname)
    middlename = final_cleaning(middlename)
    lastname = final_cleaning(lastname)
    de_maidened_last = final_cleaning(de_maidened_last)

    fm = [firstname, middlename].compact.join(' ')
    fullname = [lastname, fm].compact.join(',')
    nee_fullname = [de_maidened_last, fm].compact.join(',')

    [firstname, middlename, lastname, fullname, nee_fullname]
  end

  def extract_with_cluster(name, opts = {})
    ary = extract(name, opts)
    return [] if ary.empty?
    ary << ary[3].gsub(/\W/, '_')
  end


  def components(*args)
    suppression_list = @config[:suppress] ? @config[:suppress].map(&:upcase) : []

    names = args
    bits = []
    names.compact.each do |name|
      name = name.dup
      name.gsub!(/\([^\(]*\)/, '')
      name.gsub!(/\[[^\[]*\]/, '')
      name.gsub!(/[\(\)\[\]\']/, '')
      name.gsub!(/[,._-]/, ' ')
      bits += name.split(/\s+/).map(&:upcase)
    end

    suppress_re = %w{MD JR SR I+ IV}.join('|')
    bits.delete_if {|bit| suppression_list.include?(bit) || bit =~ /^(#{suppress_re})$/}
    bits.delete_if(&:empty?)
    bits.uniq.sort
  end
end
