# Qui-Vive

  TODO: Description.


## Notes

   Required for use:
   - bash (look grep cut awk sort)
   - curl
   - xsltproc


   Tested under:
   - MacOS 10.14
   - Debian GNU/Linux 9 (stretch)


## Installation

   `git clone https://github.com/lkremkow/qui-vive.git qui-vive`

   `cd qui-vive`

   Edit the `settings.sh` file to give your username, password, and select your Qualys API address.

   Edit `monitor_traffic.sh` and replace X.X.X.X with the IP of the monitoring systems itself


## Usage

   Fetch the Qualys vulnerability detection data for your perimeter:

   `bash fetch_host_detections.sh`

   Fetch list of know hostile IP addresses:

   `bash fetch_known_hostile_hosts_list.sh`

   Begin monitoring your network:

   `monitor_traffic.sh`

   TODO: Complete how to use these scripts (configure ElasticSearch and Kibana).


## Contributing

   TODO: Write instructions how to report bugs and contribute.

   Please see https://github.com/lkremkow/qui-vive.git


## History

   TODO: Write history.


## Credits

   TODO: Write credits.


## License

   Copyright (C) 2018 Leif Kremkow <kremkow@tftg.net> (http://www.tftg.com)

   This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3 of the License.

   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
