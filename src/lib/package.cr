require "./package_version"

class Package

  struct SourcePackage

    getter name : String
    getter version : PackageVersion

    def initialize(name, version)
      @name = name
      @version = PackageVersion.new version
    end

  end

  getter name : String
  getter version : PackageVersion
  getter source_package : Package::SourcePackage

  # if there is no source package, my source package should equal to myself
  def initialize(name, version, source_package = nil)
    @name = name
    @version = PackageVersion.new version

    @source_package = source_package.nil? ? Package::SourcePackage.new(name, version) : source_package
  end

  def to_s(io)
    io.print "#{@name} (#{@version}) source package: #{@source_package}"
  end

end
