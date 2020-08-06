#!/bin/sh

/bin/cat > /tmp/wizard.php <<'EOF'
<?php
$filename = "/var/packages/virtualbox4dsm/target/etc/vbox4dsm.config";
if (file_exists($filename)) {
	$ini_array = parse_ini_file($filename);
} else {
    $ini_array = array (
		"wizard_on_stop_poweroff" => "false",
		"wizard_on_stop_acpibutton" => "true",
		"wizard_on_stop_savestate" => "false",
		"wizard_virtualbox_share" => "virtualbox",
		"wizard_bind_ip" => "0.0.0.0",
		"wizard_use_https" => "false",
		"wizard_use_vboxwebsvc_pass" => "B24Lq3OfG24S",
		"wizard_enable_wol" => "false",
	);
}

# page1
$wizard_on_stop_poweroff=$ini_array["wizard_on_stop_poweroff"];
$wizard_on_stop_acpibutton=$ini_array["wizard_on_stop_acpibutton"];
$wizard_on_stop_savestate=$ini_array["wizard_on_stop_savestate"];
$wizard_virtualbox_share=$ini_array["wizard_virtualbox_share"];

# page2
$wizard_bind_ip=$ini_array["wizard_bind_ip"];
$wizard_use_https=$ini_array["wizard_use_https"];
$wizard_use_vboxwebsvc_pass=$ini_array["wizard_use_vboxwebsvc_pass"];
$wizard_enable_wol=$ini_array["wizard_enable_wol"];

# page1 defaults
if (empty($wizard_on_stop_poweroff)) $wizard_on_stop_poweroff = "false";
if (empty($wizard_on_stop_acpibutton)) $wizard_on_stop_acpibutton = "true";
if (empty($wizard_on_stop_savestate)) $wizard_on_stop_savestate = "false";
if (empty($wizard_virtualbox_share)) $wizard_virtualbox_share = "virtualbox";

# page2 defaults
if (empty($wizard_bind_ip)) $wizard_bind_ip = "0.0.0.0";
if (empty($wizard_use_https)) $wizard_use_https = "false";
if (empty($wizard_use_vboxwebsvc_pass)) $wizard_use_vboxwebsvc_pass = "B24Lq3OfG24S";
if (empty($wizard_enable_wol)) $wizard_enable_wol = "false";

echo  <<<EOF
[{
		"step_title": "VirtualBox configuration (page 1 of 2)",
		"items": [{
				"type": "singleselect",
				"desc": "On DSM shutdown what to do with running Guest VM?",
				"subitems": [{
						"key": "wizard_on_stop_poweroff",
						"desc": "poweroff",
						"defaultValue": $wizard_on_stop_poweroff 
					}, {
						"key": "wizard_on_stop_acpibutton",
						"desc": "acpibutton",
						"defaultValue": $wizard_on_stop_acpibutton 
					}, {
						"key": "wizard_on_stop_savestate",
						"desc": "savestate",
						"defaultValue": $wizard_on_stop_savestate
					}
				]
			}, {
				"type": "textfield",
				"desc": "Shared folder for VirtualBox VMs (e.g. virtualbox) will be created on first live volume.",
				"subitems": [{
						"key": "wizard_virtualbox_share",
						"desc": "Shared folder",
						"defaultValue": "$wizard_virtualbox_share"
					}
				]
			}
		]
	}, {
		"step_title": "VirtualBox configuration (page 2 of 2)",
		"items": [{
				"type": "textfield",
				"desc": "Vboxwebsrv SOAP service bind IP (not phpVirtualBox's URL)",
				"subitems": [{
						"key": "wizard_bind_ip",
						"desc": "Bind to IP",
						"defaultValue": "$wizard_bind_ip"
					}
				]
			}, {
				"type": "multiselect",
				"desc": "Should vboxwebsrv use HTTPS protocol (useful if bind IP is not 127.0.0.1).",
				"subitems": [{
						"key": "wizard_use_https",
						"desc": "Use HTTPS",
						"defaultValue": $wizard_use_https
					}
				]
			}, {
				"type": "textfield",
				"desc": "Authentication password for vboxwebsrv , used if bind IP is not 127.0.0.1",
				"subitems": [{
						"key": "wizard_use_vboxwebsvc_pass",
						"desc": "vboxwebsvc password",
						"defaultValue": "$wizard_use_vboxwebsvc_pass"
					}
				]
			}, {
				"type": "multiselect",
				"desc": "Enable WOL for guest VM's, you will be able to wake VM by sending standard magic packet to port 9 and VM's MAC address",
				"subitems": [{
						"key": "wizard_enable_wol",
						"desc": "Enable WOL for VM",
						"defaultValue": $wizard_enable_wol
					}
				]
			}
		]
	}
]
EOF;
?>
EOF

/usr/bin/php -n /tmp/wizard.php > "$SYNOPKG_TEMP_LOGFILE"
rm /tmp/wizard.php
exit 0
