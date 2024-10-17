{
  config,
  pkgs,
  lib,
  ...
}:

let
  catppuccin_pink = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "catppuccin-machiato-pink";
    version = "2022-08-11";
    name = "${pname}-${version}";
    src = pkgs.fetchurl {
      url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_macchiato_pink.xpi";
      sha512 = "2vkx0ss560jmqwhd955l0yaiphaqmp1r5mvnb6aw37nrz20py77l7vl18r3csi2kms23s64vny66p6prsjwlfsscj0pv8wb6dq8aahw";
    };
    dontUnpack = true;
    passthru.addonId = "{e554e180-24a4-40a2-911d-bf48d5b1629c}";
    installPhase = ''
      dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
      mkdir -p "$dst"
      install -v -m644 "$src" "$dst/${passthru.addonId}.xpi"
    '';
  };
in
{

  programs.firefox = {
    enable = true;
    package = null;
    profiles."${config.home.username}" = {
      isDefault = true;
      settings = {
        "app.normandy.api_url" = "";
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.update.auto" = false;
        "beacon.enabled" = false;
        "breakpad.reportURL" = "";
        "browser.aboutConfig.showWarning" = false;
        "browser.contentblocking.category" = "strict";
        "browser.crashReports.unsubmittedCheck.autoSubmit" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.display.use_system_colors" = false;
        "browser.formfill.enable" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.enable" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.preload" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.safebrowsing.allowOverride" = false;
        "browser.safebrowsing.blockedURIs.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.search.serpEventTelemetry.enabled" = false;
        "browser.send_pings" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:home";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.tabs.searchclipboardfor.middleclick" = false;
        "browser.uitour.enabled" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.suggest.clipboard" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.weather" = false;
        "browser.urlbar.suggest.yelp" = false;
        "browser.urlbar.quicksuggest.enable" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "device.sensors.ambientLight.enabled" = false;
        "device.sensors.enabled" = false;
        "device.sensors.motion.enabled" = false;
        "device.sensors.orientation.enabled" = false;
        "device.sensors.proximity.enabled" = false;
        "dom.battery.enabled" = false;
        "dom.event.clipboardevents.enabled" = false;
        "dom.private-attribution.submission.enabled" = false;
        "dom.security.https_only_mode" = true;
        "extensions.pocket.enabled" = false;
        "geo.enabled" = false;
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.dns.disablePrefetch" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;
        "privacy.globalprivacycontrol.pbmode.enabled" = true;
        "privacy.resistFingerprinting.block_mozAddonManager" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.rememberSignons" = false;
        "toolkit.coverage.endpoint.base" = "";
        "toolkit.coverage.opt-out" = true;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "webgl.renderer-string-override" = " ";
        "webgl.vendor-string-override" = " ";
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # "privacy.resistFingerprinting" = true;
      };
      extensions = [
        catppuccin_pink
      ];
      search = {
        force = true;
        engines = {
          "Brave" = {
            "_name" = "Brave";
            "_loadPath" = "[https]cdn.search.brave.com/brave.xml";
            "description" = "Brave Search: private, independent, open";
            "_iconURL" = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAnFBMVEVHcEwXBgA3DQl/HBF5HBLeMCmwKBLXMyC6KQ3dMBLbMxjuOijgLgviKwHwOiryOyXwMAv5PST0LwnuLQD7QiXwLQD1LQD7LwjxNQr4Myf5OR/yPxf4OS3/Pyb/QivxTCj+SjD/VT7xXT35alL6d2L8iHb4loX5o5f7sKX0w73/zMb00s//1M754uH76+z18PT39ff/9fT8+vz///96nB6rAAAAFXRSTlMAAw0ZJDRIWGV2kKSuwcLT1e3v+/wkomRQAAABoklEQVR42nWT2WKCMBBFi6DgUpUlasUgCGGPIPz/v3WSkECV3hce7snMnUz4mkhT+pqVfnQGHfVZ/3BVOizeTG1pGvvbRPuludQm/vZ2+/nQVhv9IMDX6xmEk8Rj3ytyXXcniTX4OHq+6rzsurYpsuJJ7wi0HoAVAEHdcwHAVV0AWA3Awg5w1r9oTQVQFRVtMoQcOYsZBHHflyTEUd61+R1d4qJpHgiZKqNo8Moj0rXEzyhvgtBOU0ApEuSsQipSFAxQLSLKgaTu2uouUvoIWUMGA6bgRIlfEPKSg8/mdA05xYHfQ9+T8Nm11I+Fj45yCm0DAI4hZYqj8JRQNgJoo+7aZEDUsyaRxxo0/CLNcdMeACmPmREeMQXf1cdt7iWQ43Mqge/JvjcAhHVPSUiIHxcwo4wg14UDIOIwgzGfqf+4ILkqtS4MCoZlUfDVqsYQbJCSAQXUHyPIN4OFsq7NTuCOr0Xetj0QhJwE4Bh/n7XlDcRZAK6lvT38lT0FnJX0x9/O2I3Azpj7+xaWLQDH4hN+CoowQB2fL6KO/1NE19+O/wIwPEoAZi8ATQAAAABJRU5ErkJggg==";
            "_metaData" = {
              "loadPathHash" = "QW/qQQujPdnvphfd6AMNKPvjsYB2iFzg7yqtBIL1zd8=";
            };
            "_urls" = [
              {
                "params" = [ ];
                "rels" = [ ];
                "template" = "https://search.brave.com/search?q={searchTerms}";
              }
              {
                "params" = [ ];
                "rels" = [ ];
                "template" = "https://search.brave.com/api/suggest?q={searchTerms}";
                "type" = "application/x-suggestions+json";
              }
            ];
          };
        };
        default = "Brave";
        order = [
          "Brave"
        ];
      };
    };
  };
}
