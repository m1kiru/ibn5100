{ ... }:
{
  services.lact.enable = true;

  environment.etc."lact/config.yaml" = {
    text = ''
      version: 7
      daemon:
        log_level: info
        admin_group: wheel
        disable_clocks_cleanup: false
      apply_settings_timer: 5
      gpus:
        10DE:1B81-1462:3301-0000:05:00.0:
          fan_control_enabled: true
          fan_control_settings:
            mode: curve
            static_speed: 0.5
            temperature_key: edge
            interval_ms: 500
            curve:
              40: 0.5
              50: 0.6
              60: 0.7
              70: 0.8
              80: 1.0
            spindown_delay_ms: 5000
            change_threshold: 2
          power_cap: 200.0
      current_profile: null
      auto_switch_profiles: false
    '';
    mode = "0644";
  };
}
