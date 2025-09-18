from django.http import HttpRequest
from user_agents import parse

def get_client_ip(request):
    """
    Returns the client's IP address from the request object,
    handling the case where the request goes through a proxy.
    """
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0].strip()
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def get_browser_info(request: HttpRequest) -> dict:

    user_agent = request.META.get('HTTP_USER_AGENT', '')

    parsed_user_agent = parse(user_agent)

    browser = parsed_user_agent.browser.family
    version = parsed_user_agent.browser.version_string

    return {'browser': browser, 'version': version, 'agent':user_agent }