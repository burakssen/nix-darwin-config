cask "quitme" do
    version "1.1.1"
    sha256 "d9da815627e6add4658ce162b7eb85d797895b34749a0100f926cac3096cc36f" # Replace with the SHA256 checksum of the zip file

    url "https://github.com/burakssen/QuitMe/releases/download/v1.1.1/QuitMe.app.zip"
    name "QuitMe"
    desc "A brief description of QuitMe"
    homepage "https://github.com/burakssen/QuitMe"

    app "QuitMe.app" 

    uninstall quit: "com.burakssen.QuitMe"
    zap trash: [
      "~/Library/Application Support/QuitMe",
      "~/Library/Preferences/com.burakssen.QuitMe.plist",
    ]
end
  