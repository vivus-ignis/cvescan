require "./package_manager"
require "./vulnerabilities_decider_generator"

abstract class Distro

  # getter name : String
  # getter release : String
  @package_managers : Array(PackageManager)

  def initialize
  #   @name = name
  #   @release = release

  #   Utils.dputs "Distro.new"
    @package_managers = [] of PackageManager
  #   # @package_managers << PackageManager::Gem.new if has_binary? "gem"
  #   # @package_managers << PackageManager::Npm.new if has_binary? "npm"
  #   # @package_managers << PackageManager::Pip.new if has_binary? "pip"
  #   # @package_managers << PackageManager::Conda.new if has_binary? "conda"
  #   Utils.dputs "package_managers initialized"
  end

  abstract def name : String

  abstract def release : String

  def has_binary?(filename)
    Process.find_executable(filename).nil?
  end

  def vulnerabilities
    deciders = @package_managers.map do |pkgman|
      VulnerabilitiesDeciderGenerator.for distro: self,
                                          package_manager: pkgman
    end

    deciders.map { |decider| decider.report }
  end

end
