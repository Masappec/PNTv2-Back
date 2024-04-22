import random
import string
import uuid
from django.utils.text import slugify
from typing import List
import csv


def get_day_for_publish():
    return 5


def random_string_generator(size=10, chars=string.ascii_lowercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))


def unique_slug_generator(instance, new_slug=None):
    if new_slug is not None:
        slug = new_slug
    else:
        slug = slugify(instance.name)
    Klass = instance.__class__
    max_length = Klass._meta.get_field('slug').max_length
    slug = slug[:max_length]
    qs_exists = Klass.objects.filter(slug=slug).exists()

    if qs_exists:
        new_slug = "{slug}-{randstr}".format(
            slug=slug[:max_length-5], randstr=random_string_generator(size=4))

        return unique_slug_generator(instance, new_slug=new_slug)

    return slug


def unique_code_generator(instance, new_slug=None):
    if new_slug is not None:
        slug = new_slug
    else:
        slug = slugify(instance.name)
    Klass = instance.__class__
    max_length = Klass._meta.get_field('code').max_length
    slug = slug[:max_length]
    qs_exists = Klass.objects.filter(code=slug).exists()

    if qs_exists:
        new_slug = "{slug}-{randstr}".format(
            slug=slug[:max_length-5], randstr=random_string_generator(size=4)
        )

        return unique_code_generator(instance, new_slug=new_slug)

    return slug


def validate_type(type_obj, type_for_valid):
    types = {
        'string': ['str'],
        'number': ['int', 'float'],
        'date': ['str', 'datetime'],
        'file': ['str', 'file'],
        'decimal': ['float']
    }

    if types[type_for_valid] == type_obj:
        return True

    return False


def progress_bar(i, total):

    progress = i / total
    bar_length = 50
    bar = '[' + '#' * int(progress * bar_length) + '-' * \
        (bar_length - int(progress * bar_length)) + ']'
    return f'\r{bar} {progress * 100:.2f}% complete'
