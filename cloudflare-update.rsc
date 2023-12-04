# Updates IP from cloudflare and puts them to address-list "cloudflare" with 1 day timeout

:local result ([/tool fetch mode=https output=user url="https://www.cloudflare.com/ips-v4/" as-value ])
:if ($result->"status" = "finished") do={
	:local n 0
	:local a 0
	:local recoded
	:for i from=0 to=([:len ($result->"data")] - 1) do={ 
		:local char [:pick ($result->"data") $i]
		:if ($char = "\n") do={:set $char ","}
		:set recoded ($recoded . $char) 
	}        
	:local iplist [:toarray $recoded]
	:foreach ip in=$iplist do={ 
		:do {
			/ip firewall address-list add list=cloudflare address=$ip timeout=86400
			:put "$ip inserted"
			:set n ($n + 1)
			:set a ($a + 1)
		} on-error={
			:foreach elem in=[/ip firewall address-list find list="cloudflare" address=$ip] do={
				/ip firewall address-list set $elem timeout=86400
				:put "$ip updated"
				:set a ($a + 1)
			}
		};
	};
	:log info "cloudflare-update: $a processed ($n new)"
}
