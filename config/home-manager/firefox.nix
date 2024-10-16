{
  config,
  ...
}:

{

  programs.firefox = {
    enable = true;
    package = null;
    profiles."${config.home.username}" = {
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.homepage" = "about:home";
        # telemetry & annoyances
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "browser.discovery.enabled" = false;
        "browser.uitour.enabled" = false;
        "browser.search.serpEventTelemetry.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "extensions.pocket.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;
        # Privacy / Tracking / RFP
        # "privacy.resistFingerprinting" = true;
        "privacy.resistFingerprinting.block_mozAddonManager" = true;
        "browser.display.use_system_colors" = false;
        "browser.contentblocking.category" = "strict";
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.places.speculativeConnect.enabled" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.clipboard" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.weather" = false;
        "browser.urlbar.suggest.yelp" = false;
        "browser.safebrowsing.allowOverride" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.blockedURIs.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.ml.enable" = false;
        "browser.ml.chat.enabled" = false;
        "dom.security.https_only_mode" = true;
        "geo.provider.use_gpsd" = false;
        "geo.provider.use_geoclue" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.pbmode.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;
        # Prefs
        "browser.formfill.enable" = false;
        "browser.tabs.searchclipboardfor.middleclick" = false;
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
      };
      search = {
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
