# docker-openairinterface-enb
Simple recipe to build and run a 4G SDR eNodeB from [OpenAirInterface project](https://gitlab.eurecom.fr/oai/openairinterface5g/wikis/home) develop code base. Kernel tweaks might be required on the host machine. A working EPC reachable from the host and a USRP is required in this particular config.

# Status : DEPRECATED

Nowadays I am using nextEPC. Check my project at : https://github.com/ravens/docker-nextepc

## Configure 

Edit enb.conf to reflect your IP and cellular network configuration.

Variables for cellular: 
>eNB_ID, eNB_name, tracking_area_code, mobile_country_code, mobile_network_code, eutra_band, downlink_frequency, uplink_frequency_offset, rx_gain, tx_gain

Variables for eNodeB IP config:
> ENB_IPV4_ADDRESS_FOR_S1_MME, ENB_IPV4_ADDRESS_FOR_S1U

Variables for 4G EPC:
> mme_ip_address

## Build

> docker-compose build --no-cache

## Run 

> docker-compose up 
