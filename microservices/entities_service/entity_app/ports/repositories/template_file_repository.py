from abc import ABC, abstractmethod
from django.core.files.uploadedfile import UploadedFile


class TemplateFileRepository(ABC):

    def get_all(self):
        pass

    def get(self, id):
        pass

    def get_by_numeral(self, numeral_id):
        pass

    # request.files.get('file')
    def validate_file(self, template_id, file: UploadedFile):
        pass
