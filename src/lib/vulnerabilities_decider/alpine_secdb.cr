require "yaml"

require "../vulnerabilities_decider"
require "../vulnerability"

class VulnerabilitiesDecider::AlpineSecDb < VulnerabilitiesDecider

  @@secdb_baseurl = "https://raw.githubusercontent.com/alpinelinux/alpine-secdb/master"

  @db : Hash(String, Hash(String, Array(String)))

  def initialize(pkgman, release)
    super(pkgman)

    release_major_minor = release.split(".")[0..1].join(".")
    repositories = [ "main", "community" ]

    feed_urls = repositories.map { |r| "#{@@secdb_baseurl}/v#{release_major_minor}/#{r}.yaml" }

    # {"ansible" => {"2.4.6.0-r0" => ["CVE-2018-10855"]},
    # "apache2" =>
    #  {"2.4.35-r0" => ["CVE-2018-11763"],
    #   "2.4.34-r0" => ["CVE-2018-1333", "CVE-2018-8011"],
    #   "2.4.33-r0" =>
    #    ["CVE-2017-15710", ...
    @db = feed_urls
          .map { |feed| fetch_feed feed }
          .map { |contents| YAML.parse(contents)["packages"] }
          .reduce([] of YAML::Any) do |acc, feed|
            feed.as_a.each { |pkg| acc << pkg }
            acc
          end
          .reduce({} of String => Hash(String, Array(String))) do |acc, pkg|
            pkg_name = pkg["pkg"]["name"].as_s
            pkg_secfixes = pkg["pkg"]["secfixes"].as_h
                           .transform_keys { |k| k.as_s }
                           .transform_values { |v| v.as_a.map { |i| i.as_s } }
            acc[pkg_name] = pkg_secfixes
            acc
         end
  end

  private def fetch_feed(url)
    Utils.get_remote_contents(url)
  end

  def report
    [] of Vulnerability
  end

end
