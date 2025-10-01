import os
import requests
from django.conf import settings
from django.utils.text import slugify

def get_or_download_logo(domain: str) -> str:
    """
    Given a domain, check if the logo exists in MEDIA_ROOT/logos/.
    If not, download it from Clearbit and save it.
    Returns the relative media URL (e.g., /media/logos/github-com.png).
    """
    if not domain:
        return ""

    filename = f"{slugify(domain)}.png"
    logo_dir = os.path.join(settings.MEDIA_ROOT, 'logos')
    filepath = os.path.join(logo_dir, filename)
    media_url = f"{settings.MEDIA_URL}logos/{filename}"

    # Make sure the logos directory exists
    os.makedirs(logo_dir, exist_ok=True)

    # If file doesn't exist, fetch and save
    if not os.path.exists(filepath):
        clearbit_url = f"https://logo.clearbit.com/{domain}"
        print("getting from clearbit")
        try:
            response = requests.get(clearbit_url, timeout=5)
            response.raise_for_status()
            with open(filepath, 'wb') as f:
                f.write(response.content)
        except requests.RequestException:
            # If fetching fails, return empty string or default image URL
            return ""

    return media_url
