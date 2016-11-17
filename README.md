# docker-openairinterface-enb
Recipe to build and run a 4G SDR eNodeB from [OpenAirInterface project](https://gitlab.eurecom.fr/oai/openairinterface5g/wikis/home) develop code base. Kernel tweaks might be required on the host machine.

## Configure 

Edit enb.conf to reflect your IP and cellular network configuration.

Variables for cellular: 
>eNB_ID, eNB_name, tracking_area_code, mobile_country_code, mobile_network_code, eutra_band, downlink_frequency, uplink_frequency_offset, rx_gain, tx_gain

Variables for eNodeB IP config:
> ENB_IPV4_ADDRESS_FOR_S1_MME, ENB_IPV4_ADDRESS_FOR_S1U

Variables for 4G EPC:
> mme_ip_address

## Build

> docker build -t openair4g .

## Run 

> docker run --net=host --rm --privileged -v /dev/bus/usb:/dev/bus/usb -it openair4g