/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=private]
/ipv6 firewall address-list
:local ipList {
    "::/127";
    "fc00::/7";
    "fe80::/10";
    "ff00::/8";
}
:foreach ip in=$ipList do={
    /ipv6 firewall address-list add address=$ip list=private timeout=0
}
