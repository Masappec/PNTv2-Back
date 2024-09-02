import time
from PIL import Image, ImageDraw, ImageFont
import random
import string
import uuid
from django.utils.text import slugify
import tempfile
from django.core.files import File
from django.core.files.base import ContentFile

import io


def random_string_generator(size=10, chars=string.ascii_lowercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))


def unique_slug_generator(instance, new_slug=None):
    if new_slug is not None:
        slug = new_slug
    else:
        count = instance.name.split()
        slug = ''
        if len(count) > 5:
            for i in instance.name.split():
                slug += i[0]
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


# Crear una instancia de Faker


def progress_bar(i, total):

    progress = i / total
    bar_length = 50
    bar = '[' + '#' * int(progress * bar_length) + '-' * \
        (bar_length - int(progress * bar_length)) + ']'
    return f'\r{bar} {progress * 100:.2f}% complete'


def generate_image_with_text(width, height, text):
    # Crear una imagen en blanco
    width, height = 200, 200

    new_image = Image.new('RGB', (width, height), color='white')

    # Dibuja algo en la imagen (por ejemplo, un círculo rojo)
    draw = ImageDraw.Draw(new_image)
    draw.ellipse((50, 50, 150, 150), fill='red')

    # Convierte la imagen en bytes
    with io.BytesIO() as buffer:
        new_image.save(buffer, format='JPEG')
        image_bytes = buffer.getvalue()

    # Nombre del archivo
    file_name = 'imagen.jpg'

    # Crea un objeto File de Django utilizando ContentFile
    django_file = ContentFile(image_bytes, name=file_name)

    return django_file
