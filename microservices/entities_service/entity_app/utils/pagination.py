from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination

class LargeResultsSetPagination(PageNumberPagination):
    page_size = 1000
    page_size_query_param = 'page_size'
    max_page_size = 10000

class StandardResultsSetPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'limit'
    max_page_size = 1000
    
    
    def get_paginated_response(self, data):
        return Response({
            'total': self.page.paginator.object_list.count() if self.page.paginator.object_list else 0,
            'limit': self.page.paginator.per_page,
            'results': data,
            'current': self.page.number,
            'next': self.page.next_page_number() if self.page.has_next() else None,
            'previous': self.page.previous_page_number() if self.page.has_previous() else None,
            'total_pages': self.page.paginator.num_pages,
            'from' : self.page.start_index(),
            'to' : self.page.end_index(),
        })
        

class StandardResultsSetPaginationDicts(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'limit'
    max_page_size = 1000

    def get_paginated_response(self, data):
        return Response({
            'total': self.page.paginator.count if self.page.paginator else 0,
            'limit': self.page.paginator.per_page,
            'results': data,
            'current': self.page.number,
            'next': self.get_next_link(),
            'previous': self.get_previous_link(),
            'total_pages': self.page.paginator.num_pages,
            'from': self.page.start_index(),
            'to': self.page.end_index(),
        })
