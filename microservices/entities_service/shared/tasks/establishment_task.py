from entity_app.domain.services.numeral_service import NumeralService
from entity_app.adapters.impl.numeral_impl import NumeralImpl
from entities_service.celery import app


def establishment_created_event(numerals_id: list, establishment_id: int):
    service = NumeralService(numeral_repository=NumeralImpl())
    # eliminar los valores '' de la lista numerals_id
    try:

        numerals = service.get_by_entity(establishment_id).filter(default=True)
        if not numerals.exists():
            defaults_numerals = service.get_by_default(True)

            service.asign_numeral_to_establishment(
                defaults_numerals, establishment_id)
        return {
            'type': 'establishment_created',
            'payload': {
                'numerals_id' : numerals_id,
                'establishment_id': establishment_id
            },
        }
    except Exception as e:
        print(e)
        pass
    
    
    try:
        if numerals_id:
            list_numeral = service.filter_by_list_ids(numerals_id)
            service.asign_numeral_to_establishment(list_numeral, establishment_id)
            
    except Exception as e:
        print(e)
        pass
        
    