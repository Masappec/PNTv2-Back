from abc import ABC, abstractmethod


class FilePublicationRepository(ABC):

    @abstractmethod
    def save(self, name, description, file):
        pass

    @abstractmethod
    def update(self, file_publication_id, name, description, file):
        pass

    @abstractmethod
    def get(self, file_publication_id):
        pass

    @abstractmethod
    def get_all(self):
        pass

    @abstractmethod
    def delete(self, file_publication_id):
        pass

    @abstractmethod
    def get_by_user_establishment(self, user_establishment_id):
        pass

    @abstractmethod
    def get_files_from_transparency_active(self, user_id):
        pass

    @abstractmethod
    def get_files_from_transparency_collaborative(self, user_id):
        pass

    @abstractmethod
    def get_files_from_transparency_focus(self, user_id):
        pass
