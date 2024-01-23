
from entity_app.ports.repositories.tag_repository import TagRepository

from entity_app.domain.models.publication import Tag

class TagImpl(TagRepository):
    
    
    def find_by_name(self, name: str):
        return Tag.objects.filter(name__icontains=name)
    
    def find_all(self):
        #retornar los ultimos 10
        return Tag.objects.all().last(10)
    
    
    def save(self, name: str):
        return Tag.objects.create(name=name)
    
    def delete(self, id:int):
        return Tag.objects.delete(id=id)
    
    
    