require "../distro"
require "../package_manager/*"

class Distro::Ubuntu < Distro

  def initialize
    super

    @package_managers << PackageManager::Dpkg.new
  end

  def name
    "ubuntu"
  end

  def release
    lsb = File.read_lines("/etc/lsb-release")
          .reduce({} of String => String) { |acc, x| k, v = x.split("="); acc[k] = v; acc }
    lsb["DISTRIB_RELEASE"]
  end

end
