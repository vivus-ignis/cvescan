require "../utils"
require "../package"

class PackageManager::Dpkg < PackageManager

  @architecture : String

  def initialize
    @architecture = architecture
    super

    Utils.dputs "installed : #{Utils.snip @installed} (count: #{@installed.size})"
    Utils.dputs "available : #{Utils.snip @available} (count: #{@available.size})"
    Utils.dputs "upgrade candidates : #{Utils.snip @upgrade_candidates} (count: #{@upgrade_candidates.size})"
  end

  # amd64
  private def architecture : String
    Utils.get_command_output("dpkg --print-architecture").chomp
  end

  # [ "deb http://deb.debian.org/debian jessie main", "deb http://security.debian.org/debian-security jessie/updates main" ... ]
  private def sources_lists : Array(String)
    sources_lists = Dir["/etc/apt/sources.list.d/*"]
    sources_lists << "/etc/apt/sources.list"

    Utils.dputs "sources_lists = #{sources_lists}"

    sources_lists.flat_map do |sl|
      File.read_lines(sl).select { |line| line.starts_with? "deb " }
    end
  end

  # http://deb.debian.org/debian/dists/jessie/main/binary-amd64/Packages.gz
  private def repository_index_url_from(sources_list_line) : String
    ls = sources_list_line.split
    base_url = ls[1]
    release = ls[2]
    component = ls[3]

    "#{base_url}/dists/#{release}/#{component}/binary-#{@architecture}/Packages.gz"
  end

  private def fetch_uncompress_repo_index(url)
    Utils.dputs "About to fetch repository index at #{url}"
    contents_gzipped = Utils.get_remote_contents url
    Utils.dputs "Done fetching"

    io = IO::Memory.new contents_gzipped

    Gzip::Reader.open(io) { |gzip| gzip.gets_to_end }.split("\n")
  end

  private def dpkg_status_to_package_hashes(lines : Array(String)) : Array(Hash(String,String))
    Utils.ddump "dpkg_status", lines.join("\n")

    lines
      .select { |line| line =~ /^(Package|Source|Status|Version):/ }
      .chunks { |x| x.starts_with? "Package: " }
      .map { |x| x[1] }
      .in_groups_of(2)
      .map { |x| x.flatten }
      .map { |pkg_a| pkg_a.map { |x| x.not_nil!.split(": ") }.to_h }
  end

  # two types of source values in /var/lib/dpkg/sources:
  # libsepol
  # gcc-4.9 (4.9.2-10+deb8u1)
  private def package_hash_to_package(pkg_hash : Hash(String, String))
    Utils.dputs("pkg_hash = #{pkg_hash}") if pkg_hash["Package"] == "libgcc1"
    matched = if pkg_hash.has_key? "Source"
                /(\S+)(?:\s\((\S+)?\))?/.match pkg_hash["Source"]
              end

    unless matched.nil?
      source_pkg_name = matched[1]
      source_pkg_ver = matched[2]?.nil? ? pkg_hash["Version"] : matched[2]

      source_package = Package::SourcePackage.new(source_pkg_name, source_pkg_ver)
      Package.new(pkg_hash["Package"],
                  pkg_hash["Version"],
                  source_package)
    else
      Package.new(pkg_hash["Package"], pkg_hash["Version"])
    end
  end

  def installed
    dpkg_status_to_package_hashes(File.read_lines("/var/lib/dpkg/status"))
      .select { |pkg_hash| pkg_hash["Status"] =~ /installed/ }
      .map { |pkg_hash| package_hash_to_package pkg_hash }
  end

  def available
    repo_index_urls = sources_lists.map { |sl| repository_index_url_from sl }
    Utils.dputs "Repository index URLs: #{repo_index_urls}"

    repo_indexes = repo_index_urls.reduce([] of String) do |acc, index_url|
      acc = acc + fetch_uncompress_repo_index(index_url); acc
    end
    Utils.dputs "repo_indexes: #{Utils.snip repo_indexes}"

    dpkg_status_to_package_hashes(repo_indexes)
      .map do |pkg_hash|
      # Utils.dputs "pkg_hash: #{pkg_hash}"
      package_hash_to_package pkg_hash
    end
  end

  def upgrade_candidates
    Utils.dputs "upgrade candidates"
    installed_h = @installed.reduce({} of String => Package) do |acc, pkg|
      acc[pkg.name] = pkg
      acc
    end

    candidates = @available.select do |avail_pkg|
      if installed_h.has_key? avail_pkg.name
        installed_h[avail_pkg.name].version < avail_pkg.version
      end
    end
    Utils.dputs "candidates = #{candidates} (count: #{candidates.size})"

    grouped = candidates.group_by { |pkg| pkg.name }
    Utils.dputs "grouped = #{grouped}"

    top_candidates = [] of Package
    grouped.each_value do |pkgs|
      top_candidates << pkgs.max_by { |pkg| pkg.version }
    end
    Utils.dputs "top candidates = #{top_candidates} (count: #{top_candidates.size})"

    top_candidates
  end

  def upgradable
    candidates_by_name = @upgrade_candidates.reduce({} of String => Package) do |acc, pkg|
      acc[pkg.name] = pkg
      acc
    end
    @installed.select do |pkg|
      candidates_by_name.has_key? pkg.name
    end
  end

end
