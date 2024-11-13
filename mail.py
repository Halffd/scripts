import requests
import random
import string
import time

def generate_random_email():
    """Generate a random email address."""
    random_string = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
    return f"{random_string}@tempmail.com"  # You can change the domain if needed

def check_inbox(email):
    """Check the inbox for the generated email."""
    username = email.split('@')[0]
    response = requests.get(f"https://api.temp-mail.org/request/mail/id/{username}")

    if response.status_code == 200:
        return response.json()
    else:
        print("Error fetching emails:", response.json())
        return []

def main():
    email = generate_random_email()
    print("Generated email:", email)

    # Wait a few seconds for any emails to arrive
    print("Waiting for incoming emails...")
    time.sleep(10)  # Adjust the wait time as necessary

    # Check for incoming emails
    emails = check_inbox(email)
    if emails:
        print("Incoming emails:")
        for email in emails:
            print(f"Subject: {email['subject']}, From: {email['from']}, Date: {email['date']}")
    else:
        print("No emails found.")

if __name__ == "__main__":
    main()