import os
import boto3
import email
import re
import json
import html
from datetime import datetime
from botocore.exceptions import ClientError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

ses_region = os.environ['SesRegion']
incoming_email_bucket = os.environ['MailS3Bucket']
incoming_email_prefix = os.environ['MailS3Prefix']
mail_sender = os.environ['MailSender']
mail_recipient = os.environ['MailRecipient']

client_s3 = boto3.client("s3")
client_ses = boto3.client('ses', ses_region)

def get_message_from_s3(mail):
    message_id = mail['messageId']

    if incoming_email_prefix:
        object_path = (incoming_email_prefix + "/" + message_id)
    else:
        object_path = message_id

    object_http_path = (f"https://s3.console.aws.amazon.com/s3/object/{incoming_email_bucket}/{object_path}")

    # Get the email object from the S3 bucket.
    object_s3 = client_s3.get_object(Bucket=incoming_email_bucket, Key=object_path)

    # Create presigned url for S3 object with one day expiration time
    expires_in_seconds = 86400
    now = datetime.now()
    presigned_url_expires_at = datetime.fromtimestamp(now.timestamp()+expires_in_seconds)
    presigned_url = create_presigned_url(incoming_email_bucket, object_path, expires_in_seconds)

    # Read the content of the message.
    file = object_s3['Body'].read()

    file_dict = {
        "file": file,
        "path": object_http_path,
        "presigned_url": presigned_url,
        "presigned_url_expires_at": presigned_url_expires_at.strftime("%d/%m/%Y, %H:%M:%S"),
    }

    return file_dict

def create_message(file_dict):
    separator = ", "

    # Parse the email body.
    eml_file = file_dict['file'].decode('utf-8')
    mailobject = email.message_from_string(eml_file)

    # Create a new subject line.
    subject_original = mailobject['Subject']
    subject = "FW: " + subject_original

    to_to = mailobject.get_all('To')
    to_cc = mailobject.get_all('Cc')
    to_bcc = mailobject.get_all('Bcc')
    to_all = []
    if to_to is not None:
        to_all += to_to
    if to_cc is not None:
        to_all += to_cc
    if to_bcc is not None:
        to_all += to_bcc

    # The body text of the email.
    body_text = ("<p>A message was received from: <b>"
              + html.escape(separator.join(mailobject.get_all('From')))
              + "</b></p><p>This message was sent to: <b> "
              + html.escape(separator.join(to_all))
              + "</b></p><p>This message is archived at: " + file_dict['path']
              + "</p><p>You can download this message using <a href=\"" + file_dict['presigned_url']
              + "\">this URL</a> until it expires (" + file_dict['presigned_url_expires_at'] + " UTC).</p>"
              )

    # Create a MIME container.
    msg = MIMEMultipart()
    # Create a MIME text part.
    text_part = MIMEText(body_text, _subtype="html")
    # Attach the text part to the MIME message.
    msg.attach(text_part)

    # Add subject, from and to lines.
    msg['Subject'] = subject
    msg['From'] = mail_sender
    msg['To'] = mail_recipient

    message = {
        "Source": mail_sender,
        "Destinations": mail_recipient,
        "Data": msg.as_string(),
        "OriginalEmail": mailobject,
    }

    return message

def send_email(message):
    # Send the email.
    try:
        #Provide the contents of the email.
        response = client_ses.send_raw_email(
            Source=message['Source'],
            Destinations=[
                message['Destinations']
            ],
            RawMessage={
                'Data':message['Data']
            }
        )

    # Display an error if something goes wrong.
    except ClientError as e:
        output = e.response['Error']['Message']
    else:
        output = "Email sent! Message ID: " + response['MessageId']

    return output

def forward_original_email(message):
    original_email = message['OriginalEmail']
    new_subject = "FW: " + original_email['Subject']
    del original_email['Subject']
    original_email['Subject'] = new_subject
    del original_email['From']
    original_email['From'] = message['Source']
    del original_email['Return-Path']
    del original_email['DKIM-Signature']
    del original_email['Status']
    message2 = message
    message2['Data'] = original_email.as_bytes()
    return send_email(message)

import logging
import boto3
from botocore.exceptions import ClientError


def create_presigned_url(bucket_name, object_name, expiration=3600):
    """Generate a presigned URL to share an S3 object

    :param bucket_name: string
    :param object_name: string
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Presigned URL as string. If error, returns None.
    """

    # Generate a presigned URL for the S3 object
    try:
        response = client_s3.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL
    return response

def lambda_handler(event, context):
    # Get the unique ID of the message. This corresponds to the name of the file in S3.
    print(json.dumps(event))
    mail = event['Records'][0]['ses']['mail']

    # Retrieve the file from the S3 bucket.
    file_dict = get_message_from_s3(mail)

    # Create the message.
    message = create_message(file_dict)

    # Send the email and print the result.
    result = send_email(message)
    print(result)

    # Forward the original email and print the result.
    result2 = forward_original_email(message)
    print(result2)
