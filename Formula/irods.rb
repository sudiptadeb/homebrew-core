class Irods < Formula
  desc "Integrated data grid software solution"
  homepage "https://irods.org/"
  url "https://github.com/irods/irods-legacy/archive/3.3.1.tar.gz"
  sha256 "e34e7be8646317d5be1c84e680d8f59d50a223ea25a3c9717b6bf7b57df5b9f6"
  revision 1

  bottle do
    cellar :any
    sha256 "22a5e9bf24a034976491b65af9b36c4311afa16612f072655c556fba7285112b" => :sierra
    sha256 "510a0c5691702971c670c57c9ed11c5ca9371139b50c623cc950c0f8391a9737" => :el_capitan
    sha256 "490adc71118dc93c087aa685ddb873c3670575c679c834adc0a95c0b013772bc" => :yosemite
    sha256 "5d77816c581d12c4c30eb247e9b4a05f096347aa42ff4c069fa9aeff94678f87" => :mavericks
    sha256 "6b0aa76607c2fec9b0007a6ad4fdca8ab53e7615edc01e3dccd35facbea9bb39" => :mountain_lion
  end

  option "with-osxfuse", "Install iRODS FUSE client"

  depends_on :osxfuse => :optional
  depends_on "openssl"

  conflicts_with "sleuthkit", :because => "both install `ils`"
  conflicts_with "renameutils",
    :because => "both install `icp` and `imv` binaries"

  def install
    cd "iRODS" do
      system "./scripts/configure"

      # include PAM authentication by default
      inreplace "config/config.mk", "# PAM_AUTH = 1", "PAM_AUTH = 1"
      inreplace "config/config.mk", "# USE_SSL = 1", "USE_SSL = 1"

      system "make"
      bin.install Dir["clients/icommands/bin/*"].select { |f| File.executable? f }

      # patch in order to use osxfuse
      if build.with? "osxfuse"
        inreplace "config/config.mk" do |s|
          s.gsub! "# IRODS_FS = 1", "IRODS_FS = 1"
          s.gsub! "fuseHomeDir=/home/mwan/adil/fuse-2.7.0", "fuseHomeDir=#{HOMEBREW_PREFIX}"
        end
        inreplace "clients/fuse/Makefile" do |s|
          s.gsub! "lfuse", "losxfuse"
          s.gsub! "-I$(fuseHomeDir)/include", "-I$(fuseHomeDir)/include/osxfuse"
        end

        system "make", "-C", "clients/fuse"
        bin.install Dir["clients/fuse/bin/*"].select { |f| File.executable? f }
      end
    end
  end

  test do
    system "#{bin}/ipwd"
  end
end
