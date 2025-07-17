import re
from datetime import datetime

import markdown
from django import template
from django.contrib.auth import get_user_model
from django.db.models import Count
from django.utils import timezone
from django.utils.formats import date_format
from django.utils.safestring import mark_safe

from ..models import Post

register = template.Library()


@register.simple_tag
def total_posts():
    return Post.published.count()


@register.simple_tag(takes_context=True)
def current_date(context, format_string=None):
    """
    Returns the current date formatted according to the system locale.
    If format_string is given, it will override system format.
    """
    request = context.get("request")
    now = timezone.now()

    if format_string:
        return date_format(now, format_string)

    # Auto format based on locale and settings (USE_L10N, LANGUAGE_CODE)
    return date_format(now, use_l10n=True)


@register.inclusion_tag("blog/post/latest_posts.html")
def show_latest_posts(count=5):
    latest_posts = Post.published.order_by("-publish")[:count]
    return {"latest_posts": latest_posts}


@register.simple_tag
def get_most_commented_posts(count=5):
    return Post.published.annotate(total_comments=Count("comments")).order_by(
        "-total_comments"
    )[:count]


@register.filter(name="markdown")
def markdown_format(text):
    return mark_safe(markdown.markdown(text))


@register.filter
def first_two_sentences(value):
    # This regex splits text by sentence-ending punctuation.
    sentences = re.split(r"(?<=[.!?])\s+", value.strip())
    return " ".join(sentences[:5])


User = get_user_model()


@register.simple_tag
def count_superusers():
    return User.objects.filter(is_superuser=True).count()


@register.simple_tag
def current_year():
    return datetime.now().year
