


from entity_app.ports.repositories.tag_repository import TagRepository


class TagService:
    
    
    def __init__(self, tag_repo: TagRepository):
        self.tag_repo = tag_repo
        
        
    def find_by_name(self, name: str):
        return self.tag_repo.find_by_name(name=name)
    
    
    def find_all(self):
        return self.tag_repo.find_all()
    
    
    def save(self, name: str):
        return self.tag_repo.save(name=name)
    
    def delete(self, id:int):
        return self.tag_repo.delete(id=id)