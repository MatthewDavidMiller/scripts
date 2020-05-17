# Copyright (c) Matthew David Miller. All rights reserved.

# Licensed under the MIT License.

# Run the script as root.

# Libraries to import.

import smtplib
import urllib.request
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import subprocess

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
