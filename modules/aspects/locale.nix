{ ... }:
{
  flake.modules.nixos.locale = {
    i18n.defaultLocale = "en_US.UTF-8";
    # TODO: time.timeZone
  };
}
