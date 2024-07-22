import secrets
import string

def generate_firestore_id(length=20):
    base62_chars = string.ascii_letters + string.digits  # a-z, A-Z, 0-9
    return ''.join(secrets.choice(base62_chars) for _ in range(length))
