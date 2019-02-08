require "../distro"
require "../package_manager/*"

class Distro::Centos < Distro

  def initialize
    super

    @package_managers << PackageManager::Rpm.new
  end

  def name
    "centos"
  end

  def release
    File.read("/etc/redhat-release").chomp
  end

end
