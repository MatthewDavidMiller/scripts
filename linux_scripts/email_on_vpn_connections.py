# Copyright (c) 2019 Matthew David Miller. All rights reserved.
# Licensed under the MIT License.

# Libraries to import.
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Variables to edit
email_ssl = smtplib.SMTP_SSL('smtp.gmail.com', 465)
email_address = 'matthewdavidmiller1@gmail.com'
email_address_to_send_to = 'matthewdavidmiller1@gmail.com'
email_subject = 'Connection established on VPN server'
email_body = 'A VPN connection has been established on the VPN server.'
email_password = 'Password'
full_email = MIMEMultipart()
full_email['From'] = email_address
full_email['To'] = email_address_to_send_to
full_email['Subject'] = email_subject
full_email.attach(MIMEText(email_body, 'plain'))
email = full_email.as_string()

# Script to email admin on VPN connection.
email_ssl.login(email_address, email_password)
email_ssl.sendmail(email_address, email_address_to_send_to, email)
email_ssl.close()