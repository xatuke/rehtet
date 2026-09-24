# Homebrew formula. Publish in a tap (e.g. github.com/xatuke/homebrew-tap) and
# users install with:  brew install xatuke/tap/rehtet
class Rehtet < Formula
  desc "Share your Mac's Wi-Fi with an iPhone over a USB-C cable"
  homepage "https://github.com/xatuke/rehtet"
  url "https://github.com/xatuke/rehtet/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_THE_TARBALL"
  license "MIT"

  depends_on :macos
  depends_on "tinyproxy"

  def install
    bin.install "rehtet"
  end

  test do
    assert_match "rehtet", shell_output("#{bin}/rehtet --version")
  end
end
