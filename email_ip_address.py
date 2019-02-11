# Run the script as root.

# Libraries to import.

import smtplib
import urllib.request
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Variables to edit

ip_address = urllib.request.urlopen("https://api.ipify.org").read().decode('utf-8')
email_ssl = smtplib.SMTP_SSL('smtp.gmail.com', 465)
email_address = 'matthew.miller.secondary@gmail.com'
email_address_to_send_to = 'matthewdavidmiller1@gmail.com'
email_subject = 'IP address of Raspberry Pi'
email_body = ip_address
email_password = 'Password'
full_email = MIMEMultipart()
full_email['From'] = email_address
full_email['To'] = email_address_to_send_to
full_email['Subject'] = email_subject
full_email.attach(MIMEText(email_body, 'plain'))
email = full_email.as_string()

# Prints date

date = subprocess.check_output(["date", "+'%m/%d/%Y %H:%M:%S'"])

print(date)

# Script to email ip address.

try:
    email_ssl.login(email_address, email_password)
    email_ssl.sendmail(email_address, email_address_to_send_to, email)
    email_ssl.close()

    print('Email successfully sent.')
except:
    print('Error detected.')


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
