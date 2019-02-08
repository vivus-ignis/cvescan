require "zlib"

require "../vulnerabilities_decider"
require "../vulnerability"

class VulnerabilitiesDecider::Debsecan < VulnerabilitiesDecider

  @@feed_url = "https://security-tracker.debian.org/tracker/debsecan/release/1/GENERIC"

  @db : Hash(String, Array(Debsecan::DB::AffectedPackage))

  struct Debsecan::DB::CVE
    property id : String
    property description : String

    def initialize(@id, @description); end
  end

  struct Debsecan::DB::AffectedPackage
    property name : String
    property cve : Debsecan::DB::CVE
    property flags : Array(String) | Nil
    property fixed_backports_versions : Array(PackageVersion) | Nil
    property fixed_unstable_version : PackageVersion | Nil

    def initialize(@name, @cve); end
  end

  def initialize(pkgman)
    super

    feed = fetch_feed
    cve_records, package_records = dissect feed
    Utils.dputs("debsecan feed parsed: CVE records = #{cve_records.size}, package records = #{package_records.size}")

    @db = build_db(cve_records, package_records)
  end

  private def fetch_feed : Array(String)
    contents_compressed = Utils.get_remote_contents @@feed_url
    Utils.dputs "debsecan feed fetched"

    io = IO::Memory.new contents_compressed
    Zlib::Reader.open(io) { |zlib| zlib.gets_to_end }.split("\n")
  end

  # split debsecan feed into CVE and affected packages parts
  private def dissect(feed) : Tuple(Array(String), Array(String))
    # first line is "VERSION", so throwing it right away
    feed[1..-1].reject { |l| l.empty? }
      .partition { |l| l.starts_with?("CVE-") || l.starts_with?("TEMP-") }
  end

  private def build_db(cve_records : Array(String), package_records : Array(String)) : Hash(String, Array(Debsecan::DB::AffectedPackage))
    cves = cve_records.map do |rec|
      id, _, description = rec.split(",")

      Debsecan::DB::CVE.new(id: id, description: description)
    end

    packages = package_records.map do |rec|
      name, cve_idx, flags, fixed_unstable_version, fixed_backports_versions = rec.split(",")

      ap = Debsecan::DB::AffectedPackage.new(name: name, cve: cves[cve_idx.to_i])
      ap.flags = flags.split("") unless flags.empty?
      ap.fixed_unstable_version = PackageVersion.new(fixed_unstable_version) unless fixed_unstable_version.empty?
      ap.fixed_backports_versions = fixed_backports_versions.split(" ").map { |v| PackageVersion.new(v) } unless fixed_backports_versions.empty?

      ap
    end

    packages.group_by { |ap| ap.name }
  end

  private def maybe_vulnerable(pkg : Package, ap : Debsecan::DB::AffectedPackage) : (Vulnerability | Nil)
    vuln = Vulnerability.new(pkg, ap.cve.id, ap.cve.description)

    Utils.dputs("Checking package\n\t#{pkg}\n\tagainst #{ap}")

    unless ap.fixed_unstable_version.nil?
      return nil if pkg.source_package.version > ap.fixed_unstable_version.not_nil! ||
                    pkg.source_package.version == ap.fixed_unstable_version.not_nil!
    end

    Utils.dputs("fixed unstable version check failed")

    unless ap.fixed_backports_versions.nil?
      return nil if ap.fixed_backports_versions.not_nil!.includes?(pkg.source_package.version)
    end

    Utils.dputs("fixed backports versions check failed")

    vuln
  end

  private def find_vulnerabilities_for(pkg) : Array(Vulnerability)
    return [] of Vulnerability unless @db.has_key?(pkg.source_package.name)

    @db[pkg.source_package.name].reduce([] of Vulnerability) do |acc, rec|
      res = maybe_vulnerable(pkg, rec)
      acc << res unless res.nil?

      acc
    end
  end

  def report
    @package_manager.upgradable.reduce([] of Vulnerability) do |acc, pkg|
      find_vulnerabilities_for(pkg).each do |vuln|
        Utils.dputs "Vulnerability found: #{vuln}"
        acc << vuln
      end

      acc
    end
  end

end
