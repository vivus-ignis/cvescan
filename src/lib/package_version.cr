class PackageVersion

  # == DEBIAN ==
  # https://manpages.debian.org/wheezy/dpkg-dev/deb-version.5.en.html
  # [epoch:]upstream_version[-debian_revision]

  # The upstream_version may contain only alphanumerics and the
  # characters . + - : (full stop, plus, hyphen, colon) and should
  # start with a digit. If there is no debian_revision then hyphens
  # are not allowed; if there is no epoch then colons are not allowed.

  getter original_version : String
  getter epoch : Int32
  getter version : PackageVersion::ChunkList
  getter revision : PackageVersion::ChunkList

  def initialize(version : String)
    # Utils.dputs "in PackageVersion.new(#{version})"
    @original_version = version

    @epoch, rest = extract_epoch version
    version_raw, revision_raw = extract_version_revision rest

    # Utils.dputs "... epoch: #{@epoch}"
    # Utils.dputs "... version (raw): #{version_raw}"
    # Utils.dputs "... revision (raw): #{revision_raw}"

    @version = PackageVersion::ChunkList.new version_raw
    # Utils.dputs "... @version: #{@version}"
    @revision = PackageVersion::ChunkList.new revision_raw
    # Utils.dputs "... @revision: #{@revision}"
  end

  private def extract_epoch(x : String)
    s = x.split(":")
    return {0, s[0]} if s.size == 1 # no epoch

    {s[0].to_i, s[1]}
  end

  private def extract_version_revision(x : String)
    s = x.split("-")
    return {s[0], "0"} if s.size == 1 # no revision

    {s[0], s[1]}
  end

  def ==(other : PackageVersion)
    return false unless @epoch == other.epoch
    return false unless @version == other.version
    return false unless @revision == other.revision

    true
  end

  def >(other : PackageVersion)
    return true if @epoch > other.epoch
    return true if @epoch == other.epoch && @version > other.version
    return true if @version == other.version && @revision > other.revision

    false
  end

  def <(other : PackageVersion)
    other > self
  end

  def <=>(other : PackageVersion)
    self > other ? 1 : (self < other ? -1 : 0)
  end

  def to_s(io)
    io.print "#{@original_version} | Epoch: #{@epoch} | Version: #{@version} | Revision: #{@revision} "
  end

end

require "./package_version/chunk_list"
