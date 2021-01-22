let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/257cbbcd3ab7bd96f5d24d50adc807de7c82e06d.tar.gz";
    sha256 = "sha256-hCsGe2nDz+SX4uO+lj0qPVcSGZdt52R9Yk5MOYs4djw=";
  };
in
{ pkgs ? import nixpkgs {
  config.android_sdk.accept_license = true;
}}:

let
  buildToolsVersion = "28.0.3";
  android = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "27" "28" "29" ];
    abiVersions = ["armeabi-v7a" "arm64-v8a"]; 
    buildToolsVersions = [buildToolsVersion];
    useGoogleAPIs = true;
  };
  jdk = pkgs.jdk8;
  JAVA_HOME = "${jdk.home}";
  sdk = android.androidsdk.overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      mkdir -p "$out/libexec/android-sdk/licenses"
      function lic {
        echo -e "\n$2" >> "$out/libexec/android-sdk/licenses/$1"
      }
      lic android-googletv-license 601085b94cd77f0b54ff86406957099ebe79c4d6
      lic android-sdk-arm-dbt-license 859f317696f67ef3d7f30a50a5560e7834b43903
      lic android-sdk-license 8933bad161af4178b1185d1a37fbf41ea5269c55
      lic android-sdk-license 24333f8a63b6825ea9c5514f83c2829b004d1fee
      lic android-sdk-preview-license 84831b9409646a918e30573bab4c9c91346d8abd
      lic google-gdk-license 33b6a2b64607f11b759f320ef9dff4ae5c47d97a
      lic mips-android-sysimage-license e9acab5b5fbb560a72cfaecce8946896ff6aab9d
    '';
  });
  ANDROID_HOME = "${sdk}/libexec/android-sdk";
in
pkgs.mkShell {
  shellHook = ''
    echo ${sdk}
    flutter packages get
    flutter packages run flutter_launcher_icons:main
  '';
  buildInputs = with pkgs; [
    sdk
    glibc
    flutter
    jre
    dart
  ];
  # override the aapt2 that gradle uses with the nix-shipped version
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
  inherit ANDROID_HOME;
}
