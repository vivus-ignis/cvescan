class PackageVersion::ChunkList

  getter chunks : Array(Array(UInt64))

  # 3.3.30  -> [[3], [302], [3], [302], [30]]
  def initialize(x : String)
    @chunks = x.chars
              .chunks { |c| c.ascii_number? } # split when numbers end
              .map do |tpl|
      if tpl[1].first.number?
        [ tpl[1].join("").to_u64 ] # numbers should be joined
      else
        tpl[1].map { |c| encode_nondigit(c).to_u64 } # non-numbers are treated one by one and encoded
      end
    end
  end

  # "~" sorts before the empty string:
  # 1.0~beta1 < 1.0
  # 2.1~~pre < 2.1~alpha < 2.1~beta < 2.1~rc (Mozilla style pre-releases)
  private def encode_nondigit(c : Char)
    if c == '~'
      -1
    elsif c.ascii_letter?
      c.ord
    else
      c.ord + 256
    end
  end

  # pad smaller of the two arrays with [0]'s
  private def equalize(x : Array(Array(UInt64)), y : Array(Array(UInt64)))
    if y.size < x.size
      diff = x.size - y.size
      y = y + (1..diff).map { |_| [0] }
    elsif x.size < y.size
      diff = y.size - x.size
      x = x + (1..diff).map { |_| [0] }
    end

    {x, y}
  end

  def ==(other : PackageVersion::ChunkList)
    @chunks == other.chunks
  end

  def >(other : PackageVersion::ChunkList)

    my_chunks, other_chunks = equalize @chunks, other.chunks

    # puts "self: #{self}"
    # puts "my: #{my_chunks} vs other: #{other_chunks}"

    my_chunks.each_with_index do |chunk, i|
      return true if chunk > other_chunks[i]
      return false if chunk < other_chunks[i]
    end

    false
  end

  def <(other : PackageVersion::ChunkList)
    other > self
  end

  def <=>(other : PackageVersion::ChunkList)
    self > other ? 1 : (self < other ? -1 : 0)
  end

  def to_s(io)
    io.print "#{@chunks}"
  end

end
