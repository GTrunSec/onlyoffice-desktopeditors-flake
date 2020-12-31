{
  inputs.nixpkgs.url = "nixpkgs/7ff5e241a2b96fff7912b7d793a06b4374bd846c";


  outputs = { self, nixpkgs }: {

    overlay = final: prev: {
      onlyoffice-desktopeditors = self.defaultPackage.x86_64-linux;
    };

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        pname = "onlyoffice-desktopeditors";
        version = "6.1.0";
        minor = "90";
        src = fetchurl {
          url = "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v${self.outputs.defaultPackage.x86_64-linux.version}/onlyoffice-desktopeditors_${self.outputs.defaultPackage.x86_64-linux.version}-${self.outputs.defaultPackage.x86_64-linux.minor}_amd64.deb";
          sha256 = "sha256-TUaECChM3GxtB54/zNIKjRIocnAxpBVK7XsX3z7aq8o=";
        };

        buildInputs = [
          gnome3.gsettings_desktop_schemas
          glib
          gtk3
          gtk2
          cairo
          atk
          gdk-pixbuf
          at-spi2-atk
          dbus
          dconf
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          qt5.qtbase
          qt5.qtdeclarative
          qt5.qtsvg
          xorg.libX11
          xorg.libxcb
          xorg.libXi
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXrandr
          xorg.libXcomposite
          xorg.libXext
          xorg.libXfixes
          xorg.libXrender
          xorg.libXtst
          xorg.libXScrnSaver
          nss
          nspr
          alsaLib
          fontconfig
          libpulseaudio
        ];

        nativeBuildInputs = [
          wrapGAppsHook
          autoPatchelfHook
          makeWrapper
          dpkg
        ];

        
        runtimeLibs = lib.makeLibraryPath [ libudev0-shim glibc curl pulseaudio ];

        unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

        preConfigure = ''
        cp ${./MacFSGB2312.ttf} opt/onlyoffice/desktopeditors/fonts/.
        cp ${./WeibeiSC-Bold.otf} opt/onlyoffice/desktopeditors/fonts/.
        '';
        installPhase = ''
        mkdir -p $out/share
        mkdir -p $out/{bin,lib}
        mv usr/share/* $out/share/
        mv opt/onlyoffice/desktopeditors $out/share

        ln -s $out/share/desktopeditors/DesktopEditors $out/bin/DesktopEditors

        wrapProgram $out/bin/DesktopEditors \
        --set QT_XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb \
        --set QTCOMPOSE ${xorg.libX11.out}/share/X11/locale

        substituteInPlace $out/share/applications/onlyoffice-desktopeditors.desktop \
          --replace "/usr/bin/onlyoffice-desktopeditor" "$out/bin/DesktopEditors"
          '';

        preFixup = ''
         gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "${self.outputs.defaultPackage.x86_64-linux.runtimeLibs}" )
         '';

        enableParallelBuilding = true;
      };

    checks.x86_64-linux.build = self.defaultPackage.x86_64-linux;

  };

}
