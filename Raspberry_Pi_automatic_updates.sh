#!/bin/bash

# MIT License

# Copyright (c) 2019 Matthew David Miller

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This script is used to automatically update the Raspberry Pi when used in cron.

# Run the script as root

# Create a temporary Directory
mkdir -p /tmp/scripttemp

# Variable for words to search for when updating.
search_for_these_words="0 upgraded"


# File to search through.
file_to_search_for_words=/temp/scripttemp/temp.txt


/usr/bin/apt-get update && /usr/bin/rpi-update && /usr/bin/apt-get upgrade -y |& tee -a ${file_to_search_for_words}
grep -qi ${search_for_these_words} ${file_to_search_for_words}
if [ "$?" = "1" ] ; then
/usr/bin/apt-get autoremove --purge
/usr/bin/apt-get autoclean
rm -rf /tmp/scripttemp
/sbin/reboot
fi
