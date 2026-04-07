/*** my user.js overrides ***/
user_pref("network.dns.disableIPv6", false);
user_pref("keyword.enabled", true);
user_pref("browser.startup.homepage", "https://home.momo.nohost.me/");
user_pref("privacy.window.maxInnerWidth", 1920);
user_pref("privacy.window.maxInnerHeight", 1080);
/* 0102: set startup page [SETUP-CHROME]
 * 0=blank, 1=home, 2=last visited page, 3=resume previous session
 * [NOTE] Session Restore is cleared with history (2811), and not used in Private Browsing mode
 * [SETTING] General>Startup>Restore previous session ***/
user_pref("browser.startup.page", 3);
user_pref("privacy.clearOnShutdown.history", false);
