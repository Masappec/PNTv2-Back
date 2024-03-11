from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination


class LargeResultsSetPagination(PageNumberPagination):
    page_size = 1000
    page_size_query_param = 'page_size'
    max_page_size = 10000


class StandardResultsSetPagination(PageNumberPagination):
    page_size = 5
    page_size_query_param = 'limit'
    max_page_size = 1000

    def get_paginated_response(self, data):
        return Response({
            'total': self.page.paginator.object_list.count(),
            'limit': self.page.paginator.per_page,
            'results': data,
            'current': self.page.number,
            'next': self.page.next_page_number() if self.page.has_next() else None,
            'previous': self.page.previous_page_number() if self.page.has_previous() else None,
            'total_pages': self.page.paginator.num_pages,
            'from': self.page.start_index(),
            'to': self.page.end_index(),
        })


class LetterPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'limit'
    max_page_size = 1000

    def paginate_queryset(self, queryset, request, view=None):
        letter = request.query_params.get('letter', None)

        if letter:
            queryset = queryset.filter(name__istartswith=letter)

        return super().paginate_queryset(queryset, request, view)

    def get_paginated_response(self, data):
        return Response({
            'total': len(data),
            'results': data,
        })
