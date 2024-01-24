from entity_app.ports.repositories.publication_repository import PublicationRepository
from entity_app.domain.models import Publication, Tag, FilePublication
from entity_app.domain.models.establishment import UserEstablishmentExtended
from django.contrib.auth.models import User

from entity_app.domain.models.publication import TypePublication
class PublicationImpl(PublicationRepository):
    
    def inactivate_publication(self, publication_id: int):
        
       return Publication.objects.filter(id=publication_id).update(is_active=False)
        
        
    def get_publication(self, publication_id: int):
        
        publication = Publication.objects.get(id=publication_id)
        
        return publication
    
    
    def get_publications_transparency_active(self):
        
        publications = Publication.objects.filter(is_active=True).filter(type_publication__code='TA')
        
        return publications
    
    def get_publications(self):
        publications = Publication.objects.all()
        
        
    def get_publications_by_user_id(self, user_id: int):
        
        user = User.objects.get(id=user_id)
        if user.is_superuser:
            publications = Publication.objects.all()
            return publications
        
        establishment = UserEstablishmentExtended.objects.get(user_id=user_id)
        
        publications = Publication.objects.filter(establishment=establishment)
        
        return publications
    

    def get_publication_by_slug(self, slug: str):
        
        publication = Publication.objects.get(slug=slug)
        
        return publication
    
    def create_publication(self, publicacion: dict):

        tags_instancias = Tag.objects.filter(id__in=publicacion['group_dataset'])
        file_instancias = FilePublication.objects.filter(id__in=publicacion['file_publication'])
        
        type_publication = TypePublication.objects.get(code=publicacion['type_publication'])

        nueva_publicacion = Publication.objects.create(
            name=publicacion['name'],
            description=publicacion['description'],
            type_publication=type_publication,
            notes=publicacion['notes'],
            establishment_id = publicacion['establishment_id']
        )
        nueva_publicacion.tag.set(tags_instancias)
        nueva_publicacion.file_publication.set(file_instancias)

        nueva_publicacion.save()

    def update_publication(self, publication_id: int, publicacion: dict):

        tags_instancias = Tag.objects.filter(id__in=publicacion['group_dataset'])
        file_instancias = FilePublication.objects.filter(id_in=publicacion['file_publication'])

        publicacion = Publication.objects.filter(id=publication_id)
        publicacion.update(
            name=publicacion['name'],
            description=publicacion['description'],
            Tag=tags_instancias,
            FilePublication=file_instancias
        )

        return publicacion.first()