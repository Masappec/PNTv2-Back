from entity_app.ports.repositories.file_publication_repository import FilePublicationRepository
from entity_app.domain.models.publication import FilePublication
from entity_app.domain.models.establishment import EstablishmentExtended,UserEstablishmentExtended
from django.apps import apps
from django.contrib.auth.models import User

class FilePublicationImpl(FilePublicationRepository):
    
    
    def save(self, name, description, file):
        return FilePublication.objects.create(name=name, description=description, url_download=file)
    
    
    def get(self, file_publication_id):
        return FilePublication.objects.get(id=file_publication_id)
    
    
    def update(self, file_publication_id, name, description, file):
        file_publication = FilePublication.objects.get(id=file_publication_id)
        file_publication.name = name
        file_publication.description = description
        file_publication.url_download = file
        file_publication.save()
        return file_publication
    def get_all(self):
        return FilePublication.objects.all()
    
    def delete(self, file_publication_id):
        return FilePublication.objects.get(id=file_publication_id).delete()
    
    
    def get_by_user_establishment(self, user_id):
        
        user = User.objects.get(id=user_id)
        
        if user.is_superuser:
            return FilePublication.objects.all()
        
        user_establishment = UserEstablishmentExtended.objects.get(user_id=user_id)
        
        return FilePublication.objects.filter(
            publication__file_publication__userestablishment=user_establishment
        ).distinct()
        
    